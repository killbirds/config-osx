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

  -- Fuzzy finder (telescope 대체)
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    keys = {
      { "<C-p>", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Find buffers" },
      { "<leader>fh", "<cmd>FzfLua helptags<cr>", desc = "Help tags" },
      { ",ag", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
      { "<leader>fr", "<cmd>FzfLua resume<cr>", desc = "Resume last picker" },
      { "<leader>fP", "<cmd>FzfLua builtin<cr>", desc = "FzfLua pickers" },
      { "<leader>ag", "<cmd>FzfLua grep_cword<cr>", desc = "Search word under cursor" },
      { "<leader>ag", "<cmd>FzfLua grep_visual<cr>", mode = "v", desc = "Search selection" },
    },
    config = function()
      require("config.fzf-lua")
    end,
  },
}
