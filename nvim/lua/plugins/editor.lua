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
	-- (folke/ts-comments.nvim 제거함. treesitter에 tsx 파서/쿼리를 설치한 뒤로는
	--  내장 gc가 JSX에서도 {/* */}를 올바르게 고른다. jsx 쿼리가 jsx_element에
	--  bo.commentstring 메타데이터를 제공하고, javascript/tsx 쿼리가 이를 상속한다
	--  (site/queries/jsx/highlights.scm:154).
	--  실측: typescriptreact/javascriptreact -> {/* */}, rust/java/js/ts -> //.
	--  vue/svelte/terraform 같은 다른 filetype을 쓰게 되면 다시 필요할 수 있다)

	{
		"mg979/vim-visual-multi",
		branch = "master",
		-- keys 트리거는 쓰지 않는다. VM 진입점은 위 6개 말고도 11개가 더 있다:
		-- 리더 기반(\\A Select All, \\\\ Add Cursor At Pos, \\gS, \\/),
		-- <S-Left>/<S-Right>, VM_mouse_mappings로 켜지는 <C-LeftMouse> 계열,
		-- visual \\c / \\/. keys에 하나라도 빠지면 그 진입점은 조용히 죽는다.
		-- 목록을 손으로 유지하는 대신 VeryLazy로 UI 준비 직후 로드해 전부 살린다.
		-- (VeryLazy는 UIEnter 후에 뜨므로 startup 시간에는 잡히지 않는다)
		event = "VeryLazy",
		-- 주의: g:VM_maps 등 설정은 반드시 init(플러그인 로드 **전**)에서 해야 한다.
		-- vim-visual-multi는 plugin/ 스크립트가 로드될 때 이 전역들을 읽어 매핑을
		-- 만들기 때문에, config(로드 **후**)에 두면 매핑이 적용되지 않는다.
		init = function()
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

	-- (MeanderingProgrammer/render-markdown.nvim 제거함.
	--  opts.enabled = false로 렌더링이 꺼진 상태였어서 실질 동작이 없었다.
	--  쓰려면 다시 추가하고 enabled = true로 둘 것)
}
