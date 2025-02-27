local actions = require("telescope.actions")
local telescope = require("telescope")
telescope.setup({
	defaults = {
		mappings = {
			i = {
				["<esc>"] = actions.close,
				["<C-h>"] = "which_key",
				["<C-j>"] = {
					actions.move_selection_next,
					type = "action",
					opts = { nowait = true, silent = true },
				},
				["<C-k>"] = {
					actions.move_selection_previous,
					type = "action",
					opts = { nowait = true, silent = true },
				},
				["<C-o>"] = {
					actions.select_default,
					type = "action",
					opts = { nowait = true, silent = true },
				},
			},
		},
	},
	pickers = {
		find_files = {
			-- theme = "dropdown",
			-- find_command = { "ag", "-l", "--nocolor", "--hidden", "-g", "" },
		},
		buffers = {
			sort_mru = true,
			ignore_current_buffer = true,
		},
	},
})

telescope.load_extension("fzf")

vim.keymap.set("n", "<C-p>", "<cmd>Telescope find_files<cr>", { silent = true })
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { silent = true })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { silent = true })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { silent = true })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { silent = true })
