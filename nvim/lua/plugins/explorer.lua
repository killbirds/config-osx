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
      {
        "<leader>ag",
        function()
          -- 기존 telescope live_grep({ default_text = cword })과 같은 의미:
          -- cword를 초기 쿼리로 넣지만 프롬프트를 고치면 rg를 다시 돌린다.
          -- FzfLua grep_cword는 opts.search로 M.grep(비-live)을 부르므로
          -- 최초 cword 결과 안에서 fuzzy filter만 되어 동작이 다르다.
          require("fzf-lua").live_grep({ search = vim.fn.expand("<cword>") })
        end,
        desc = "Live grep word under cursor",
      },
    },
    config = function()
      require("config.fzf-lua")
    end,
  },
}
