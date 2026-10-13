return {
  -- Statusline & UI
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    config = function()
      require("config.lualine")
    end,
  },
  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    config = function()
      require("config.bufferline")
    end,
  },
  {
    -- bufdelete.nvim(archive됨, 마지막 커밋 2024-02)을 대체한다. 창 배치를 유지한 채 버퍼를 지운다.
    "nvim-mini/mini.bufremove",
    version = "*",
    cmd = { "Bdelete", "Bwipeout" },
    keys = {
      {
        "<C-c>",
        function()
          require("config.bufdelete").smart_bufdelete()
        end,
        silent = true,
        desc = "Delete current buffer unless it is protected",
      },
    },
    config = function()
      require("config.bufdelete").setup()
    end,
  },

  -- 인덴트 가이드
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- Trouble.nvim for diagnostics, references, etc.
  {
    "folke/trouble.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    cmd = { "Trouble" },
    config = function()
      require("config.trouble")
    end,
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "진단 목록 표시" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "현재 버퍼 진단 목록" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "로케이션 리스트" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "퀵픽스 리스트" },
      { "<leader>xl", "<cmd>Trouble lsp toggle<cr>", desc = "LSP 참조/정의/구현" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "문서 심볼" },
    },
  },
}
