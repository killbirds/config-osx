-- 하이라이트 그룹 정의
local function setup_gitsigns_highlights()
	vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#2ecc71" }) -- 추가된 부분 (녹색)
	vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#f1c40f" }) -- 변경된 부분 (노란색)
	vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#e74c3c" }) -- 삭제된 부분 (빨간색)
	vim.api.nvim_set_hl(0, "GitSignsChangedelete", { fg = "#f1c40f" }) -- 변경+삭제 (노란색)
	vim.api.nvim_set_hl(0, "GitSignsTopdelete", { fg = "#e74c3c" }) -- 상단 삭제 (빨간색)
	vim.api.nvim_set_hl(0, "GitSignsUntracked", { fg = "#95a5a6" }) -- 추적되지 않음 (회색)
end

-- 하이라이트 설정 적용
setup_gitsigns_highlights()

-- 컬러 스키마 변경 시 하이라이트 다시 적용
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		setup_gitsigns_highlights()
	end,
})

require("gitsigns").setup({
	signs = {
		add = { text = "│" }, -- hl 속성 제거
		change = { text = "│" }, -- hl 속성 제거
		delete = { text = "_" }, -- hl 속성 제거
		topdelete = { text = "‾" }, -- hl 속성 제거
		changedelete = { text = "~" }, -- hl 속성 제거
		untracked = { text = "┆" }, -- hl 속성 제거
	},
	signcolumn = true, -- 기호 열에 표시
	numhl = false, -- 줄 번호 색 변경 비활성화
	linehl = false, -- 줄 배경색 변경 비활성화
	word_diff = false, -- 단어 단위 diff 비활성화
	watch_gitdir = {
		interval = 1000, -- 1초마다 git 디렉토리 확인 (성능 최적화)
		follow_files = true, -- 파일 이름 변경 감지
	},
	attach_to_untracked = true, -- 추적되지 않는 파일에도 연결 (개선)
	current_line_blame = true, -- 현재 줄 blame 활성화 (개선)
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = "eol", -- 줄 끝에 표시
		delay = 500, -- 500ms 지연 후 표시
		ignore_whitespace = true, -- 공백 변경 무시
	},
	current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
	sign_priority = 6, -- 표시 우선순위
	update_debounce = 100, -- 업데이트 디바운스 시간 감소 (ms)
	status_formatter = nil, -- 기본 포매터 사용
	max_file_length = 40000, -- 처리할 최대 파일 길이 제한
	preview_config = {
		border = "rounded",
		style = "minimal",
		relative = "cursor",
		row = 0,
		col = 1,
	},
	-- Git 작업 관련 설정 추가
	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns

		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- 키 매핑 추가
		-- 탐색
		map("n", "]c", function()
			if vim.wo.diff then
				return "]c"
			end
			vim.schedule(function()
				gs.next_hunk()
			end)
			return "<Ignore>"
		end, { expr = true, desc = "다음 변경 부분으로 이동" })

		map("n", "[c", function()
			if vim.wo.diff then
				return "[c"
			end
			vim.schedule(function()
				gs.prev_hunk()
			end)
			return "<Ignore>"
		end, { expr = true, desc = "이전 변경 부분으로 이동" })

		-- 액션
		map("n", "<leader>hs", gs.stage_hunk, { desc = "Hunk 스테이징" })
		map("n", "<leader>hr", gs.reset_hunk, { desc = "Hunk 리셋" })
		map("v", "<leader>hs", function()
			gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "선택 부분 스테이징" })
		map("v", "<leader>hr", function()
			gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "선택 부분 리셋" })
		map("n", "<leader>hS", gs.stage_buffer, { desc = "버퍼 전체 스테이징" })
		map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "스테이징 취소" })
		map("n", "<leader>hR", gs.reset_buffer, { desc = "버퍼 전체 리셋" })
		map("n", "<leader>hp", gs.preview_hunk, { desc = "Hunk 미리보기" })
		map("n", "<leader>hb", function()
			gs.blame_line({ full = true })
		end, { desc = "전체 blame 보기" })
		map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "현재 줄 blame 토글" })
		map("n", "<leader>hd", gs.diffthis, { desc = "현재 파일 diff" })
		map("n", "<leader>hD", function()
			gs.diffthis("~")
		end, { desc = "HEAD와 diff 비교" })
		map("n", "<leader>td", gs.toggle_deleted, { desc = "삭제된 줄 토글" })
	end,
	-- 성능 최적화 설정
	_threaded_diff = true, -- 쓰레드로 diff 계산
})
