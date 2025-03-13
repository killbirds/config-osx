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
	cmd = "eslint", -- 실행 명령어
	args = { "--format", "json", "--stdin", "--stdin-filename", "%filepath" }, -- JSON 출력 설정
	stream = "stdout", -- 출력 스트림
	ignore_exitcode = true, -- 종료 코드 무시 (에러가 있어도 계속 진행)
	env = {
		ESLINT_USE_FLAT_CONFIG = "true", -- eslint.config.mjs 파일을 인식하기 위한 환경 변수
	},
}

lint.linters.flake8 = {
	cmd = "flake8",
	args = { "--format", "default", "--stdin-display-name", "%filepath", "-" },
	stream = "stdout",
}

lint.linters.luacheck = {
	cmd = "luacheck",
	args = { "--formatter", "plain", "--codes", "--ranges", "--filename", "%filepath", "-" },
	stream = "stdout",
}

-- 진단 결과를 quickfix에 표시하는 함수
local function update_quickfix()
	-- LSP 기반 진단과 린터 결과 결합
	local diagnostics = vim.diagnostic.get(0, { severity = { min = vim.diagnostic.severity.WARN } })
	if #diagnostics > 0 then
		-- 현재 윈도우 ID 저장
		local current_win = vim.api.nvim_get_current_win()

		-- pcall을 사용해 안전하게 quickfix 목록 업데이트
		local ok, _ = pcall(function()
			vim.diagnostic.setqflist() -- Quickfix 목록 업데이트
			vim.cmd("cwindow")
		end)

		-- 에러가 없고 현재 윈도우가 여전히 유효할 경우에만 원래 윈도우로 포커스 돌려놓기
		if ok and vim.api.nvim_win_is_valid(current_win) then
			vim.api.nvim_set_current_win(current_win)
		end
	end
end

-- 자동 린팅 및 Quickfix 출력 설정
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.js", "*.ts", "*.jsx", "*.tsx", "*.py", "*.lua", "*.rs" }, -- 지원 파일 확장자
	group = vim.api.nvim_create_augroup("Linting", { clear = true }), -- 중복 방지를 위한 그룹
	callback = function()
		lint.try_lint() -- 린팅 실행
		update_quickfix()
	end,
})

-- 추가 이벤트: 버퍼 진입 시에도 린팅 실행 (선택적)
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.js", "*.ts", "*.jsx", "*.tsx", "*.py", "*.lua", "*.rs" },
	group = vim.api.nvim_create_augroup("LintOnEnter", { clear = true }),
	callback = function()
		lint.try_lint()
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

-- TextChanged 이벤트에서도 린팅 실행 (선택적, 주의: 자원 소모가 클 수 있음)
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
	pattern = { "*.js", "*.ts", "*.jsx", "*.tsx", "*.py", "*.lua", "*.rs" },
	group = vim.api.nvim_create_augroup("LintOnChange", { clear = true }),
	callback = function()
		-- 타이머를 사용하여 입력 후 일정 시간이 지나면 린팅 실행 (디바운싱)
		local timer = vim.uv.new_timer()
		if timer then
			timer:start(
				500,
				0,
				vim.schedule_wrap(function()
					lint.try_lint()
				end)
			)
		end
	end,
})
