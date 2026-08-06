-- lualine은 M = { setup = setup, ... } 형태로 테이블을 통째로 만들어 반환해서
-- lua_ls가 setup 필드를 정적으로 못 본다(undefined-field). 런타임에는 존재하고
-- statusline도 정상 설정됨을 확인했다.
---@diagnostic disable-next-line: undefined-field
require("lualine").setup({
  options = {
    icons_enabled = true,
    theme = "catppuccin-nvim",
    component_separators = { left = "", right = "" }, -- 좀 더 눈에 띄는 구분자 설정
    section_separators = { left = "", right = "" },
    disabled_filetypes = { "Lazy", "NvimTree" },
    always_divide_middle = true,
    globalstatus = true, -- 모든 창에서 동일한 상태줄 사용
    refresh = { -- 상태줄 갱신 주기 (성능 최적화)
      statusline = 5000, -- 5초마다 갱신
      tabline = 5000,
      winbar = 5000,
    },
  },
  sections = {
    lualine_a = {
      {
        "mode",
        fmt = function(str)
          return str:sub(1, 1)
        end,
      }, -- 모드 첫 글자만 표시 (간결하게)
    },
    lualine_b = {
      { "branch", icon = "" }, -- Git 브랜치에 아이콘 추가
      {
        "diff",
        -- gitsigns가 이미 계산해 둔 diff를 재사용한다.
        -- lualine의 source는 **함수만** 받는다 (lualine/components/diff/git_diff.lua:22가
        -- type(opts.source) == "function"일 때만 채택). 이전의 source = { "gitsigns" }는
        -- table이라 조용히 무시됐고, lualine이 자체 git 프로세스를 돌리고 있었다.
        source = function()
          local gs = vim.b.gitsigns_status_dict
          if not gs then
            return nil -- gitsigns 정보가 없으면 lualine 기본 경로로 폴백
          end
          return { added = gs.added, modified = gs.changed, removed = gs.removed }
        end,
        symbols = { added = "+", modified = "~", removed = "-" }, -- 심플한 diff 심볼
        diff_color = {
          added = { fg = "#98c379" }, -- 색상 커스터마이징 (catppuccin과 조화)
          modified = { fg = "#e5c07b" },
          removed = { fg = "#e06c75" },
        },
      },
    },
    lualine_c = {
      {
        "filename",
        path = 1, -- 상대 경로 표시 (0: 파일명만, 1: 상대경로, 2: 절대경로)
        shorting_target = 50, -- 경로 단축 목표 길이 (조정 가능)
        symbols = {
          modified = "[+]", -- 수정된 파일 표시
          readonly = "[-]", -- 읽기 전용 표시
          unnamed = "[No Name]", -- 이름 없는 버퍼 표시
        },
      },
      {
        "diagnostics",
        sources = { "nvim_lsp" },
        sections = { "error", "warn", "info", "hint" },
        symbols = { error = "✘ ", warn = "▲ ", info = "● ", hint = "◆ " },
        colored = true,
        update_in_insert = false,
        always_visible = false,
      }, -- LSP 진단 (중복 방지를 위해 통합)
    },
    lualine_x = {
      -- 진단 개수는 lualine_c의 diagnostics 컴포넌트가 표시하므로 여기서 중복 표시하지 않는다
      { "filetype", icon_only = false, colored = true }, -- 파일 타입과 아이콘 함께 표시
    },
    lualine_y = {
      { "encoding", show_bom = false }, -- BOM 표시 비활성화
      { "fileformat", icons_enabled = true }, -- 파일 형식 (예: unix, dos)
    },
    lualine_z = {
      { "progress", padding = { left = 1, right = 0 } }, -- 진행률 표시 (패딩 조정)
      { "location", padding = { left = 1, right = 1 } }, -- 줄/열 위치
    },
  },
  tabline = { -- 탭라인 활성화 (선택적)
  },
  extensions = { "fugitive", "nvim-tree", "quickfix", "lazy" }, -- 확장 추가 (lazy.nvim 지원)
})
