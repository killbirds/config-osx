-- This file can be loaded by calling `lua require('plugins')` from your init.vim

local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
		vim.cmd([[packadd packer.nvim]])
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

return require("packer").startup(function(use)
	use("wbthomason/packer.nvim")

	-- Theme
	-- use 'lifepillar/vim-solarized8'
	-- use "rebelot/kanagawa.nvim"
	use({ "catppuccin/nvim", as = "catppuccin" })

	use("tpope/vim-sensible")
	use("kylechui/nvim-surround")

	use({ "numToStr/Comment.nvim", config = [[require('config.comment')]] })

	use({ "alexghergh/nvim-tmux-navigation", config = [[require('config.nvim-tmux-navigation')]] })

	use({ "mg979/vim-visual-multi", branch = "master" })

	use({
		"mfussenegger/nvim-lint",
		config = [[require('config.nvim-lint')]],
	})

	use({
		"stevearc/conform.nvim",
		config = [[require('config.conform')]],
	})

	-- nvim-cmp
	-- https://github.com/jdhao/nvim-config/blob/590baf4ca95f77418dc6beee80e9ad149cd585d4/lua/plugins.lua
	-- Snippet engine and snippet template
	use({ "L3MON4D3/LuaSnip" })
	use({ "saadparwaiz1/cmp_luasnip", after = { "nvim-cmp", "LuaSnip" } })

	-- auto-completion engine
	use({ "onsails/lspkind-nvim", event = "VimEnter" })
	use({ "hrsh7th/nvim-cmp", after = "lspkind-nvim", config = [[require('config.nvim-cmp')]] })

	-- nvim-cmp completion sources
	use({ "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp" })
	use({ "hrsh7th/cmp-nvim-lua", after = "nvim-cmp" })
	use({ "hrsh7th/cmp-path", after = "nvim-cmp" })
	use({ "hrsh7th/cmp-buffer", after = "nvim-cmp" })
	use({ "hrsh7th/cmp-cmdline", after = "nvim-cmp" })

	-- nvim-lsp configuration (it relies on cmp-nvim-lsp, so it should be loaded after cmp-nvim-lsp).
	use({ "neovim/nvim-lspconfig", after = "cmp-nvim-lsp", config = [[require('config.nvim-lspconfig')]] })

	-- scala metals
	use({
		"scalameta/nvim-metals",
		requires = { "nvim-lua/plenary.nvim" },
		after = "cmp-nvim-lsp",
		config = [[require('config.nvim-metals')]],
	})

	-- lsp package manager
	use({ "williamboman/mason.nvim", config = [[require('config.mason')]] })
	use({
		"williamboman/mason-lspconfig.nvim",
		after = { "mason.nvim", "nvim-lspconfig" },
		config = [[require('config.mason-lspconfig')]],
	})

	-- Post-install/update hook with neovim command
	use({
		"nvim-treesitter/nvim-treesitter",
		event = "BufEnter",
		run = function()
			vim.cmd("TSUpdate")
		end,
		config = [[require('config.nvim-treesitter')]],
	})

	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
	use({
		"nvim-telescope/telescope.nvim",
		requires = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-fzf-native.nvim" },
		config = [[require('config.telescope')]],
	})

	-- statusline
	use({ "nvim-tree/nvim-web-devicons" })

	use({
		"nvim-lualine/lualine.nvim",
		event = "VimEnter",
		requires = { "nvim-tree/nvim-web-devicons", opt = true },
		config = [[require('config.lualine')]],
	})

	use({
		"akinsho/bufferline.nvim",
		event = "VimEnter",
		requires = { "nvim-tree/nvim-web-devicons", opt = true },
		config = [[require('config.bufferline')]],
	})

	use({ "famiu/bufdelete.nvim", config = [[require('config.bufdelete')]] })

	-- file explorer
	use({
		"nvim-tree/nvim-tree.lua",
		requires = { "nvim-tree/nvim-web-devicons", opt = true },
		config = [[require('config.nvim-tree')]],
	})

	-- Repeat vim motions
	use({ "tpope/vim-repeat", event = "VimEnter" })

	-- Git command inside vim
	use({ "tpope/vim-fugitive" })

	-- Better git log display
	use({ "rbong/vim-flog", requires = "tpope/vim-fugitive", cmd = { "Flog" } })

	-- Shows a git diff in the sign column.
	use({ "lewis6991/gitsigns.nvim", config = [[require('config.gitsigns')]] })

	-- use { "github/copilot.vim" }

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require("packer").sync()
	end
end)
