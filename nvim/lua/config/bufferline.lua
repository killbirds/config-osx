require("bufferline").setup({
	options = {
		mode = "buffers", -- 버퍼 모드 (기본값, 탭 대신 버퍼 표시)
		numbers = "none", -- 버퍼 번호 표시 안 함
		close_command = "bdelete! %d", -- 버퍼 강제 삭제 명령어 (숨김 방지)
		right_mouse_command = "bdelete! %d", -- 우클릭으로 버퍼 강제 삭제
		left_mouse_command = "buffer %d", -- 좌클릭으로 버퍼 이동
		middle_mouse_command = "bdelete! %d", -- 중클릭으로 버퍼 삭제
		indicator = {
			style = "icon", -- 활성 버퍼를 아이콘으로 표시
			icon = "▎", -- 커스텀 인디케이터 아이콘 (심플한 수직선)
		},
		max_name_length = 18, -- 파일명 최대 길이 제한
		max_prefix_length = 15, -- 접두사 최대 길이 제한
		truncate_names = false, -- 이름 잘림 비활성화 (긴 이름 표시)
		tab_size = 10, -- 탭 크기 설정 (컴팩트하게)
		diagnostics = "nvim_lsp", -- LSP 기반 진단 정보 표시
		diagnostics_update_in_insert = false, -- 삽입 모드에서 진단 업데이트 비활성화 (성능 최적화)
		custom_filter = function(bufnr)
			-- 표시하지 않을 파일 타입 필터링
			local exclude_ft = { "qf", "fugitive", "git", "help", "text" }
			local cur_ft = vim.bo[bufnr].filetype
			return not vim.tbl_contains(exclude_ft, cur_ft)
		end,
		get_element_icon = function(element)
			-- 파일 타입에 따른 아이콘 설정 (nvim-web-devicons 사용)
			local icon, hl = require("nvim-web-devicons").get_icon_by_filetype(element.filetype, { default = true })
			return icon or "", hl -- 기본 아이콘 추가
		end,
		show_buffer_icons = true, -- 버퍼 아이콘 표시
		show_buffer_close_icons = true, -- 버퍼 닫기 아이콘 표시
		show_close_icon = true, -- 전체 닫기 아이콘 표시
		show_tab_indicators = true, -- 탭 인디케이터 표시
		persist_buffer_sort = true, -- 버퍼 정렬 상태 유지
		separator_style = "slant", -- 구분선 스타일 (slant로 시각적 구분 강화)
		enforce_regular_tabs = false, -- 탭 크기 강제 비활성화
		always_show_bufferline = true, -- 버퍼라인이 항상 표시되도록 설정
		hover = {
			enabled = true, -- 마우스 호버 효과 활성화
			delay = 200, -- 호버 반응 지연 시간 (ms)
			reveal = { "close" }, -- 호버 시 닫기 버튼 표시
		},
		sort_by = "insert_after_current", -- 새 버퍼를 현재 버퍼 뒤에 추가
		offsets = { -- 특정 파일 타입에 대한 오프셋 설정 (예: 파일 탐색기)
			{
				filetype = "NvimTree",
				text = "File Explorer",
				highlight = "Directory",
				text_align = "left",
			},
		},
	},
})
