require("lint").linters_by_ft = {
	javascript = { "eslint" },
	typescript = { "eslint" },
	python = { "flake8" },
	lua = { "luacheck" },
}

-- 'BufWritePost'를 특정 파일 형식에만 적용하도록 설정
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.js", "*.ts", "*.tsx", "*.py", "*.lua" }, -- 특정 파일 형식에만 적용
	callback = function()
		require("lint").try_lint()
	end,
})

-- 린팅 결과를 quickfix 목록에 출력하도록 추가
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.js", "*.ts", "*.tsx", "*.py", "*.lua" }, -- 특정 파일 형식에만 적용
	callback = function()
		local lint = require("lint")
		lint.try_lint()
		local diagnostics = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
		if #diagnostics > 0 then
			vim.cmd("copen") -- quickfix 창을 열어 에러를 표시
		end
	end,
})
