local actions = require("telescope.actions")
local telescope = require("telescope")

telescope.setup({
	defaults = {
		file_ignore_patterns = { "node_modules", ".git" },
		mappings = {
			i = {
				["<esc>"] = actions.close,
				["<C-h>"] = "which_key",
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
				["<C-o>"] = actions.select_default,
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

-- Load fzf extension
telescope.load_extension("fzf")

-- Key mappings for Telescope
local telescope_mappings = {
	["<C-p>"] = "<cmd>Telescope find_files<cr>",
	["<leader>ff"] = "<cmd>Telescope find_files<cr>",
	["<leader>fg"] = "<cmd>Telescope live_grep<cr>",
	["<leader>fb"] = "<cmd>Telescope buffers<cr>",
	["<leader>fh"] = "<cmd>Telescope help_tags<cr>",
}

-- Set key mappings in normal mode
for key, cmd in pairs(telescope_mappings) do
	vim.keymap.set("n", key, cmd, { silent = true })
end
