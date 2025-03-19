require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "catppuccin",
		component_separators = { left = "", right = "" }, -- 좀 더 눈에 띄는 구분자 설정
		section_separators = { left = "", right = "" },
		disabled_filetypes = { "Lazy", "NvimTree" },
		always_divide_middle = true,
		globalstatus = true, -- 모든 창에서 동일한 상태줄 사용
		refresh = { -- 상태줄 갱신 주기 (성능 최적화)
			statusline = 5000, -- 5초마다 갱신
			tabline = 5000,
			winbar = 5000,
		},
	},
	sections = {
		lualine_a = {
			{
				"mode",
				fmt = function(str)
					return str:sub(1, 1)
				end,
			}, -- 모드 첫 글자만 표시 (간결하게)
		},
		lualine_b = {
			{ "branch", icon = "" }, -- Git 브랜치에 아이콘 추가
			{
				"diff",
				source = { "gitsigns" }, -- gitsigns 캐시에서 diff 정보 가져오기
				symbols = { added = "+", modified = "~", removed = "-" }, -- 심플한 diff 심볼
				diff_color = {
					added = { fg = "#98c379" }, -- 색상 커스터마이징 (catppuccin과 조화)
					modified = { fg = "#e5c07b" },
					removed = { fg = "#e06c75" },
				},
			},
		},
		lualine_c = {
			{
				"filename",
				path = 1, -- 상대 경로 표시 (0: 파일명만, 1: 상대경로, 2: 절대경로)
				shorting_target = 50, -- 경로 단축 목표 길이 (조정 가능)
				symbols = {
					modified = "[+]", -- 수정된 파일 표시
					readonly = "[-]", -- 읽기 전용 표시
					unnamed = "[No Name]", -- 이름 없는 버퍼 표시
				},
			},
			{ "diagnostics", sources = { "nvim_lsp" }, sections = { "error", "warn" } }, -- LSP 진단 추가
		},
		lualine_x = {
			-- 린트 상태 추가 (global 함수에서 가져옴)
			{
				function()
					return _G.lint_status and _G.lint_status() or ""
				end,
				color = {
					fg = "#61afef", -- 린트 상태 색상
				},
			},
			{ "filetype", icon_only = false, colored = true }, -- 파일 타입과 아이콘 함께 표시
		},
		lualine_y = {
			{ "encoding", show_bom = false }, -- BOM 표시 비활성화
			{ "fileformat", icons_enabled = true }, -- 파일 형식 (예: unix, dos)
		},
		lualine_z = {
			{ "progress", padding = { left = 1, right = 0 } }, -- 진행률 표시 (패딩 조정)
			{ "location", padding = { left = 1, right = 1 } }, -- 줄/열 위치
		},
	},
	tabline = { -- 탭라인 활성화 (선택적)
	},
	extensions = { "fugitive", "nvim-tree", "quickfix", "lazy" }, -- 확장 추가 (lazy.nvim 지원)
})
