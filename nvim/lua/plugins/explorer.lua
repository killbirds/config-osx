return {
	-- File Explorer
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("config.nvim-tree")
		end,
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-fzf-native.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			{
				"nvim-telescope/telescope-smart-history.nvim",
				dependencies = { "kkharji/sqlite.lua" },
			},
		},
		config = function()
			require("config.telescope")
		end,
	},
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

	-- 프로젝트 관리
	{
		"ahmedkhalf/project.nvim",
		config = function()
			require("project_nvim").setup({
				detection_methods = { "pattern", "lsp" }, -- LSP 기반 탐지 추가
				patterns = { ".git", "Makefile", "package.json", "Cargo.toml", "pyproject.toml", "build.gradle" },
				show_hidden = false,
				silent_chdir = true,
				scope_chdir = "global",
				datapath = vim.fn.stdpath("data"),
			})
			require("telescope").load_extension("projects")
		end,
	},
}
