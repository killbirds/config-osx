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

function M.smart_bufdelete()
  local ft = vim.bo.filetype
  local bt = vim.bo.buftype

  -- 보호된 버퍼인지 확인
  if vim.tbl_contains(protected_filetypes, ft) or vim.tbl_contains(protected_buftypes, bt) then
    return
  end

  -- force = false로 호출한다.
  -- true를 넘기면 bufdelete.nvim이 modified 버퍼의 Save/Ignore/Cancel 프롬프트를
  -- 건너뛴다(bufdelete/init.lua의 `if not force then` 분기). 이 설정은 swapfile을
  -- 전역으로 끄고 있어(lua/init.lua) 저장 전 내용을 잃으면 복구 수단도 없다.
  -- false로 두어도 플러그인이 사용자 선택 후 필요한 곳에서 bang을 알아서 붙인다.
  local ok, err = pcall(require("bufdelete").bufdelete, 0, false)
  if not ok then
    vim.notify("버퍼를 삭제할 수 없습니다: " .. err, vim.log.levels.ERROR)
  end
end

return M
