require("conform").setup({
	formatters_by_ft = {
		javascript = { "prettier" },
		typescript = { "prettier" },
		lua = { "stylua" },
		python = { "black" },
	},
	format_on_save = true,
})
