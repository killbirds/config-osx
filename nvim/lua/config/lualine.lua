require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "catppuccin",
		component_separators = { left = "", right = "" }, -- 좀 더 눈에 띄는 구분자 설정
		section_separators = { left = "", right = "" },
		disabled_filetypes = { "packer", "NvimTree" },
		always_divide_middle = true,
		globalstatus = true, -- 모든 창에서 동일한 상태줄 사용
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff" },
		lualine_c = { { "filename", path = 0, shorting_target = 50 } }, -- 절대경로 사용, 경로 길이 늘리기
		lualine_x = { "filetype" },
		lualine_y = { "encoding", "fileformat" },
		lualine_z = {
			{ "progress", icons_enabled = false },
			{ "location", icons_enabled = false },
		},
	},
	tabline = {}, -- 탭라인 비활성화
	extensions = { "fugitive", "nvim-tree", "quickfix" }, -- quickfix 확장 추가
})
