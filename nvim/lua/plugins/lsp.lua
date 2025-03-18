return {
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
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("config.mason-tool-installer")
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

	-- LSP 진행 상태 표시
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		config = function()
			require("config.fidget")
		end,
	},

	-- 린트 및 포맷팅
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
}
