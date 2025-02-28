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

-- 자동 린팅 및 Quickfix 출력 설정
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.js", "*.ts", "*.jsx", "*.tsx", "*.py", "*.lua" }, -- 지원 파일 확장자
	group = vim.api.nvim_create_augroup("Linting", { clear = true }), -- 중복 방지를 위한 그룹
	callback = function()
		lint.try_lint() -- 린팅 실행
		-- LSP 기반 진단과 린터 결과 결합
		local diagnostics = vim.diagnostic.get(0, { severity = { min = vim.diagnostic.severity.WARN } })
		if #diagnostics > 0 then
			vim.diagnostic.setqflist() -- Quickfix 목록 업데이트
			vim.cmd("cwindow") -- Quickfix 창을 조건부로 열기 (이미 열려 있으면 유지)
		end
	end,
})

-- 추가 이벤트: 버퍼 진입 시에도 린팅 실행 (선택적)
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.js", "*.ts", "*.jsx", "*.tsx", "*.py", "*.lua" },
	group = vim.api.nvim_create_augroup("LintOnEnter", { clear = true }),
	callback = function()
		lint.try_lint()
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
