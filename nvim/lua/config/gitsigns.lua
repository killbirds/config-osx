require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "-" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
		untracked = { text = "┆" },
	},
	signcolumn = true, -- 기호 열에 표시
	numhl = false, -- 줄 번호 색 변경 비활성화
	linehl = false, -- 줄 배경색 변경 비활성화
	word_diff = false, -- 단어 단위 diff 비활성화
	watch_gitdir = {
		interval = 5000, -- 5초마다 git 디렉토리 확인 (1초에서 변경)
		follow_files = true, -- 파일 이름 변경 감지
	},
	attach_to_untracked = false, -- 추적되지 않는 파일에 연결 안함
	current_line_blame = false, -- 현재 줄 blame 비활성화
	sign_priority = 6, -- 표시 우선순위
	update_debounce = 500, -- 업데이트 디바운스 시간 (ms)
	status_formatter = nil, -- 기본 포매터 사용
	max_file_length = 40000, -- 처리할 최대 파일 길이 제한
	preview_config = {
		border = "rounded",
		style = "minimal",
		relative = "cursor",
		row = 0,
		col = 1,
	},
	-- 성능 최적화 설정 추가
	_threaded_diff = true, -- 쓰레드로 diff 계산
	_extmark_signs = true, -- extmark 기능 사용
})
