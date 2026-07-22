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
  -- Neovim 설정/플러그인 Lua 편집용 lua_ls 자동 구성
  -- 열린 파일의 require()를 감지해 해당 플러그인 경로만 lua_ls workspace에
  -- 지연 추가한다 (전체 플러그인 인덱싱 없이 vim.* / 플러그인 API 자동완성 제공)
  {
    "folke/lazydev.nvim",
    ft = "lua", -- lua 파일에서만 로드
    opts = {
      library = {
        -- vim.uv를 사용하는 파일에서 luv 타입 정의 로드
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
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

  -- Mason (저장소가 williamboman → mason-org 조직으로 이관됨)
  {
    "mason-org/mason.nvim",
    config = function()
      require("config.mason")
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("config.mason-lspconfig")
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
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
    -- 참고: 과거의 fidget.integration.nvim-tree 비활성화 핵은 최신 fidget에서
    -- 해당 모듈이 제거되어 오히려 에러를 냈으므로 삭제함.
    -- nvim-tree 회피는 notification.window.avoid 옵션이 담당한다.
    config = function(_, opts)
      require("fidget").setup(opts)
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
