local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- Theme
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },

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
	{ "mg979/vim-visual-multi", branch = "master" },
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
	{
		"echasnovski/mini.files",
		config = function()
			require("config.mini-files")
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
})
