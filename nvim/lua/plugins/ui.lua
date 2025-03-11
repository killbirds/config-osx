return {
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

	-- 인덴트 가이드
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},

	-- Trouble.nvim for diagnostics, references, etc.
	{
		"folke/trouble.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("config.trouble")
		end,
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "진단 목록 표시" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "현재 버퍼 진단 목록" },
			{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "로케이션 리스트" },
			{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "퀵픽스 리스트" },
			{ "<leader>xl", "<cmd>Trouble lsp toggle<cr>", desc = "LSP 참조/정의/구현" },
			{ "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "문서 심볼" },
		},
	},
} 