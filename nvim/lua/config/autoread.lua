-- 밖에서 바뀐 파일을 버퍼에 반영한다.
--
-- 'autoread'는 nvim이 파일을 다시 확인할 때(:checktime)만 동작하고, nvim은 스스로 확인하지
-- 않는다. 그래서 두 군데서 확인시킨다.
--
-- 1. 포커스가 돌아오거나 버퍼에 들어갈 때: 모든 버퍼를 확인한다.
-- 2. 1초마다: 지금 탭의 창에 보이는 버퍼만 확인한다. 옆 pane의 에이전트가 파일을 고치는 동안
--    nvim은 포커스가 없어서 1번이 일어나지 않는다. 지켜보는 화면이 옛 내용으로 남는다
--    (실측: 밖에서 고친 뒤 4초가 지나도 그대로, 포커스가 돌아와야 바뀜).
--
-- 2번은 **조용히 다시 읽고 끝나는 경우에만** 한다. :checktime은 경우에 따라 확인 창을 띄우는데,
-- 타이머가 띄우면 타이핑하던 다음 글자가 그 답이 된다(l이면 Load File — 저장하지 않은 편집을
-- 버린다). `silent!`는 그 창을 막지 못한다. 그래서 아래는 건너뛰고 1번에 맡긴다. 1번은 사람이
-- nvim으로 돌아온 순간이라 물어도 된다.
--   - 수정한 버퍼: 파일도 바뀌었으면 W12를 묻는다.
--   - 파일을 읽은 적이 없는 버퍼(없는 경로를 :edit한 것): 그 파일이 생기면 W13을 묻는다(실측).
--   - 'autoread'를 끈 버퍼(:setlocal noautoread): W11을 묻는다(실측).
--   - 파일이 지금 없는 버퍼: 묻지는 않지만 :checktime 한 번이 "지워졌다"는 알림(E211)을 써 버려서
--     1번에서도 다시 나오지 않는다(실측). 지워진 것을 모른 채 저장해 파일을 되살리게 된다.
--   - 노멀 모드가 아닐 때: 입력·선택·명령줄 도중에 버퍼 내용이 바뀌면 안 된다.
-- 드는 일은 버퍼마다 stat 한 번이다.

local M = {}

local POLL_MS = 1000

-- 이 버퍼의 내용이 디스크의 그 파일에서 왔거나 거기에 쓰였다 (vim.b에 두는 표시).
local ON_DISK = "autoread_on_disk"

local function check_all()
  if vim.api.nvim_get_mode().mode ~= "c" and vim.fn.getcmdwintype() == "" then
    vim.cmd("checktime")
  end
end

-- 지역 값이 없으면 nvim_get_option_value가 nil을 돌려준다(실측). 그때는 전역 값을 따른다.
local function autoread_on(buf)
  local value = vim.api.nvim_get_option_value("autoread", { buf = buf })
  if value == nil then
    return vim.go.autoread
  end
  return value
end

local function reloads_quietly(buf)
  if vim.bo[buf].buftype ~= "" or vim.bo[buf].modified or not vim.b[buf][ON_DISK] or not autoread_on(buf) then
    return false
  end
  local name = vim.api.nvim_buf_get_name(buf)
  return name ~= "" and vim.uv.fs_stat(name) ~= nil
end

local function check_visible()
  local mode = vim.api.nvim_get_mode()
  if mode.blocking or mode.mode ~= "n" or vim.fn.getcmdwintype() ~= "" then
    return
  end
  local seen = {}
  -- 지금 탭의 창만 본다. nvim_list_wins()는 다른 탭의 창까지 돌려준다.
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if not seen[buf] and not vim.api.nvim_win_get_config(win).hide then
      seen[buf] = true
      if reloads_quietly(buf) then
        -- silent!: 다시 읽었다는 줄("a.txt" 3L, 40B)과 권한만 바뀐 경우의 W16을 내지 않는다
        vim.cmd("silent! checktime " .. buf)
      end
    end
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("ExternalChanges", { clear = true })
  vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, { group = group, callback = check_all })
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    callback = function(args)
      vim.b[args.buf][ON_DISK] = true
    end,
  })
  -- 없는 파일을 편집하기 시작했다. 읽은 적이 있는 버퍼도 여기로 올 수 있다: 파일이 밖에서 지워진
  -- 뒤 :edit!를 하면 같은 버퍼가 "새 파일"이 되고, 그 파일이 다시 생기면 W13을 묻는다.
  vim.api.nvim_create_autocmd("BufNewFile", {
    group = group,
    callback = function(args)
      vim.b[args.buf][ON_DISK] = nil
    end,
  })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    callback = function(args)
      -- `:w 다른이름`은 이 버퍼의 파일을 만들지 않으므로, 쓴 파일이 이 버퍼의 파일일 때만 표시한다.
      -- 경로 문자열로 비교하면 안 된다. 심링크를 거친 경로로 연 버퍼는 이벤트의 경로(link/…)와
      -- 버퍼 이름(real/…)이 달라서 표시가 붙지 않았고, 그 뒤의 외부 변경을 읽지 않았다.
      local written = vim.uv.fs_realpath(args.match)
      if written and written == vim.uv.fs_realpath(vim.api.nvim_buf_get_name(args.buf)) then
        vim.b[args.buf][ON_DISK] = true
      end
    end,
  })
  -- 화면이 있을 때만 돈다. --headless로 도는 스크립트에는 타이머를 걸지 않는다.
  vim.api.nvim_create_autocmd("UIEnter", {
    group = group,
    once = true,
    callback = function()
      local timer = vim.uv.new_timer()
      if timer then
        timer:start(POLL_MS, POLL_MS, vim.schedule_wrap(check_visible))
      end
    end,
  })
end

return M
