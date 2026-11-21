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
-- nvim이 뜨는 경로는 둘이고, bufferline만 다르게 다룬다.
--   - Herdr의 Nvim 토글 버튼: mod가 `nvim -S look.lua`로 띄운다. 옆에 붙여 두고 파일 하나를
--     보는 pane이라 bufferline이 없어도 된다. look.lua가 하는 그대로 둔다.
--   - 셸에서 손으로 띄운 nvim: 이 파일이 look.lua를 읽혀 같은 색이 되게 하되, **bufferline은
--     남긴다.** 버퍼를 여럿 열어 놓고 일하는 쪽이라 pane 헤더의 파일 이름 하나로는 부족하다.
-- 둘은 시작 인자로 가른다. mod가 띄운 nvim에만 `-S …/mods/nvim/look.lua`가 있다(v:argv).
--
-- 아무 일도 하지 않는 경우:
--   - HC_TERMINAL_ID가 없다: herdr-core가 자기 터미널에 넣는 환경 변수다. Ghostty 등 다른
--     터미널에서 띄운 nvim은 건드리지 않는다.
--   - UI가 없다(--headless): 스크립트로 돌리는 nvim의 옵션과 하이라이트를 바꾸지 않는다.
--   - look.lua가 없다: mod를 설치하지 않은 머신.

local M = {}

local LOOK = "/mods/nvim/look.lua"

-- mod의 Nvim 토글이 띄운 nvim인가. mod는 자기 경로 표기로 look.lua를 넘기므로
-- (HERDR_APP_HOME, ~ 전개 여부가 이쪽과 다를 수 있다) 전체 경로가 아니라 끝부분으로 본다.
local function launched_by_mod()
  local argv = vim.v.argv
  for i = 1, #argv - 1 do
    if argv[i] == "-S" and vim.endswith(argv[i + 1], LOOK) then
      return true
    end
  end
  return false
end

-- look.lua는 다시 칠할 때마다(VimEnter, VeryLazy, 트리 열기, ColorScheme, 테마 변경, 시작 1초 뒤)
-- showtabline을 0으로 되돌린다. 그 호출들을 하나씩 쫓지 않고 옵션이 0이 되는 순간 되돌린다.
-- 그래서 이 nvim에서는 `:set showtabline=0`으로 bufferline을 끌 수 없다.
local function keep_bufferline()
  vim.o.showtabline = 2 -- 시작 중에는 OptionSet이 발생하지 않으므로 지금 값도 직접 맞춘다
  vim.api.nvim_create_autocmd("OptionSet", {
    group = vim.api.nvim_create_augroup("HerdrKeepBufferline", { clear = true }),
    pattern = "showtabline",
    callback = function()
      if vim.o.showtabline == 0 then
        vim.o.showtabline = 2
      end
    end,
  })
end

function M.setup()
  if not vim.env.HC_TERMINAL_ID or #vim.api.nvim_list_uis() == 0 then
    return
  end
  local home = vim.env.HERDR_APP_HOME or vim.fn.expand("~/.config/herdr-app")
  local look = home .. LOOK
  if vim.fn.filereadable(look) == 0 then
    return
  end
  local ok, err = pcall(vim.cmd.source, look)
  if not ok then
    vim.notify("Herdr look을 읽지 못했습니다: " .. tostring(err), vim.log.levels.WARN)
    return
  end
  if not launched_by_mod() then
    keep_bufferline()
  end
end

return M
