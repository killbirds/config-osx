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
--     남긴 탭 바는 Herdr 테마의 배경색을 기준으로 칠하고(config/bufferline.lua), 테마가 바뀌면
--     다시 칠한다.
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

-- look.lua가 색을 읽는 파일. look.lua를 읽힌 뒤에만 값이 있다.
local theme_file

-- Herdr 테마의 색 표. 읽지 못하면 nil.
-- 읽는 순서는 look.lua의 read_theme과 같다: g:herdr_theme가 있으면 그것, 없으면 .theme.json.
local function read_theme()
  if not theme_file then
    return nil
  end
  local theme = vim.g.herdr_theme
  if type(theme) == "table" then
    return theme
  end
  local file = io.open(theme_file, "r")
  if not file then
    return nil
  end
  local text = file:read("*a")
  file:close()
  local ok, decoded = pcall(vim.json.decode, text)
  return ok and type(decoded) == "table" and decoded or nil
end

-- Herdr 테마의 배경색("#rrggbb"). Herdr 모양이 아닌 nvim에서는 nil.
-- config/bufferline.lua가 탭 바 색의 기준으로 쓴다. look.lua는 bufferline을 칠하지 않는다
-- (토글이 띄운 nvim에는 bufferline이 없다). 남겨 둔 쪽에서 색을 맞추는 것은 이 설정의 일이다.
function M.background()
  local theme = read_theme()
  local background = theme and theme.background
  if type(background) == "string" and background:find("^#%x%x%x%x%x%x") then
    return background:sub(1, 7)
  end
  return nil
end

-- bufferline을 지금 색으로 다시 칠한다.
-- bufferline은 ColorScheme에서만 색을 다시 계산하므로 그 자동 명령(BufferlineCmds 그룹)만 실행한다.
--
-- 실행하기 전에 bufferline의 그룹을 비워야 한다. bufferline은 그룹을 `default`로 정의해서
-- (options.themable) 이미 있는 그룹은 덮어쓰지 않는다. 진짜 ColorScheme에서는 colorscheme이
-- 먼저 전부 지우므로 문제가 없지만, 여기서는 지워 주지 않으면 옛 색이 그대로 남는다(실측).
-- 비우는 것은 bufferline이 다시 만드는 그룹뿐이다: 설정의 하이라이트 표에 있는 그룹과, 탭마다
-- 만드는 아이콘 그룹(BufferLine + devicons 그룹 이름, 즉 BufferLineDevIcon*). 이름이
-- BufferLine으로 시작한다고 전부 비우면 손으로 정의한 그룹은 되살릴 주체가 없다.
-- (아이콘 그룹은 접두사로만 가릴 수 있다. BufferLineDevIcon으로 시작하는 그룹을 손으로 만들면
--  여기서 지워진다 — 그 이름은 colorscheme을 바꿀 때도 지워지는 자리다.)
local function repaint_bufferline()
  if not package.loaded["bufferline"] then
    return -- 아직 로드 전이면 로드될 때 지금 테마로 칠한다
  end
  local own = {}
  pcall(function()
    for _, hl in pairs(require("bufferline.config").highlights) do
      if type(hl) == "table" and hl.hl_group then
        own[hl.hl_group] = true
      end
    end
  end)
  for name in pairs(vim.api.nvim_get_hl(0, {})) do
    if own[name] or vim.startswith(name, "BufferLineDevIcon") then
      vim.api.nvim_set_hl(0, name, {})
    end
  end
  pcall(vim.api.nvim_exec_autocmds, "ColorScheme", { group = "BufferlineCmds" })
  vim.cmd.redrawtabline()
end

-- Herdr 테마가 바뀌면 bufferline도 다시 칠한다.
-- look.lua는 테마 파일이 바뀌면 HerdrNvimLook.reload를 부르고(테마를 다시 읽어 apply),
-- ColorScheme 이벤트는 내지 않는다. 그래서 reload를 감싸 그 뒤에 칠한다.
--
-- reload에 묶는 이유: look.lua가 쓰는 색이 바뀌는 곳이 거기뿐이다. apply는 트리를 열 때 등에도
-- 불리고 그때는 메모리의 옛 테마로 칠한다. apply 뒤에 테마 파일을 읽어 "바뀌었나"를 비교하면,
-- 파일이 바뀐 직후 reload보다 먼저 온 apply가 새 테마를 이미 칠한 것으로 기록해서 정작 reload
-- 때는 칠하지 않는다(실측: Normal과 선택된 탭의 글자색이 갈림). 비교 없이 reload마다 칠한다.
-- reload는 테마 파일이 바뀔 때만 오고, 칠하는 것은 하이라이트 그룹 백여 개다.
local function repaint_bufferline_on_theme_change()
  -- look.lua가 자신을 내놓는 곳이 전역 HerdrNvimLook뿐이다
  -- selene: allow(global_usage)
  local look = rawget(_G, "HerdrNvimLook")
  if type(look) ~= "table" or type(look.reload) ~= "function" then
    return
  end
  local reload = look.reload
  look.reload = function(...)
    reload(...)
    repaint_bufferline()
  end
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
  theme_file = vim.fn.fnamemodify(look, ":h") .. "/.theme.json"
  if not launched_by_mod() then
    keep_bufferline()
    repaint_bufferline_on_theme_change()
  end
end

return M
