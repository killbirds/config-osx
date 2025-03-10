return {
	-- Theme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			-- load the colorscheme here
			vim.cmd([[colorscheme catppuccin]])
		end,
	},

	"tpope/vim-sensible",
	"kylechui/nvim-surround",
	{
		"numToStr/Comment.nvim",
		config = function()
			require("config.comment")
		end,
	},

	{
		"alexghergh/nvim-tmux-navigation",
		config = function()
			require("config.nvim-tmux-navigation")
		end,
	},
	{
		"mg979/vim-visual-multi",
		branch = "master",
		config = function()
			require("config.vim-visual-multi").setup()
		end,
	},
	{
		"mfussenegger/nvim-lint",
		config = function()
			require("config.nvim-lint")
		end,
	},
	{
		"stevearc/conform.nvim",
		config = function()
			require("config.conform")
		end,
	},

	-- nvim-cmp & LSP
	"L3MON4D3/LuaSnip",
	"saadparwaiz1/cmp_luasnip",
	"onsails/lspkind-nvim",
	{
		"hrsh7th/nvim-cmp",
		config = function()
			require("config.nvim-cmp")
		end,
	},
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-nvim-lua",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-cmdline",
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("config.nvim-lspconfig")
		end,
	},
	{
		"scalameta/nvim-metals",
		dependencies = "nvim-lua/plenary.nvim",
		config = function()
			require("config.nvim-metals")
		end,
	},

	-- Mason
	{
		"williamboman/mason.nvim",
		config = function()
			require("config.mason")
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("config.mason-lspconfig")
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("config.nvim-treesitter")
		end,
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-fzf-native.nvim" },
		config = function()
			require("config.telescope")
		end,
	},
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

	-- Statusline & UI
	"nvim-tree/nvim-web-devicons",
	{
		"nvim-lualine/lualine.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("config.lualine")
		end,
	},
	{
		"akinsho/bufferline.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("config.bufferline")
		end,
	},
	{
		"famiu/bufdelete.nvim",
		config = function()
			require("config.bufdelete")
		end,
	},

	-- File Explorer
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("config.nvim-tree")
		end,
	},

	-- Git
	"tpope/vim-fugitive",
	{ "rbong/vim-flog", dependencies = "tpope/vim-fugitive" },
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("config.gitsigns")
		end,
	},

	-- Miscellaneous
	"tpope/vim-repeat",

	-- LSP 진행 상태 표시
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		config = function()
			require("config.fidget")
		end,
	},

	-- 추가 플러그인

	-- 인덴트 가이드
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
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

	-- 코드 액션 메뉴
	{
		"weilbith/nvim-code-action-menu",
		cmd = "CodeActionMenu",
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

	-- 프로젝트 관리
	{
		"ahmedkhalf/project.nvim",
		config = function()
			require("project_nvim").setup({
				detection_methods = { "pattern" },
				patterns = { ".git", "Makefile", "package.json" },
				show_hidden = false,
			})
			require("telescope").load_extension("projects")
		end,
	},
}
