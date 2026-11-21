-- 노멀 모드로 돌아오면 macOS 입력기를 영문(ABC)으로 돌린다. 한글 상태로는 노멀 모드 키가 먹지 않는다.
-- 입력기를 읽고 바꾸는 일은 macism이 한다 (brew install macism, README의 "한글 입력 지원 도구 설치").
--
-- im-select.nvim을 대체한다. 그 플러그인과 다른 점은 둘이다.
--   - nvim을 멈추지 않는다. 플러그인은 이벤트마다 `macism`을 vim.fn.system으로 불러 현재 입력기를
--     읽었고(호출 한 번에 약 40ms, 실측), 그동안 화면과 다음 키 처리가 멈췄다. <Esc>를 누를 때마다였다.
--     그 값은 "이전 입력기로 되돌리기"에 쓰는 것인데 그 기능은 꺼 두고 있었다.
--   - 글자를 넣는 중이면 포커스가 돌아와도 건드리지 않는다. 플러그인은 모드를 보지 않아서, 입력
--     모드에서 한글을 치다가 옆 pane에 다녀오면 영문으로 바뀌어 있었다(실측).
--
-- 아무 일도 하지 않는 경우: macOS가 아니다, 화면이 없다(--headless — 스크립트가 사용자의 입력기를
-- 바꾸면 안 된다).

local M = {}

local ABC = "com.apple.keylayout.ABC"
-- macism이 끝나지 않으면 이만큼 뒤에 SIGTERM을 보낸다. 없으면 한 번 걸린 호출이 뒤의 요청을
-- 전부 막는다. (SIGTERM을 무시하는 프로세스까지 끝내지는 않는다. macism은 그렇지 않다.)
local TIMEOUT_MS = 2000

local running = false
local again = false
-- 포커스 이벤트를 주지 않는 터미널에서는 계속 true다 (그때는 포커스를 가리지 않고 바꾼다).
local focused = true

-- 입력(i)·치환(R)·명령줄(c)·터미널(t) 모드에서는 글자를 치는 중이다
local function typing()
  return vim.api.nvim_get_mode().mode:find("^[iRct]") ~= nil
end

-- 프로세스를 시작하지 못하면 vim.system이 예외를 던진다(실측: 실행 파일이 사라지면 ENOENT).
-- 그때는 on_exit이 불리지 않으므로 호출한 쪽이 직접 뒷정리를 해야 한다.
local function spawn(cmd, on_exit)
  return (pcall(vim.system, cmd, { text = true, timeout = TIMEOUT_MS }, on_exit))
end

-- 이미 ABC면 바꾸지 않는다(읽고 나서 다를 때만 바꾼다). 도는 중에 또 불리면 끝난 뒤 한 번 더 본다.
local function to_abc()
  if running then
    again = true
    return
  end
  running = true
  local function done()
    running = false
    if again then
      again = false
      vim.schedule(to_abc)
    end
  end
  local started = spawn({ "macism" }, function(read)
    if read.code ~= 0 or vim.trim(read.stdout or "") == ABC then
      done()
      return
    end
    -- 판단은 메인 루프에서 한다. 그사이의 포커스·모드 이벤트가 처리된 뒤의 값을 봐야 한다.
    vim.schedule(function()
      -- 읽는 동안(약 40ms) 사정이 바뀌었으면 바꾸지 않는다. 그사이 입력 모드에 들어갔으면 치던
      -- 한글이 영문이 되고, 포커스가 떠났으면 옮겨 간 pane의 입력기를 바꾸게 된다(둘 다 실측).
      if not focused or typing() or not spawn({ "macism", ABC }, done) then
        done()
      end
    end)
  end)
  if not started then
    running, again = false, false
  end
end

function M.setup()
  if vim.fn.has("mac") == 0 or #vim.api.nvim_list_uis() == 0 then
    return
  end
  if vim.fn.executable("macism") == 0 then
    vim.schedule(function()
      vim.notify(
        "macism이 없어 입력기를 자동으로 영문으로 돌리지 못합니다 (brew install macism)",
        vim.log.levels.WARN
      )
    end)
    return
  end

  local group = vim.api.nvim_create_augroup("InputSource", { clear = true })
  vim.api.nvim_create_autocmd({ "VimEnter", "InsertLeave", "CmdlineLeave" }, { group = group, callback = to_abc })
  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function()
      focused = true
      if not typing() then
        to_abc()
      end
    end,
  })
  vim.api.nvim_create_autocmd("FocusLost", {
    group = group,
    callback = function()
      focused = false
    end,
  })
end

return M
