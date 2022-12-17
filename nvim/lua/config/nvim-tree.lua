require("nvim-tree").setup({
  sort_by = "name",
  update_cwd = false,
  view = {
    adaptive_size = true,
    mappings = {
      list = {
        { key = "u", action = "dir_up" },
        { key = "<C-r>", action = "refresh" },
      },
    },
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
    custom = { 'node_modules' }
  },
  actions = {
    change_dir = {
      restrict_above_cwd = true
    },
    open_file = {
      quit_on_open = false,
      window_picker = {
        enable = false
      }
    }
  }
})

local api = require("nvim-tree.api")

vim.keymap.set("n", "<F2>", function()
  return api.tree.toggle(true, true)
end, { silent = true, desc = "toggle nvim-tree" })

vim.keymap.set("n", "<F3>", function()
  return vim.cmd [[NvimTreeFindFile]]
end, { silent = true, desc = "find_file nvim-tree" })

