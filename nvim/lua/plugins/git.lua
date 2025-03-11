return {
	-- Git
	"tpope/vim-fugitive",
	{ "rbong/vim-flog", dependencies = "tpope/vim-fugitive" },
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("config.gitsigns")
		end,
	},
}

