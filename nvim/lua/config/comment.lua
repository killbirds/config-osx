require("Comment").setup({
	padding = true, -- Add spaces after comment delimiters
	sticky = true, -- Keep cursor position after commenting
	ignore = nil, -- Ignore lines that match a pattern
	toggler = {
		line = "<leader>l", -- Toggle line comment
		block = "<leader>?", -- Toggle block comment
	},
	opleader = {
		line = "<leader>l",
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
	pre_hook = function(ctx)
		-- 한글 포함 텍스트에서도 정확한 주석 처리
		local U = require("Comment.utils")
		local type = ctx.ctype
		local text = ctx.ctext
		if #text > 0 and string.find(text, "[가-힣]") then
			if type == U.ctype.line then
				return string.rep(" ", #U.get_comment_start(ctx)) .. text
			elseif type == U.ctype.block then
				local cs = U.get_comment_start(ctx)
				local ce = U.get_comment_end(ctx)
				return string.format(" %s %s %s ", cs, text, ce)
			end
		end
	end,
})
