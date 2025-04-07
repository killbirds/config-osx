local actions = require("telescope.actions")
local telescope = require("telescope")
local open_with_trouble = require("trouble.sources.telescope").open

telescope.setup({
	defaults = {
		file_ignore_patterns = { "node_modules", ".git", "yarn.lock", ".cache" },
		mappings = {
			i = {
				["<esc>"] = actions.close,
				["<C-h>"] = actions.which_key,
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
				["<C-o>"] = actions.select_default,
				["<C-t>"] = open_with_trouble,
				["<C-n>"] = actions.cycle_history_next,
				["<C-p>"] = actions.cycle_history_prev,
			},
			n = {
				["<C-t>"] = open_with_trouble,
			},
		},
		history = {
			path = vim.fn.stdpath("data") .. "/telescope_history.sqlite3",
			limit = 100,
		},
		cache_picker = {
			num_pickers = 10,
			limit = 100,
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
		live_grep = {
			-- 기본 설정 유지
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

-- Load smart-history extension
telescope.load_extension("smart_history")

-- Load projects
telescope.load_extension("projects")

-- Key mappings for Telescope
local telescope_mappings = {
	["<C-p>"] = "<cmd>Telescope find_files<cr>",
	["<leader>ff"] = "<cmd>Telescope find_files<cr>",
	["<leader>fg"] = "<cmd>Telescope live_grep<cr>",
	["<leader>fb"] = "<cmd>Telescope buffers<cr>",
	["<leader>fp"] = "<cmd>Telescope projects<cr>",
	["<leader>fh"] = "<cmd>Telescope help_tags<cr>",
	[",ag"] = "<cmd>Telescope live_grep<cr>",
	-- 이전 피커/검색 결과 다시 열기
	["<leader>fr"] = "<cmd>Telescope resume<cr>",
	-- 이전 피커 목록 보기
	["<leader>fP"] = "<cmd>Telescope pickers<cr>",
}

-- Set key mappings in normal mode
for key, cmd in pairs(telescope_mappings) do
	vim.keymap.set("n", key, cmd, { silent = true })
end

vim.keymap.set("n", "<leader>ag", function()
	local current_word = vim.fn.expand("<cword>")
	require("telescope.builtin").live_grep({ default_text = current_word })
end, { desc = "Search for selected word" })
