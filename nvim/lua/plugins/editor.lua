return {
	-- 기본 편집 도구
	-- (tpope/vim-sensible은 Neovim에서 거의 전부 기본값이라 제거함)
	-- {
	-- 	"kylechui/nvim-surround",
	-- 	event = "VeryLazy", -- 필요할 때만 로드
	-- 	config = true,
	-- },
	-- 주석 토글은 Neovim 0.10+ 내장 기능(gc/gcc)을 사용한다. 키맵은 keys.lua 참고.
	-- (numToStr/Comment.nvim은 2024-06 이후 방치되어 0.11에서 바뀐
	--  vim.treesitter.get_parser 동작 때문에 파서 없는 버퍼에서 깨졌으므로 제거함)
	--
	-- 내장 커멘팅은 commentstring을 treesitter 언어 단위로만 고르기 때문에
	-- tsx 파일의 JSX 안에서도 `//`를 넣는다. ts-comments는 노드 타입까지 보고
	-- `{/* */}`를 골라준다. 내장 gc를 그대로 쓰고 commentstring만 보정한다.
	{
		"folke/ts-comments.nvim",
		event = "VeryLazy",
		opts = {},
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
		opts = {
			-- 성능 최적화 옵션 추가
			check_ts = true, -- treesitter 통합
			disable_filetype = { "fzf", "spectre_panel" },
			fast_wrap = {
				map = "<M-e>",
				chars = { "{", "[", "(", '"', "'" },
				pattern = [=[[%'%"%>%]%)%}%,]]=],
				end_key = "$",
				keys = "qwertyuiopzxcvbnmasdfghjkl",
				check_comma = true,
				highlight = "Search",
				highlight_grey = "Comment",
			},
		},
	},

	-- 하이라이트된 단어 모두 표시
	{
		"RRethy/vim-illuminate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("illuminate").configure({
				providers = { "lsp", "treesitter", "regex" },
				delay = 200, -- 100에서 200으로 증가 (성능 개선)
				filetypes_denylist = {
					"NvimTree",
					"fzf",
					"lazy",
					"mason",
					"help",
					"alpha",
				},
				-- 대용량 파일에서 비활성화
				large_file_cutoff = 2000,
				large_file_overrides = {
					providers = { "lsp" },
				},
			})
		end,
	},

	-- im-select.nvim for Korean input method management
	{
		"keaising/im-select.nvim",
		lazy = false,
		config = function()
			require("config.im-select")
		end,
	},

	-- 터미널 통합
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = { "ToggleTerm", "TermExec" }, -- 명령어 사용시에만 로드
		keys = { [[<c-\>]] },
		opts = {
			open_mapping = [[<c-\>]],
			direction = "float",
			float_opts = {
				border = "curved",
			},
			-- 성능 최적화
			persist_size = true,
			persist_mode = true,
		},
	},

	-- 마크다운 렌더링 (일반 마크다운용)
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" }, -- 마크다운 파일에서만 로드
		opts = {
			file_types = { "markdown" },
			enabled = false,
			latex = { enabled = false },
		},
	},
}
