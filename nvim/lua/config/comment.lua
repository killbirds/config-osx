require("Comment").setup({
	padding = true, -- Add spaces after comment delimiters
	sticky = true, -- Keep cursor position after commenting
	ignore = nil, -- Ignore lines that match a pattern
	toggler = {
		line = "<leader>/", -- Toggle line comment
		block = "<leader>?", -- Toggle block comment
	},
	opleader = {
		line = "<leader>/",
		block = "<leader>?",
	},
	extra = {
		above = "<leader>O", -- Add comment on the line above
		below = "<leader>o", -- Add comment on the line below
		eol = "<leader>A", -- Add comment at the end of the line
	},
	mappings = {
		basic = true,
		extra = true,
	},
})
