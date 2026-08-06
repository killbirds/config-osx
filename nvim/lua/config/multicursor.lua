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
--
-- 보존하지 않은 VM 키와 그 이유:
--   <C-h>/<C-l> Move Left/Right    -> 불필요. multicursor는 일반 모션이 전 커서에
--                                     적용된다(실측: llllX가 3줄 모두에 적용).
--   u / <C-r>   Undo/Redo          -> 불필요. 내장 undo가 멀티커서 편집을 한 단위로
--                                     되돌린다(실측: cwZZZ 후 u 한 번에 3줄 복원).
--   <S-Left>/<S-Right> Extend      -> 매핑하지 않고 비워 둔다(아래 layer 주석 참고).
--   <C-f>/<C-d> Visual Find/Add    -> visual <C-n>(matchAddCursor)과 <leader>mp가
--                                     역할을 대체한다.
--   Find Subword Under             -> 대응 없음. matchAddCursor는 단어 경계를 쓴다.

local M = {}

function M.setup()
  local mc = require("multicursor-nvim")
  mc.setup()

  local set = vim.keymap.set
  local function d(desc)
    return { desc = "Multicursor: " .. desc }
  end

  -- normal 모드에서 먼저 단어를 선택한 뒤 매칭한다.
  --
  -- 이게 없으면 VM과 감각이 다르다. multicursor의 match* 는 선택을 만들지 않고
  -- 커서만 옮기므로(실측: <C-n> 후 mode="n", visual=false) 커서 블록이 한 글자만
  -- 덮어 "단어가 아니라 한 글자만 잡힌 것"처럼 보이고, VM처럼 바로 c/d/y를 눌러
  -- 편집할 수도 없다(cw/ciw를 써야 했다).
  -- viw로 단어를 잡아 주면 VM과 같아진다.
  -- 실측: viw+match 3회 -> mode="v", 커서 3개, 그 상태에서 cXYZ -> 3줄 모두 치환.
  --
  -- 커서가 비-키워드 문자(;, 공백 등) 위면 viw가 그 문자열을 잡으므로
  -- 그 문자 기준으로 매칭된다(기존에는 한 글자만 매칭됐다).
  ---@param dir -1|1
  local function match_with_word(dir)
    if vim.api.nvim_get_mode().mode == "n" then
      -- 빈 줄 등에서 viw가 실패할 수 있으므로 실패해도 계속 진행한다.
      -- vim.cmd는 __call 테이블이라 pcall에 직접 넘기면 타입이 안 맞는다.
      pcall(function()
        vim.cmd("normal! viw")
      end)
    end
    mc.matchAddCursor(dir)
  end

  -- 주 진입점 (VM Find Under)
  set({ "n", "x" }, "<C-n>", function()
    match_with_word(1)
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

  -- 대소문자: match* 계열은 검색식에 \C를 강제로 넣어 **항상 대소문자를 구분**한다
  -- (multicursor-nvim/examples.lua:641,655,657,741,743 — 옵션으로 끌 수 없다).
  -- 구 VM은 VM_case_setting = "smart"였으므로 이 부분은 동작이 다르다.
  -- 실측: "foo/Foo/foo/FOO"에서 matchAllAddCursors -> 커서 2개(구분),
  --       searchAllAddCursors -> 4개(ignorecase/smartcase 반영).
  -- 이름 바꾸기 용도로는 대소문자 구분이 안전해 기본 키는 match* 그대로 두고,
  -- smart-case가 필요할 때 쓰라고 검색 기반 경로를 따로 둔다(/패턴 입력 후 사용).
  set({ "n", "x" }, "<leader>m/", mc.searchAllAddCursors, d("검색 결과 전체에 커서 (smartcase)"))
  set({ "n", "x" }, "<leader>mj", function()
    mc.searchAddCursor(1)
  end, d("다음 검색 결과에 커서 (smartcase)"))

  -- 건너뛰기 / 역방향 (VM에는 없던 기능이지만 matchAddCursor의 짝이라 함께 둔다)
  set({ "n", "x" }, "<leader>mn", function()
    mc.matchSkipCursor(1)
  end, d("다음 일치 건너뛰기"))
  set({ "n", "x" }, "<leader>mN", function()
    match_with_word(-1)
  end, d("이전 일치에 커서 추가"))

  -- 마우스 (기존 VM_mouse_mappings = 1 대응)
  set("n", "<C-LeftMouse>", mc.handleMouse, d("클릭 위치에 커서 추가"))
  set("n", "<C-LeftDrag>", mc.handleMouseDrag, d("드래그로 커서 추가"))
  set("n", "<C-LeftRelease>", mc.handleMouseRelease, d("드래그 종료"))

  -- 커서 일시 비활성/재활성
  set({ "n", "x" }, "<C-q>", mc.toggleCursor, d("커서 토글"))

  -- 아래 매핑은 커서가 여러 개일 때만 적용된다(layer). 평소 키를 가리지 않는다.
  mc.addKeymapLayer(function(layer)
    -- 주 커서 이동.
    -- <S-Left>/<S-Right>는 쓰지 않는다: VM에서 그 키가 "선택 영역 확장/축소"였기
    -- 때문에 같은 상황(커서 여러 개)에서 정반대 의미로 재사용하면 손이 헷갈린다.
    -- <Left>/<Right>도 keys.lua의 창 크기 조절이라 피한다.
    layer({ "n", "x" }, "<leader>m[", mc.prevCursor, d("이전 커서로"))
    layer({ "n", "x" }, "<leader>m]", mc.nextCursor, d("다음 커서로"))
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
