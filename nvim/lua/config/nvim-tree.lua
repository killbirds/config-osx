-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
  sort_by = "name",
  update_cwd = false,
  view = {
    adaptive_size = true,
    mappings = {
      list = {
        { key = "u", action = "dir_up" },
      },
    },
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
  actions = {
    open_file = {
      window_picker = {
        enable = false
      }
    }
  }
})

vim.keymap.set("n", "<F2>", function()
  return require("nvim-tree").toggle(true, true)
end, { silent = true, desc = "toggle nvim-tree" })

vim.keymap.set("n", "<F3>", function()
  return require("nvim-tree").find_file(true)
end, { silent = true, desc = "find_file nvim-tree" })

