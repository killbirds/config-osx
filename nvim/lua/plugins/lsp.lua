return {
  -- 자동완성 & LSP
  {
    "saghen/blink.cmp",
    -- v2(main)는 breaking change가 진행 중이고 blink.lib 의존이 추가되므로 v1에 고정한다.
    version = "1.*",
    -- prebuilt 바이너리를 GitHub에서 내려받는 대신 로컬 cargo로 빌드한다.
    -- (사내망에서 release 다운로드가 막혀도 동작하고, 결과가 결정적이다)
    build = "cargo build --release",
    dependencies = { "rafamadriz/friendly-snippets" },
    -- 지연 로딩 주의사항:
    -- blink의 plugin/blink-cmp.lua가 vim.lsp.config("*", { capabilities = ... })를
    -- 자동 등록한다. 이게 LSP 클라이언트가 뜨기 전에 실행되지 않으면 서버가
    -- snippetSupport / resolveSupport / labelDetails를 모르는 상태로 initialize된다.
    --
    -- 그래서 InsertEnter만으로는 늦다. 대신 config/lsp-capabilities.lua가
    -- require("blink.cmp")를 호출하고, 그 파일은 nvim-lspconfig(event = BufReadPre)가
    -- 로드한다. lazy.nvim의 require 훅이 이때 blink을 끌어올리므로 클라이언트 시작 전에
    -- capabilities 등록이 끝난다.
    --
    -- 이 방식이 lazy = false보다 나은 점: 파일 인자 없이 nvim만 띄우는 경우
    -- blink을 로드하지 않아 startup이 이전 그대로다.
    -- (12회 측정 median: 이 방식 24.4ms / lazy = false 36ms / 이전 nvim-cmp 26ms)
    event = { "InsertEnter", "CmdlineEnter" },
    opts = function()
      return require("config.blink-cmp")
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
    -- plenary 의존은 제거함: nvim-metals 소스에 plenary 참조가 0건이다.
    -- (telescope가 유일한 실사용처였고 함께 제거됨)
    ft = { "scala", "sbt", "java" },
    cmd = { "MetalsStart" },
    config = function()
      require("config.nvim-metals")
    end,
  },

  -- Mason (저장소가 williamboman → mason-org 조직으로 이관됨)
  {
    "mason-org/mason.nvim",
    -- 트리거가 없으면 startup에 로드된다. 아래 mason-lspconfig가 BufReadPre에
    -- dependency로 끌어올리므로 파일을 열 때는 어차피 로드되고,
    -- 파일 인자 없이 nvim만 띄우는 경우에만 로드를 건너뛴다.
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog", "MasonUpdate" },
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
          -- 이전 코드는 range = { line("'<"), line("'>") } 평평한 배열을 넘겼는데
          -- conform의 계약은 { start = {row,col}, ["end"] = {row,col} }이라
          -- "attempt to index field 'start' (a nil value)"로 실패했다.
          -- range 구성은 config/conform.lua가 담당한다 (conform 자체의 암시적
          -- visual 감지는 마지막 행을 놓치므로 쓰지 않는다).
          require("config.conform").format_visual()
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
