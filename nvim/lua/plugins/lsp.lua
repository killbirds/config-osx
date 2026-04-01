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
    cmd = { "LspCleanup", "LspStatus", "LspRestart" },
    keys = {
      {
        "<leader>th",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          local filter = { bufnr = bufnr }
          local enabled = vim.lsp.inlay_hint.is_enabled(filter)
          vim.lsp.inlay_hint.enable(not enabled, filter)
        end,
        desc = "Toggle Inlay Hints",
      },
    },
    config = function()
      require("config.nvim-lspconfig")
    end,
  },
  {
    "scalameta/nvim-metals",
    dependencies = "nvim-lua/plenary.nvim",
    ft = { "scala", "sbt", "java" },
    cmd = { "MetalsStart" },
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
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "ConformInfo", "Format" },
    keys = {
      {
        "<leader>fmt",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "n",
        desc = "Format buffer",
      },
      {
        "<leader>fmt",
        function()
          require("conform").format({
            async = true,
            lsp_fallback = true,
            range = { vim.fn.line("'<"), vim.fn.line("'>") },
          })
        end,
        mode = "v",
        desc = "Format selected lines",
      },
    },
    config = function()
      require("config.conform")
    end,
  },
}
