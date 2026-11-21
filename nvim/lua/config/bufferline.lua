-- 투명 배경(plugins/theme.lua의 transparent_background)에서도 탭 바 색을 유지한다.
--
-- bufferline은 바·비활성 탭·구분선 색을 전부 Normal의 배경을 어둡게 해서 만든다
-- (bufferline/config.lua의 derive_colors: -45 / -25 / -8). Normal에 배경이 없으면 그 값이
-- 모두 NONE이 되고, slant 구분선은 "fg = 바 색, bg = 탭 색"으로 사선을 그리는 글리프라서
-- fg가 비면 Normal의 글자색으로 칠해진다. 탭 사이에 흰 삼각형이 뜨던 이유다.
-- (실측: 투명일 때 BufferLineSeparator fg/bg가 둘 다 없음, 불투명일 때 #101019 / #161622)
--
-- 그래서 Normal 배경 대신 화면에 실제로 깔리는 배경색을 기준으로 같은 계산을 해 준다.
-- 선택된 탭만 배경을 비워 편집 영역과 이어지게 한다.
--   - Herdr 터미널 안: Herdr 테마의 배경색(config/herdr.lua). 그 안에서는 편집 영역이 Herdr
--     pane 색이라, catppuccin 기준으로 칠하면 탭 바만 다른 색조로 남는다(실측: 바 #101019,
--     pane #14141c). Herdr 테마를 바꾸면 config/herdr.lua가 다시 칠하게 한다.
--   - 그 밖: catppuccin의 base. 색은 투명 배경을 켜기 전과 같다.
-- ColorScheme이 바뀌면 bufferline이 이 함수를 다시 부른다(config.update_highlights).
local function highlights(defaults)
  if vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg then
    return {} -- Normal에 배경이 있으면 bufferline이 직접 계산한다
  end
  local base = require("config.herdr").background()
  if not base then
    local ok, palettes = pcall(require, "catppuccin.palettes")
    if not ok then
      return {}
    end
    base = palettes.get_palette().base
  end

  local shade = require("bufferline.colors").shade_color
  local fill, inactive, visible = shade(base, -45), shade(base, -25), shade(base, -8)

  local hl = {}
  for name in pairs(defaults.highlights) do
    local bg = inactive
    if name:find("_selected$") then
      bg = "NONE"
    elseif name:find("_visible$") then
      bg = visible
    end
    hl[name] = { bg = bg }
  end

  -- 바 자체의 색을 배경으로 쓰는 그룹
  for _, name in ipairs({ "fill", "group_separator", "trunc_marker", "offset_separator" }) do
    hl[name].bg = fill
  end
  -- 바 색을 글자색으로 쓰는 그룹 (사선 구분선이 여기에 해당한다)
  for _, name in ipairs({
    "separator",
    "separator_visible",
    "separator_selected",
    "tab_separator",
    "tab_separator_selected",
  }) do
    hl[name].fg = fill
  end
  hl.group_label = { fg = fill } -- 배경은 bufferline 기본값(주석 색) 그대로
  hl.indicator_visible.fg = visible
  return hl
end

require("bufferline").setup({
  highlights = highlights,
  options = {
    mode = "buffers", -- 버퍼 모드 (기본값, 탭 대신 버퍼 표시)
    numbers = "none", -- 버퍼 번호 표시 안 함
    -- :Bdelete(config/bufdelete.lua, mini.bufremove) 사용 (창 레이아웃 유지).
    -- bang 없이 실행해 수정된 버퍼는 경고 없이 날아가지 않도록 한다.
    close_command = "Bdelete %d",
    right_mouse_command = "Bdelete %d", -- 우클릭으로 버퍼 삭제
    left_mouse_command = "buffer %d", -- 좌클릭으로 버퍼 이동
    middle_mouse_command = "Bdelete %d", -- 중클릭으로 버퍼 삭제
    indicator = {
      style = "icon", -- 활성 버퍼를 아이콘으로 표시
      icon = "▎", -- 커스텀 인디케이터 아이콘 (심플한 수직선)
    },
    max_name_length = 18, -- 파일명 최대 길이 제한
    max_prefix_length = 15, -- 접두사 최대 길이 제한
    truncate_names = false, -- 이름 잘림 비활성화 (긴 이름 표시)
    tab_size = 10, -- 탭 크기 설정 (컴팩트하게)
    diagnostics = "nvim_lsp", -- LSP 기반 진단 정보 표시
    diagnostics_update_in_insert = false, -- 삽입 모드에서 진단 업데이트 비활성화 (성능 최적화)
    custom_filter = function(bufnr)
      -- 표시하지 않을 파일 타입 필터링
      -- ("text"를 넣으면 .txt 파일이 버퍼라인에서 사라지므로 제외하지 않는다)
      local exclude_ft = { "qf", "fugitive", "git", "help" }
      local cur_ft = vim.bo[bufnr].filetype
      return not vim.tbl_contains(exclude_ft, cur_ft)
    end,
    get_element_icon = function(element)
      -- 파일 타입에 따른 아이콘 설정 (nvim-web-devicons 사용)
      local icon, hl = require("nvim-web-devicons").get_icon_by_filetype(element.filetype, { default = true })
      return icon or "", hl -- 기본 아이콘 추가
    end,
    show_buffer_icons = true, -- 버퍼 아이콘 표시
    show_buffer_close_icons = true, -- 버퍼 닫기 아이콘 표시
    show_close_icon = true, -- 전체 닫기 아이콘 표시
    show_tab_indicators = true, -- 탭 인디케이터 표시
    persist_buffer_sort = true, -- 버퍼 정렬 상태 유지
    separator_style = "slant", -- 구분선 스타일 (slant로 시각적 구분 강화)
    enforce_regular_tabs = false, -- 탭 크기 강제 비활성화
    always_show_bufferline = true, -- 버퍼라인이 항상 표시되도록 설정
    hover = {
      enabled = true, -- 마우스 호버 효과 활성화
      delay = 200, -- 호버 반응 지연 시간 (ms)
      reveal = { "close" }, -- 호버 시 닫기 버튼 표시
    },
    sort_by = "insert_after_current", -- 새 버퍼를 현재 버퍼 뒤에 추가
    offsets = { -- 특정 파일 타입에 대한 오프셋 설정 (예: 파일 탐색기)
      {
        filetype = "NvimTree",
        text = "File Explorer",
        highlight = "Directory",
        text_align = "left",
      },
    },
  },
})
