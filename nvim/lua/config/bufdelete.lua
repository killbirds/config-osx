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
local function remove(method, buf, force)
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
