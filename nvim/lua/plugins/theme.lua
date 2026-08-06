return {
  -- Theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = false,
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
      -- auto_integrations가 기본 활성이라 설치된 플러그인은 자동 감지된다.
      -- 여기에는 명시적으로 끄거나 옵션을 주는 항목만 남긴다.
      integrations = {
        notify = false,
        neotree = false,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
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
