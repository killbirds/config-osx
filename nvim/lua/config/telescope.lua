local actions = require("telescope.actions")
local telescope = require("telescope")

telescope.setup({
	defaults = {
		file_ignore_patterns = { "node_modules", ".git", "yarn.lock" },
		mappings = {
			i = {
				["<esc>"] = actions.close,
				["<C-h>"] = actions.which_key,
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
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({
				-- 추가 설정을 여기에 넣을 수 있습니다
				width = 0.8,
				previewer = false,
			}),
		},
	},
})

-- Load fzf extension
telescope.load_extension("fzf")

-- Load ui-select extension
telescope.load_extension("ui-select")

-- Key mappings for Telescope
local telescope_mappings = {
	["<C-p>"] = "<cmd>Telescope find_files<cr>",
	["<leader>ff"] = "<cmd>Telescope find_files<cr>",
	["<leader>fg"] = "<cmd>Telescope live_grep<cr>",
	["<leader>fb"] = "<cmd>Telescope buffers<cr>",
	["<leader>fh"] = "<cmd>Telescope help_tags<cr>",
	[",ag"] = "<cmd>Telescope live_grep<cr>",
}

-- Set key mappings in normal mode
for key, cmd in pairs(telescope_mappings) do
	vim.keymap.set("n", key, cmd, { silent = true })
end

vim.keymap.set("n", "<leader>ag", function()
	local current_word = vim.fn.expand("<cword>")
	require("telescope.builtin").live_grep({ default_text = current_word })
end, { desc = "Search for selected word" })
