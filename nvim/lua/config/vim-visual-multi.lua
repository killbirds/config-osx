-- vim-visual-multi 설정
local M = {}

function M.setup()
  -- 기본 설정
  vim.g.VM_theme = "iceblue"              -- 멀티 커서 테마
  vim.g.VM_highlight_matches = "underline" -- 일치하는 항목 강조 표시 방법
  vim.g.VM_show_warnings = 1              -- 경고 메시지 표시
  vim.g.VM_silent_exit = 0                -- 종료 시 메시지 표시

  -- 키 매핑 설정
  vim.g.VM_maps = {
    -- 기본 매핑
    ["Find Under"] = "<C-n>",       -- 커서 아래 단어 선택 및 다음 일치 항목 찾기
    ["Find Subword Under"] = "<C-n>", -- 커서 아래 부분 단어 선택
    ["Select All"] = "<C-a>",       -- 모든 일치 항목 선택
    ["Select Cursor Down"] = "<C-j>", -- 아래에 커서 추가
    ["Select Cursor Up"] = "<C-k>", -- 위에 커서 추가

    -- 추가 매핑
    ["Add Cursor At Pos"] = "<C-x>", -- 현재 위치에 커서 추가
    ["Visual All"] = "<C-a>",      -- 비주얼 모드에서 모든 일치 항목 선택
    ["Visual Find"] = "<C-f>",     -- 비주얼 모드에서 선택 항목 찾기
    ["Visual Add"] = "<C-d>",      -- 비주얼 모드에서 선택 항목 추가

    -- 이동 및 편집
    ["Move Left"] = "<C-h>", -- 모든 커서를 왼쪽으로 이동
    ["Move Right"] = "<C-l>", -- 모든 커서를 오른쪽으로 이동
    ["Undo"] = "u",         -- 실행 취소
    ["Redo"] = "<C-r>",     -- 다시 실행

    -- 선택 확장/축소
    ["Extend Forward"] = "<S-Right>", -- 선택 영역 앞으로 확장
    ["Extend Backward"] = "<S-Left>", -- 선택 영역 뒤로 확장
  }

  -- 추가 설정
  vim.g.VM_mouse_mappings = 1    -- 마우스 매핑 활성화
  vim.g.VM_skip_empty_lines = 1  -- 빈 줄 건너뛰기
  vim.g.VM_case_setting = "smart" -- 대소문자 구분 설정 (smart, sensitive, ignore)
end

return M
