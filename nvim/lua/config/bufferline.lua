require("bufferline").setup({
	options = {
		mode = "buffers",
		numbers = "none",
		close_command = "bdelete", -- 버퍼를 실제로 닫을 수 있도록 설정
		right_mouse_command = "bdelete", -- 우클릭으로 버퍼 닫기
		left_mouse_command = "buffer", -- 좌클릭으로 해당 버퍼로 이동
		middle_mouse_command = "bdelete", -- 마우스 가운데버튼으로 닫기
		indicator = {
			style = "icon", -- 활성 버퍼 표시를 아이콘으로
		},
		max_name_length = 18,
		max_prefix_length = 15,
		truncate_names = false,
		tab_size = 10,
		diagnostics = true, -- 진단 정보 활성화
		custom_filter = function(bufnr)
			local exclude_ft = { "qf", "fugitive", "git", "help", "text" } -- 추가 필터링
			local cur_ft = vim.bo[bufnr].filetype
			return not vim.tbl_contains(exclude_ft, cur_ft)
		end,
		get_element_icon = function(element)
			local icon, hl = require("nvim-web-devicons").get_icon_by_filetype(element.filetype, { default = true })
			return icon or "", hl -- 기본 아이콘 추가
		end,
		show_buffer_icons = true,
		show_buffer_close_icons = true, -- 닫기 아이콘 표시
		show_close_icon = true,
		show_tab_indicators = true,
		persist_buffer_sort = true,
		separator_style = "slant", -- 더 눈에 띄는 구분선 스타일
		enforce_regular_tabs = false,
		always_show_bufferline = true,
		hover = {
			enabled = true, -- 마우스 오버 효과 활성화
		},
		sort_by = "id",
	},
})
