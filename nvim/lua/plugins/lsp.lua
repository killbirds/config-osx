return {
  -- nvim-cmp & LSP
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind-nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
    },
    config = function()
      require("config.nvim-cmp")
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("config.nvim-lspconfig")
    end,
  },
  {
    "scalameta/nvim-metals",
    dependencies = "nvim-lua/plenary.nvim",
    ft = { "scala", "sbt", "java" },
    config = function()
      require("config.nvim-metals")
    end,
  },

  -- Mason
  {
    "williamboman/mason.nvim",
    config = function()
      require("config.mason")
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("config.mason-lspconfig")
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsClean" },
    config = function()
      require("config.mason-tool-installer")
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("config.nvim-treesitter")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = false,
    config = function()
      require("config.nvim-treesitter-textobjects").setup()
    end,
  },

  -- LSP 진행 상태 표시
  {
    "j-hui/fidget.nvim",
    -- tag = "v1.2.0",
    event = "LspAttach",
    config = function(_, opts)
      require("fidget").setup(opts)

      -- Fidget's health check still warns about implicit nvim-tree integration
      -- even when notification.window.avoid already includes "NvimTree".
      require("fidget.integration.nvim-tree").options.enable = false
    end,
    opts = {
      progress = {
        poll_rate = 0,
        suppress_on_insert = true,
        ignore_done_already = true,
        ignore_empty_message = true,
        display = {
          render_limit = 5,
          done_ttl = 2,
          done_icon = "✓",
          done_style = "Constant",
          progress_icon = { "dots_bounce", rate = 0.5 },
          progress_style = "WarningMsg",
          group_style = "Title",
          icon_style = "Question",
          priority = 40,
          skip_history = true,
        },
      },
      notification = {
        poll_rate = 10,
        filter = vim.log.levels.WARN,
        override_vim_notify = false,
        window = {
          winblend = 0,
          border = "rounded",
          zindex = 45,
          max_width = 0,
          max_height = 0,
          x_padding = 1,
          y_padding = 0,
          align = "bottom",
          relative = "editor",
          avoid = { "NvimTree" },
        },
      },
      logger = {
        level = vim.log.levels.WARN,
        float_precision = 0.01,
        path = string.format("%s/fidget.nvim.log", vim.fn.stdpath("cache")),
      },
    },
  },

  -- 린트 및 포맷팅
  {
    "stevearc/conform.nvim",
    -- tag = "v5.5.1", -- 특정 태그 사용 권장
    event = { "BufWritePre" }, -- 저장 시 포맷팅을 위한 트리거
    cmd = { "ConformInfo" },   -- lazy 로딩 최적화
    -- opts 테이블 삭제
    -- config 함수 복원
    config = function()
      require("config.conform")
    end,
    -- 기존 0.11 최적화 설정 (필요시 config/conform.lua 내부에서 관리)
    -- opts = { ... }
  },
}
