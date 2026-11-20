-- Herdr 앱(herdr-core 터미널) 안에서 뜬 nvim을 Herdr pane 모양에 맞춘다.
--
-- 실제 일은 Herdr 쪽 nvim mod가 가진 look.lua가 한다 (~/.config/herdr-app/mods/nvim/look.lua):
--   - 배경을 그리지 않아 Herdr의 터미널 여백과 편집 영역이 한 색이 된다.
--   - 커서 줄·구분선·팝업·lualine을 Herdr 테마 색으로 칠한다 (문법 강조 색은 colorscheme 그대로).
--   - bufferline과 nvim-tree의 루트 경로 줄·sign column을 숨긴다 (pane 헤더가 대신 보여 준다).
--   - 창 제목을 파일 이름으로 둔다 (pane 헤더에 나온다).
-- 색은 mod가 같은 폴더의 .theme.json에 써 두고, look.lua가 그 파일을 지켜본다. 그래서 Herdr
-- 테마를 바꾸면 떠 있는 nvim도 따라온다.
--
-- Herdr의 Nvim 토글 버튼으로 띄운 nvim은 mod가 `nvim -S look.lua`로 직접 읽힌다. 이 파일은 셸에서
-- 손으로 띄운 nvim도 같은 모양이 되게 한다. look.lua는 두 번 읽혀도 한 번만 설치된다.
--
-- 아무 일도 하지 않는 경우:
--   - HC_TERMINAL_ID가 없다: herdr-core가 자기 터미널에 넣는 환경 변수다. Ghostty 등 다른
--     터미널에서 띄운 nvim은 건드리지 않는다.
--   - UI가 없다(--headless): 스크립트로 돌리는 nvim의 옵션과 하이라이트를 바꾸지 않는다.
--   - look.lua가 없다: mod를 설치하지 않은 머신.

local M = {}

function M.setup()
  if not vim.env.HC_TERMINAL_ID or #vim.api.nvim_list_uis() == 0 then
    return
  end
  local home = vim.env.HERDR_APP_HOME or vim.fn.expand("~/.config/herdr-app")
  local look = home .. "/mods/nvim/look.lua"
  if vim.fn.filereadable(look) == 0 then
    return
  end
  local ok, err = pcall(vim.cmd.source, look)
  if not ok then
    vim.notify("Herdr look을 읽지 못했습니다: " .. tostring(err), vim.log.levels.WARN)
  end
end

return M
