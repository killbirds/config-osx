-- 내장 undo 트리(0.12의 opt 패키지 nvim.undotree) 창을 여닫고 그 수명을 돌본다.
-- :Undotree 명령과 <Leader>u(keys.lua)가 이 모듈의 toggle을 부른다.
--
-- 내장 구현은 창을 여닫기만 하고 그 뒤는 돌보지 않는다
-- ($VIMRUNTIME/pack/dist/opt/nvim.undotree/lua/undotree.lua). 그대로 쓰면 0.12.6에서 다음이 재현됐다.
--   1. 원본 창을 닫으면 트리만 남고, 거기서 다시 토글하면 E444(마지막 창은 닫을 수 없다).
--   2. 트리를 하나 더 열면 먼저 연 트리가 멈춘다 — 열 때마다 같은 augroup을 비운다.
--   3. 트리 창에 다른 버퍼를 띄운 뒤 토글하면 그 창이 닫힌다 — 원본에 적어 둔 창 번호만 믿는다.
--   4. 원본 버퍼가 지워진 뒤 트리에서 커서를 옮기면 "Invalid buffer id".
--
-- 그래서 규칙 두 가지를 지킨다.
--   - 트리는 한 번에 하나만 연다.
--   - 원본 버퍼가 트리와 같은 탭에 보이는 동안만 트리를 둔다. 원본이 화면에서 사라지면
--     (그 창에서 다른 버퍼로 바꿈, 창을 닫음, 버퍼를 지움) 트리도 닫는다.
-- 트리는 창이 아니라 **버퍼**로 따라간다. 트리 창을 분할하거나(:split) 탭으로 옮기면(<C-w>T)
-- 창 번호 하나로는 놓친다 — 남은 창이 원본 없는 트리가 되어 문제 4가 되살아났다(실측).
-- 마지막 파일 버퍼에서 :q를 눌렀을 때 트리 때문에 nvim이 끝나지 않는 문제는
-- config/bufdelete.lua의 smart_quit이 맡는다(트리를 nvim-tree처럼 곁창으로 친다).

local M = {}

---@class UndotreeState
---@field source integer 원본 버퍼
---@field buf integer 트리 버퍼

---@type UndotreeState?
local state
local package_added = false
local check_pending = false

local function forget()
  -- 내장 open()은 원본의 b:nvim_undotree에 적힌 창이 살아 있으면 무조건 그 창을 닫는다(문제 3).
  -- 트리가 사라졌으면 그 연결도 지운다.
  if state and vim.api.nvim_buf_is_valid(state.source) then
    vim.b[state.source].nvim_undotree = nil
  end
  state = nil
end

-- 트리 버퍼를 보여 주는 창 전부(모든 탭). 보통 하나지만 트리 창을 분할하면 여럿이 된다.
---@param tree UndotreeState
---@return integer[]
local function tree_windows(tree)
  if not vim.api.nvim_buf_is_valid(tree.buf) then
    return {}
  end
  return vim.fn.win_findbuf(tree.buf)
end

-- 열려 있는 트리. 트리 버퍼를 보여 주는 창이 하나도 없으면(창을 닫았거나 그 창에 다른 버퍼를
-- 띄웠다) 기록을 지우고 nil을 돌려준다.
---@return UndotreeState?
local function current()
  if not state then
    return nil
  end
  if #tree_windows(state) > 0 then
    return state
  end
  forget()
  return nil
end

local function is_plain_window(win)
  return vim.api.nvim_win_get_config(win).relative == ""
end

-- 트리 창 하나를 닫는다. 닫았으면 true.
---@param win integer
---@param source integer 원본 버퍼
local function close_window(win, source)
  local plain_windows = 0
  for _, other in ipairs(vim.api.nvim_tabpage_list_wins(vim.api.nvim_win_get_tabpage(win))) do
    if is_plain_window(other) then
      plain_windows = plain_windows + 1
    end
  end
  if plain_windows > 1 or #vim.api.nvim_list_tabpages() > 1 then
    return (pcall(vim.api.nvim_win_close, win, true))
  end
  -- 화면에 남은 창이 트리뿐이다(원본 창을 :close로 닫은 경우). 마지막 창은 닫을 수 없으니
  -- 그 창에 원본을 다시 보여 준다. 트리 버퍼는 bufhidden=wipe라 창에서 빠지면 사라진다.
  local shown = source
  if not (vim.api.nvim_buf_is_valid(shown) and vim.bo[shown].buflisted) then
    shown = vim.api.nvim_create_buf(true, false)
  end
  return (pcall(vim.api.nvim_win_set_buf, win, shown))
end

-- 트리를 보여 주는 창을 전부 닫는다.
---@param tree UndotreeState
local function close(tree)
  local closed_all = true
  for _, win in ipairs(tree_windows(tree)) do
    closed_all = close_window(win, tree.source) and closed_all
  end
  -- 닫지 못한 창이 있으면(명령줄 창이 열려 있을 때 등) 기록을 남겨 다음 기회에 다시 시도한다.
  if closed_all then
    forget()
  end
end

-- 원본 버퍼가 이 탭의 일반 창에 보이는가. 플로팅 창은 치지 않는다 — 미리보기나 숨겨 둔(hide)
-- 창에 원본이 떠 있다고 해서 편집 중인 것은 아니다.
---@param tab integer
---@param source integer
local function source_visible_in(tab, source)
  if not vim.api.nvim_buf_is_loaded(source) then
    return false -- 지워졌거나(:bwipeout) 내려갔다(:bdelete)
  end
  for _, win in ipairs(vim.fn.win_findbuf(source)) do
    if vim.api.nvim_win_get_tabpage(win) == tab and is_plain_window(win) then
      return true
    end
  end
  return false
end

local function check()
  check_pending = false
  local tree = current()
  if not tree then
    return
  end
  for _, win in ipairs(tree_windows(tree)) do
    if not source_visible_in(vim.api.nvim_win_get_tabpage(win), tree.source) then
      close_window(win, tree.source)
    end
  end
  current() -- 남은 트리 창이 없으면 기록을 지운다
end

-- 창·버퍼 이벤트 도중에는 창을 닫을 수 없는 때가 있으므로 이벤트가 끝난 뒤에 확인한다.
-- 트리가 없으면 아무 일도 하지 않는다.
local function schedule_check()
  if state and not check_pending then
    check_pending = true
    vim.schedule(check)
  end
end

-- 현재 버퍼의 트리를 연다. 내장 open()이 하는 대로 커서는 트리 창으로 간다.
---@param buf integer 현재 버퍼
local function open_for(buf)
  if not package_added then
    vim.cmd.packadd("nvim.undotree")
    package_added = true
  end
  vim.b[buf].nvim_undotree = nil
  require("undotree").open()
  state = { source = buf, buf = vim.api.nvim_get_current_buf() }
end

-- 트리가 열려 있으면 닫는다(어느 창에서 부르든). 다른 파일에서 불렀을 때만 이어서 그 파일의
-- 트리를 연다. 열려 있지 않으면 현재 파일의 트리를 연다.
function M.toggle()
  local buf = vim.api.nvim_get_current_buf()
  local is_file = vim.bo[buf].buftype == ""
  local tree = current()
  if tree then
    local source = tree.source
    close(tree)
    if current() or buf == source or not is_file then
      return
    end
  elseif not is_file then
    vim.notify("undo 트리는 파일 버퍼에서만 엽니다", vim.log.levels.INFO)
    return
  end
  open_for(buf)
end

-- 현재 버퍼의 트리를 열되 커서는 지금 창에 둔다. 이미 열려 있으면 그대로 둔다.
-- (smart_quit이 닫았던 트리를 되살릴 때 쓴다)
function M.show()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  if current() or vim.bo[buf].buftype ~= "" then
    return
  end
  open_for(buf)
  if vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_set_current_win(win)
  end
end

function M.setup()
  -- 패키지의 plugin/undotree.lua가 :Undotree를 내장 open()으로 정의하지 않게 한다(그 파일의
  -- 로드 가드). 패키지 자체는 처음 열 때 packadd한다.
  vim.g.loaded_undotree_plugin = true
  vim.api.nvim_create_user_command("Undotree", function()
    M.toggle()
  end, { desc = "undo 트리 창 토글" })

  -- WinEnter / TabEnter는 버퍼 이벤트 없이 창 배치만 바뀌는 경우(<C-w>T 등)를 잡는다.
  vim.api.nvim_create_autocmd(
    { "BufEnter", "BufWinEnter", "WinEnter", "TabEnter", "WinClosed", "BufUnload", "BufDelete", "BufWipeout" },
    {
      group = vim.api.nvim_create_augroup("UserUndotree", { clear = true }),
      callback = schedule_check,
    }
  )
end

return M
