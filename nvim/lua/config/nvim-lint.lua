local lint = require("lint")

-- 파일 타입별 린터 설정
lint.linters_by_ft = {
	javascript = { "eslint" }, -- JavaScript 린팅
	typescript = { "eslint" }, -- TypeScript 린팅
	javascriptreact = { "eslint" }, -- JSX 지원 추가
	typescriptreact = { "eslint" }, -- TSX 지원 추가
	python = { "flake8" }, -- Python 린팅
	lua = { "luacheck" }, -- Lua 린팅
}

-- 커스텀 린터 설정 (선택적)
lint.linters.eslint = {
	name = "eslint", -- 린터 이름
	cmd = "eslint", -- 실행 명령어
	args = { "--format", "json", "--stdin", "--stdin-filename", "%filepath" }, -- JSON 출력 설정
	stream = "stdout", -- 출력 스트림
	ignore_exitcode = true, -- 종료 코드 무시 (에러가 있어도 계속 진행)
	env = {
		ESLINT_USE_FLAT_CONFIG = "true", -- eslint.config.mjs 파일을 인식하기 위한 환경 변수
	},
}

lint.linters.flake8 = {
	name = "flake8",
	cmd = "flake8",
	args = { "--format", "default", "--stdin-display-name", "%filepath", "-" },
	stream = "stdout",
}

lint.linters.luacheck = {
	name = "luacheck",
	cmd = "luacheck",
	args = { "--formatter", "plain", "--codes", "--ranges", "--filename", "%filepath", "-" },
	stream = "stdout",
}

-- 진단 결과를 quickfix에 표시하는 함수 (현재 프로젝트의 진단만 표시)
local function update_quickfix()
	-- 현재 작업 디렉토리(프로젝트 루트) 가져오기
	local cwd = vim.fn.getcwd()

	-- 모든 열린 버퍼에서 진단 수집
	local all_diagnostics = {}
	local buffers = vim.api.nvim_list_bufs()

	for _, buf in ipairs(buffers) do
		if vim.api.nvim_buf_is_valid(buf) then
			local buf_name = vim.api.nvim_buf_get_name(buf)

			-- 파일이 현재 프로젝트 내에 있는지 확인
			if buf_name and buf_name:find(cwd, 1, true) then
				local buf_diagnostics = vim.diagnostic.get(buf, { severity = { min = vim.diagnostic.severity.WARN } })

				for _, diag in ipairs(buf_diagnostics) do
					table.insert(all_diagnostics, {
						bufnr = buf,
						lnum = diag.lnum + 1,
						col = diag.col + 1,
						text = diag.message .. " [" .. vim.fn.fnamemodify(buf_name, ":~:.") .. "]",
						type = (diag.severity == vim.diagnostic.severity.ERROR and "E" or "W"),
					})
				end
			end
		end
	end

	if #all_diagnostics > 0 then
		-- 현재 윈도우 ID 저장
		local current_win = vim.api.nvim_get_current_win()

		-- pcall을 사용해 안전하게 quickfix 목록 업데이트
		local ok, _ = pcall(function()
			vim.fn.setqflist(all_diagnostics) -- 필터링된 진단으로 Quickfix 목록 업데이트
			vim.cmd("cwindow")
		end)

		-- 에러가 없고 현재 윈도우가 여전히 유효할 경우에만 원래 윈도우로 포커스 돌려놓기
		if ok and vim.api.nvim_win_is_valid(current_win) then
			vim.api.nvim_set_current_win(current_win)
		end
	end
end

-- 자동 린팅 및 Quickfix 출력 설정 - 파일 저장 시에만 실행
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.js", "*.ts", "*.jsx", "*.tsx", "*.py", "*.lua", "*.rs" }, -- 지원 파일 확장자
	group = vim.api.nvim_create_augroup("Linting", { clear = true }), -- 중복 방지를 위한 그룹
	callback = function()
		-- TSX 파일 타입 포함
		lint.try_lint() -- 린팅 실행
		update_quickfix()
	end,
})

-- 버퍼 진입 시에 린팅 적용 (TSX 포함)
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.js", "*.ts", "*.jsx", "*.tsx", "*.py", "*.lua", "*.rs" }, -- TSX 포함
	group = vim.api.nvim_create_augroup("LintOnEnter", { clear = true }),
	callback = function()
		-- 파일이 닫혀 있으면 실행 중지
		if not vim.api.nvim_buf_is_valid(0) then
			return
		end

		-- 일정 시간 후에 린팅 (지연 실행)
		local timer = vim.uv.new_timer()
		if timer then
			timer:start(
				1000, -- 1초 지연
				0,
				vim.schedule_wrap(function()
					lint.try_lint()
				end)
			)
		end
	end,
})

-- 파일 수정 후 또는 저장하지 않은 상태에서도 진단 결과 반영
vim.api.nvim_create_autocmd("DiagnosticChanged", {
	group = vim.api.nvim_create_augroup("DiagnosticQuickfix", { clear = true }),
	callback = function()
		-- vim.in_fast_event()로 빠른 이벤트 내에 있는지 확인
		if vim.in_fast_event() then
			return
		end

		-- vim.api.nvim_get_mode()를 통해 현재 모드 확인
		local mode = vim.api.nvim_get_mode().mode
		if mode:find("c") or mode:find("t") then
			-- 명령 모드나 터미널 모드에서는 실행하지 않음
			return
		end

		-- 현재 버퍼에 포커스가 있고 지원하는 파일 타입인 경우에만 업데이트
		-- TSX 파일 타입 포함
		local ft = vim.bo.filetype
		if
			ft == "javascript"
			or ft == "typescript"
			or ft == "javascriptreact"
			or ft == "typescriptreact"
			or ft == "python"
			or ft == "lua"
			or ft == "rust"
		then
			-- pcall로 안전하게 실행
			pcall(update_quickfix)
		end
	end,
})

-- Quickfix 창에서 'o' 키로 항목 열기
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf", -- Quickfix 창에 적용
	group = vim.api.nvim_create_augroup("QuickfixKeymap", { clear = true }),
	callback = function()
		vim.keymap.set("n", "o", "<CR>", {
			buffer = true,
			silent = true,
			desc = "Open Quickfix item",
		})
	end,
})

-- TextChanged 이벤트 린팅은 비활성화 (성능 문제 해결)
-- 파일 저장 시에만 린팅 실행하도록 변경
