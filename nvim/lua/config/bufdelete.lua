-- 버퍼가 특정 파일 타입이 아닌 경우에만 현재 버퍼를 삭제하는 기능
-- 특별한 UI 요소나 중요한 버퍼들은 실수로 닫히지 않도록 보호합니다.

local M = {}

-- 보호할 파일 타입 목록
local protected_filetypes = {
  "NvimTree",
  "dashboard",
  "Avante",
  "help", -- 도움말 문서
  "qf", -- Quickfix 목록
  "prompt", -- 프롬프트 입력
  "fzf", -- fzf-lua picker (buftype은 terminal이지만 filetype으로도 잡힌다)
  "fzflua_backdrop", -- fzf-lua 배경 창
  "lazy", -- Lazy 플러그인 관리자
  "lspinfo", -- LSP 정보 창
  "toggleterm", -- ToggleTerm 터미널
  "alpha", -- Alpha 시작 화면
  "DiffviewFiles", -- Diffview 파일 목록
  -- 필요에 따라 더 추가할 수 있습니다
}

-- 보호할 buftype 목록.
-- 내장 터미널(:terminal, <leader>tt/<leader>tv)은 filetype이 빈 문자열이고
-- buftype만 "terminal"이다(실측). 그래서 filetype 목록에 "terminal"을 넣어도
-- 한 번도 매치되지 않았고, 실행 중인 job이 붙은 터미널이 그대로 강제 종료됐다.
local protected_buftypes = {
  "terminal",
}

-- 수정된 버퍼면 Save / Discard / Cancel을 묻고 나서 mini.bufremove로 지운다.
-- mini.bufremove 자체 확인은 "강제로 지울까?"(No/Yes)뿐이라 저장하고 닫는 길이 없다.
-- 예전 bufdelete.nvim의 Save/Ignore/Cancel 동작을 이어 간다. 이 설정은 swapfile을
-- 전역으로 끄고 있어(lua/init.lua) 저장 전 내용을 잃으면 복구 수단도 없다.
---@param method "delete"|"wipeout"
---@param buf integer 0이면 현재 버퍼
---@param force boolean true면 묻지 않고 변경을 버린다
---@param before_delete? fun() 확인이 끝나 실제로 지우기 직전에 불린다(취소하면 불리지 않는다)
local function remove(method, buf, force, before_delete)
  if buf == 0 then
    buf = vim.api.nvim_get_current_buf()
  end
  if not force and vim.bo[buf].modified then
    local name = vim.api.nvim_buf_get_name(buf)
    name = name ~= "" and vim.fn.fnamemodify(name, ":~:.") or "[No Name]"
    local choice = vim.fn.confirm(
      string.format("%s에 저장하지 않은 변경이 있습니다.", name),
      "&Save\n&Discard\n&Cancel",
      3
    )
    if choice == 1 then
      local ok, err = pcall(vim.api.nvim_buf_call, buf, function()
        vim.cmd.write()
      end)
      if not ok or vim.bo[buf].modified then
        vim.notify("저장하지 못해 버퍼를 닫지 않았습니다: " .. tostring(err), vim.log.levels.ERROR)
        return
      end
    elseif choice == 2 then
      force = true
    else
      return
    end
  end
  if before_delete then
    before_delete()
    -- bufhidden=wipe인 버퍼는 창에서 내려가는 순간 이미 지워진다
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end
  end
  require("mini.bufremove")[method](buf, force)
end

function M.smart_bufdelete()
  local ft = vim.bo.filetype
  local bt = vim.bo.buftype

  -- 보호된 버퍼인지 확인
  if vim.tbl_contains(protected_filetypes, ft) or vim.tbl_contains(protected_buftypes, bt) then
    return
  end

  local ok, err = pcall(remove, "delete", 0, false)
  if not ok then
    vim.notify("버퍼를 삭제할 수 없습니다: " .. err, vim.log.levels.ERROR)
  end
end

-- 파일을 보여 주는 일반 창인가 (트리·quickfix·help·터미널·플로팅 창이 아닌 것).
local function is_file_window(win)
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    return false
  end
  return vim.bo[vim.api.nvim_win_get_buf(win)].buftype == ""
end

-- bufferline에 탭으로 보이는 파일 버퍼인가.
-- buflisted만 보면 안 된다. quickfix 버퍼도 listed라서(실측) "넘어갈 다른 버퍼"로 세면
-- 파일 하나 + quickfix 창인 배치에서 파일 버퍼를 지우고 그 창에 quickfix를 띄운다.
local function is_file_buffer(buf)
  return vim.bo[buf].buflisted and vim.bo[buf].buftype == ""
end

-- cur 말고 남아 있는 파일 버퍼 하나. 직전에 보던 버퍼(#)를 먼저 고르고, 없으면 목록에서
-- 바로 앞의 것(없으면 맨 뒤로 돌아간다 — :bprevious와 같은 방향).
local function other_file_buffer(cur)
  local alt = vim.fn.bufnr("#")
  if alt > 0 and alt ~= cur and vim.api.nvim_buf_is_valid(alt) and is_file_buffer(alt) then
    return alt
  end
  local before, last
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= cur and is_file_buffer(buf) then
      if buf < cur then
        before = buf
      end
      last = buf
    end
  end
  return before or last
end

-- 현재 창이 smart_quit이 다룰 창인가. 아니면 :q는 내장 동작(이 창을 닫는다)이어야 한다.
local function is_plain_file_window(win, buf)
  if not is_file_window(win) or not is_file_buffer(buf) then
    return false
  end
  -- 탭 페이지를 여럿 쓰는 중이면 :q는 이 탭을 닫는 뜻이다
  if #vim.api.nvim_list_tabpages() > 1 then
    return false
  end
  if vim.wo[win].previewwindow then
    return false
  end
  -- diff를 보는 중이면 :q는 그 창을 닫는 뜻이다. 상대편(fugitive, gitsigns)은 buftype이
  -- nowrite라 "다른 파일 창" 검사로는 걸러지지 않으므로 diff 옵션으로 본다. 상대편을 먼저
  -- 닫으면 남은 창에 diff 옵션만 켜진 채 남는데, 그건 diff 중이 아니므로 상대가 있을 때만 친다.
  if vim.wo[win].diff then
    for _, other in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if other ~= win and vim.wo[other].diff then
        return false
      end
    end
  end
  return true
end

-- :q가 창이 아니라 버퍼를 닫아야 하는 상황이면 대신 보여 줄 버퍼를 돌려준다.
-- 현재 창이 이 탭의 **하나뿐인 파일 창**이고, 넘어갈 다른 파일 버퍼가 남아 있을 때만 그렇다.
-- 트리·help·quickfix·터미널 같은 보조 창이 옆에 있어도 마찬가지다(파일 창이 사라지면 안 된다는
-- 사정이 같다).
local function buffer_to_show_instead(cur_win, cur_buf)
  -- 파일 창이 또 있으면 :q는 이 분할을 닫는 뜻이다
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= cur_win and is_file_window(win) then
      return nil
    end
  end
  return other_file_buffer(cur_buf)
end

-- 현재 버퍼가 마지막 파일 버퍼이고 이 창 옆에 nvim-tree만 있으면 그 트리 창들을 돌려준다.
-- 내장 :q는 이때 파일 창만 닫고 트리를 남긴다. 그러면 트리가 화면 전체를 차지하고,
-- 버퍼는 목록에 남아 있어서 bufferline이 "File Explorer" 자리에 그 버퍼의 탭을 그린다.
-- help·quickfix·터미널 창이 함께 남는 경우는 건드리지 않는다(그 창을 계속 볼 수 있다).
--
-- "마지막 파일 버퍼"는 여기서 직접 확인한다. 버퍼를 지우는 갈래로 가지 않았다는 것만으로는
-- 알 수 없다 — 파일 창이 또 있어서 안 간 경우에는 다른 버퍼가 남아 있다.
local function trees_beside_last_buffer(cur_win, cur_buf)
  if other_file_buffer(cur_buf) then
    return nil
  end
  local trees = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= cur_win and vim.api.nvim_win_get_config(win).relative == "" then
      if vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "NvimTree" then
        return nil
      end
      table.insert(trees, win)
    end
  end
  return #trees > 0 and trees or nil
end

-- Ex 명령을 실행하고, 실패하면 스택 트레이스 없이 Vim의 오류 문구만 보여 준다.
local function try_cmd(cmd)
  -- vim.cmd는 함수가 아니라 호출 가능한 테이블이라 pcall에 직접 넘기면 lua_ls가 타입 오류로 본다
  local ok, err = pcall(function()
    vim.cmd(cmd)
  end)
  if not ok then
    local msg = tostring(err):gsub("^.-(E%d+:)", "%1")
    vim.api.nvim_echo({ { msg, "ErrorMsg" } }, true, {})
  end
  return ok
end

-- 트리만 옆에 있는 마지막 버퍼에서의 :q[!] — 트리가 없었다면 내장 :q[!]가 했을 일을 그대로 한다.
-- 트리 창을 먼저 닫아 이 창을 마지막 창으로 만든 다음 내장 :quit[!]을 부른다.
--
-- :qa[!]로 대신하면 안 된다. 내장 :q!는 현재 버퍼의 변경만 버리고 **다른** 버퍼에 저장 안 된
-- 변경이 있으면 끝내지 않는데(:help :quit), :qa!는 전부 버린다. 그 검사를 여기서 흉내 내는
-- 것도 안 된다 — QuitPre autocmd가 검사 뒤에 버퍼를 고칠 수 있고, prompt 버퍼와 autowriteall의
-- 판정도 내장과 어긋났다(리뷰에서 각각 재현됨). 판정은 전부 내장 :quit에 맡긴다.
--
-- 끝내지 못했으면(E37 / E162) 닫았던 트리를 다시 연다.
local function quit_beside_tree(trees, bang)
  for _, win in ipairs(trees) do
    pcall(vim.api.nvim_win_close, win, false)
  end
  if not try_cmd({ cmd = "quit", bang = bang }) then
    pcall(function()
      require("nvim-tree.api").tree.toggle({ focus = false })
    end)
  end
end

-- :q / :wq / :x 대신 불린다(keys.lua가 명령줄의 <CR>에서 연결한다).
--
-- 내장 :q는 버퍼가 아니라 **창**을 닫는다. 트리 옆에 파일 창이 하나뿐인 평소 배치에서는
-- 그 창이 통째로 사라져 트리만 남고, bufferline에 다른 버퍼가 떠 있어도 볼 창이 없다.
-- bufferline의 탭을 닫는다는 감각과 맞추려고, 그 배치에서는 현재 버퍼만 지우고 창에는
-- 다른 파일 버퍼를 보여 준다. 마지막 버퍼라서 닫고 나면 트리만 남을 때는 nvim을 끝낸다.
-- 그 밖에는 전부 내장 :quit 그대로다:
--   파일 창이 또 있을 때(그 분할을 닫는다), diff를 보는 중이거나 미리보기 창일 때,
--   탭 페이지가 여럿일 때, unlisted 버퍼일 때,
--   트리·quickfix·help·터미널·플로팅 창에서, 마지막 버퍼인데 트리 말고 다른 창도 남을 때.
---@param opts? { bang?: boolean, write?: "write"|"update" } write: 닫기 전에 저장(:wq / :x)
function M.smart_quit(opts)
  opts = opts or {}
  local bang = opts.bang == true
  if opts.write and not try_cmd({ cmd = opts.write, bang = bang }) then
    return -- 저장하지 못했으면 닫지 않는다 (내장 :wq와 같다)
  end

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  if not is_plain_file_window(win, buf) then
    try_cmd({ cmd = "quit", bang = bang })
    return
  end

  local target = buffer_to_show_instead(win, buf)
  if target then
    -- 수정된 버퍼면 Save / Discard / Cancel을 묻는다. !를 붙이면 묻지 않고 버린다.
    -- 보여 줄 버퍼는 여기서 직접 고른다. mini.bufremove에 맡기면 # 다음으로 :bprevious를
    -- 쓰는데, 그건 quickfix처럼 listed인 비파일 버퍼에도 멈춘다.
    local ok, err = pcall(remove, "delete", buf, bang, function()
      vim.api.nvim_win_set_buf(win, target)
    end)
    if not ok then
      vim.notify("버퍼를 닫을 수 없습니다: " .. tostring(err), vim.log.levels.ERROR)
    end
    return
  end

  local trees = trees_beside_last_buffer(win, buf)
  if trees then
    quit_beside_tree(trees, bang)
    return
  end
  try_cmd({ cmd = "quit", bang = bang })
end

-- bufdelete.nvim이 주던 :Bdelete / :Bwipeout을 이어서 제공한다(bufferline, <Leader>bd가 쓴다).
-- 창 배치를 유지한 채 버퍼만 지운다. 인자는 버퍼 번호나 이름 하나, 없으면 현재 버퍼.
-- !를 붙이면 묻지 않고 변경을 버린다.
function M.setup()
  require("mini.bufremove").setup({})
  for name, method in pairs({ Bdelete = "delete", Bwipeout = "wipeout" }) do
    vim.api.nvim_create_user_command(name, function(args)
      local buf = 0
      if args.args ~= "" then
        buf = tonumber(args.args) or vim.fn.bufnr(args.args)
      end
      if buf < 0 or (buf ~= 0 and not vim.api.nvim_buf_is_valid(buf)) then
        vim.notify("버퍼를 찾을 수 없습니다: " .. args.args, vim.log.levels.ERROR)
        return
      end
      remove(method, buf, args.bang)
    end, { nargs = "?", bang = true, complete = "buffer", desc = "창을 유지한 채 버퍼 " .. method })
  end
end

return M
