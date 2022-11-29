local actions = require("telescope.actions")
require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<C-h>"] = "which_key",
        ["<C-j>"] = {
          actions.move_selection_next, type = "action",
          opts = { nowait = true, silent = true }
        },
        ["<C-k>"] = {
          actions.move_selection_previous, type = "action",
          opts = { nowait = true, silent = true }
        },
        ["<C-o>"] = {
          actions.select_default, type = "action",
          opts = { nowait = true, silent = true }
        },
      },
    },
  },
  pickers = {
    find_files = {
      -- theme = "dropdown",
      -- find_command = { "ag", "-l", "--nocolor", "--hidden", "-g", "" },
    },
  },
})

