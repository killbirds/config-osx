return {
	-- 기본 편집 도구
	"tpope/vim-sensible",
	"kylechui/nvim-surround",
	{
		"numToStr/Comment.nvim",
		config = function()
			require("config.comment")
		end,
	},
	{
		"mg979/vim-visual-multi",
		branch = "master",
		config = function()
			require("config.vim-visual-multi").setup()
		end,
	},

	-- 자동 괄호 닫기
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},

	-- 하이라이트된 단어 모두 표시
	{
		"RRethy/vim-illuminate",
		config = function()
			require("illuminate").configure({
				providers = { "lsp", "treesitter", "regex" },
				delay = 100,
				filetypes_denylist = { "NvimTree", "Telescope" },
			})
		end,
	},

	-- im-select.nvim for Korean input method management
	{
		"keaising/im-select.nvim",
		config = function()
			require("config.im-select")
		end,
	},

	-- 터미널 통합
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		opts = {
			open_mapping = [[<c-\>]],
			direction = "float",
			float_opts = {
				border = "curved",
			},
		},
	},
}
