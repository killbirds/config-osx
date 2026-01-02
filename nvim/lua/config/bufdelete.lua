-- 버퍼가 특정 파일 타입이 아닌 경우에만 현재 버퍼를 삭제하는 기능
-- 특별한 UI 요소나 중요한 버퍼들은 실수로 닫히지 않도록 보호합니다.

-- 보호할 파일 타입 목록
local protected_filetypes = {
  "NvimTree",
  "dashboard",
  "Avante",
  "help",           -- 도움말 문서
  "qf",             -- Quickfix 목록
  "terminal",       -- 내장 터미널
  "prompt",         -- 프롬프트 입력
  "TelescopePrompt", -- Telescope 검색
  "lazy",           -- Lazy 플러그인 관리자
  "lspinfo",        -- LSP 정보 창
  "toggleterm",     -- ToggleTerm 터미널
  "alpha",          -- Alpha 시작 화면
  "DiffviewFiles",  -- Diffview 파일 목록
  -- 필요에 따라 더 추가할 수 있습니다
}

vim.keymap.set("n", "<C-c>", function()
  local ft = vim.bo.filetype

  -- 보호된 파일 타입인지 확인
  local is_protected = false
  for _, protected_ft in ipairs(protected_filetypes) do
    if ft == protected_ft then
      is_protected = true
      break
    end
  end

  if not is_protected then
    local ok, err = pcall(require("bufdelete").bufdelete, 0, true)
    if not ok then
      vim.notify("버퍼를 삭제할 수 없습니다: " .. err, vim.log.levels.ERROR)
    end
  end
end, {
  silent = true,
  desc = "NvimTree, dashboard, Avante 등의 특수 버퍼가 아닌 경우에만 현재 버퍼 강제 삭제",
})
