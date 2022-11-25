local actions = require("telescope.actions")
require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<C-h>"] = "which_key"
      },
    },
  },
  pickers = {
    find_files = {
      find_command = { "ag", "-l", "--nocolor", "--hidden", "-g", "" },
    },
  },
})
