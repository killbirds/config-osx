return {
  -- Theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      -- LSP 진단 스타일은 integrations.native_lsp가 아니라 최상위 lsp_styles다.
      -- (integrations 아래에 두면 해당 integration 모듈이 없어 조용히 무시됨)
      lsp_styles = {
        underlines = {
          errors = { "undercurl" },
          hints = { "undercurl" },
          warnings = { "undercurl" },
          information = { "undercurl" },
        },
      },
      -- nvim-tree의 git 상태 색. catppuccin의 nvim-tree 통합은 Dirty·New·Deleted만 정하므로
      -- 여섯 가지를 팔레트 색으로 직접 정한다(변경=노랑, 스테이징=초록, 충돌=파랑, 이름 변경=주황,
      -- 새 파일=회색, 삭제=빨강 — 예전에 config/nvim-tree.lua가 Flat UI 색으로 주던 구분 그대로).
      -- nvim-tree는 이 옛 이름의 그룹이 있으면 새 이름(NvimTreeGit*Icon / *HL)을 여기에 링크한다.
      custom_highlights = function(colors)
        return {
          NvimTreeGitDirty = { fg = colors.yellow },
          NvimTreeGitStaged = { fg = colors.green },
          NvimTreeGitMerge = { fg = colors.blue },
          NvimTreeGitRenamed = { fg = colors.peach },
          NvimTreeGitNew = { fg = colors.overlay2 },
          NvimTreeGitDeleted = { fg = colors.red },
        }
      end,
      -- auto_integrations가 기본 활성이라 설치된 플러그인은 자동 감지된다.
      -- 여기에는 명시적으로 끄거나 옵션을 주는 항목만 남긴다.
      integrations = {
        notify = false,
        neotree = false,
        indent_blankline = {
          enabled = true,
          scope_color = "lavender",
          colored_indent_levels = false,
        },
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd([[colorscheme catppuccin]])
    end,
  },
}
