return {
  -- File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeOpen", "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
    keys = {
      { "<F2>", "<cmd>NvimTreeToggle<CR>", desc = "toggle nvim-tree" },
      {
        "<F3>",
        function()
          require("nvim-tree.api").tree.find_file({ open = true, focus = true })
        end,
        desc = "find_file nvim-tree",
      },
      {
        "<leader>tr",
        function()
          require("nvim-tree.api").tree.reload()
        end,
        desc = "Reload nvim-tree",
      },
      {
        "<leader>tf",
        function()
          local view = require("nvim-tree.view")
          if view.is_visible() then
            view.focus()
          else
            require("nvim-tree.api").tree.open({ find_file = true })
          end
        end,
        desc = "Focus or Open nvim-tree with current file",
      },
    },
    dependencies = "nvim-tree/nvim-web-devicons",
    init = function()
      local group = vim.api.nvim_create_augroup("NvimTreeStartup", { clear = true })

      vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        callback = function(data)
          if data.file == "" or vim.fn.isdirectory(data.file) == 0 then
            return
          end

          vim.cmd.cd(data.file)
          vim.schedule(function()
            vim.cmd("NvimTreeOpen")
          end)
        end,
      })
    end,
    config = function()
      require("config.nvim-tree")
    end,
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
      { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Find projects" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { ",ag", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fr", "<cmd>Telescope resume<cr>", desc = "Resume Telescope" },
      { "<leader>fP", "<cmd>Telescope pickers<cr>", desc = "Telescope pickers" },
      {
        "<leader>ag",
        function()
          local current_word = vim.fn.expand("<cword>")
          require("telescope.builtin").live_grep({ default_text = current_word })
        end,
        desc = "Search for selected word",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      {
        "nvim-telescope/telescope-smart-history.nvim",
        dependencies = { "kkharji/sqlite.lua" },
      },
      "ahmedkhalf/project.nvim",
    },
    config = function()
      require("config.telescope")
    end,
  },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = true },

  -- 프로젝트 관리
  {
    "ahmedkhalf/project.nvim",
    lazy = true,
    config = function()
      require("project_nvim").setup({
        detection_methods = { "pattern", "lsp" }, -- LSP 기반 탐지 추가
        patterns = { ".git", "Makefile", "package.json", "Cargo.toml", "pyproject.toml", "build.gradle" },
        show_hidden = true,
        silent_chdir = true,
        scope_chdir = "global",
        datapath = vim.fn.stdpath("data"),
      })
    end,
  },
}
