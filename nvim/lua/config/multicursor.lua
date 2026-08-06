-- multicursor.nvim 설정 (vim-visual-multi 대체)
--
-- 이전 이유:
--   VM은 upstream이 2024-09-01에서 멈췄다(우리 핀 = upstream master HEAD).
--   그리고 VM은 자체 모드/매핑 체계를 만드는 구조라 진입점이 17개로 흩어져 있어
--   lazy 트리거로 다루기 어려웠다(실제로 keys 트리거로 바꿨다가 11개가 죽었다).
--   multicursor.nvim은 Neovim API 기반이고 진입점을 우리가 전부 명시한다.
--
-- 키 매핑은 기존 VM_maps의 손버릇을 그대로 옮긴다:
--   <C-n>      Find Under          -> matchAddCursor(1)      (주 진입점)
--   <C-Down>   Select Cursor Down  -> lineAddCursor(1)
--   <C-Up>     Select Cursor Up    -> lineAddCursor(-1)
--   <C-a>(x)   Visual All          -> matchAllAddCursors()
--   <C-LeftMouse> 계열              -> handleMouse* (VM_mouse_mappings = 1 대응)
--
-- VM에서 기본 리더(\\)에 있던 것은 <leader>m 네임스페이스로 옮긴다:
--   \\A  Select All        -> <leader>ma
--   \\\  Add Cursor At Pos -> <leader>mp
--
-- 주의: <C-a>/<C-x>는 숫자 증감이라 normal 모드에서 덮지 않는다(VM 설정의 경고와 동일).
-- <Left>/<Right>는 keys.lua가 창 크기 조절에 쓰므로 커서 이동은 <S-Left>/<S-Right>로 둔다.

local M = {}

function M.setup()
  local mc = require("multicursor-nvim")
  mc.setup()

  local set = vim.keymap.set
  local function d(desc)
    return { desc = "Multicursor: " .. desc }
  end

  -- 주 진입점 (VM <C-n>과 동일: 커서 아래 단어 / 선택 영역의 다음 일치에 커서 추가)
  set({ "n", "x" }, "<C-n>", function()
    mc.matchAddCursor(1)
  end, d("다음 일치에 커서 추가"))

  -- 위/아래 줄에 커서 추가 (VM <C-Down>/<C-Up>)
  set({ "n", "x" }, "<C-Down>", function()
    mc.lineAddCursor(1)
  end, d("아래 줄에 커서 추가"))
  set({ "n", "x" }, "<C-Up>", function()
    mc.lineAddCursor(-1)
  end, d("위 줄에 커서 추가"))

  -- 비주얼 모드에서 선택 영역의 모든 일치 (VM <C-a>)
  set("x", "<C-a>", mc.matchAllAddCursors, d("모든 일치에 커서 추가"))

  -- VM에서 \\ 리더에 있던 것들
  set({ "n", "x" }, "<leader>ma", mc.matchAllAddCursors, d("모든 일치에 커서 추가"))
  set({ "n", "x" }, "<leader>mp", function()
    mc.addCursor()
  end, d("현재 위치에 커서 추가"))

  -- 건너뛰기 / 역방향 (VM에는 없던 기능이지만 matchAddCursor의 짝이라 함께 둔다)
  set({ "n", "x" }, "<leader>mn", function()
    mc.matchSkipCursor(1)
  end, d("다음 일치 건너뛰기"))
  set({ "n", "x" }, "<leader>mN", function()
    mc.matchAddCursor(-1)
  end, d("이전 일치에 커서 추가"))

  -- 마우스 (기존 VM_mouse_mappings = 1 대응)
  set("n", "<C-LeftMouse>", mc.handleMouse, d("클릭 위치에 커서 추가"))
  set("n", "<C-LeftDrag>", mc.handleMouseDrag, d("드래그로 커서 추가"))
  set("n", "<C-LeftRelease>", mc.handleMouseRelease, d("드래그 종료"))

  -- 커서 일시 비활성/재활성
  set({ "n", "x" }, "<C-q>", mc.toggleCursor, d("커서 토글"))

  -- 아래 매핑은 커서가 여러 개일 때만 적용된다(layer). 평소 키를 가리지 않는다.
  mc.addKeymapLayer(function(layer)
    -- 주 커서 이동. <Left>/<Right>는 keys.lua의 창 크기 조절이라 피한다.
    layer({ "n", "x" }, "<S-Left>", mc.prevCursor, d("이전 커서로"))
    layer({ "n", "x" }, "<S-Right>", mc.nextCursor, d("다음 커서로"))
    layer({ "n", "x" }, "<leader>mx", mc.deleteCursor, d("주 커서 삭제"))

    -- <Esc>: 비활성 상태면 되살리고, 아니면 커서를 정리한다.
    -- keys.lua의 전역 <Esc>(:noh)는 커서가 있는 동안만 가려진다.
    layer("n", "<Esc>", function()
      if not mc.cursorsEnabled() then
        mc.enableCursors()
      else
        mc.clearCursors()
      end
    end, d("커서 정리 / 재활성"))
  end)

  -- 하이라이트. catppuccin에는 multicursor integration이 없으므로
  -- 테마를 따라가도록 기존 그룹에 링크한다(VM의 iceblue 테마 대체).
  local hl = vim.api.nvim_set_hl
  hl(0, "MultiCursorCursor", { link = "Cursor" })
  hl(0, "MultiCursorVisual", { link = "Visual" })
  hl(0, "MultiCursorSign", { link = "SignColumn" })
  hl(0, "MultiCursorMatchPreview", { link = "Search" })
  hl(0, "MultiCursorDisabledCursor", { link = "Comment" })
  hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
  hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
end

return M
