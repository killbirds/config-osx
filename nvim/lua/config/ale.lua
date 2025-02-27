-- ALE Fixers 설정
vim.g.ale_fixers = {
	javascript = { "prettier" },
	javascriptreact = { "prettier" },
	typescript = { "prettier" },
	typescriptreact = { "prettier" },
	scss = { "prettier" },
	css = { "prettier" },
	json = { "prettier" },
	scala = {},
	java = {},
	rust = { "rustfmt" },
}

-- 저장할 때 자동으로 린팅하지 않음
vim.g.ale_lint_on_save = 0

-- 명시적으로 지정한 린터만 사용
vim.g.ale_linters_explicit = 1

-- ALE Linters 설정
vim.g.ale_linters = {
	javascript = { "eslint" },
	typescript = {},
	scala = {},
	java = {},
}

-- 파일 저장 시 자동으로 포맷 적용
vim.g.ale_fix_on_save = 1

-- ALE의 LSP 기능 비활성화 (nvim-lspconfig를 사용할 경우)
vim.g.ale_completion_enabled = 0
vim.g.ale_disable_lsp = 1

-- 항상 sign column을 표시
vim.g.ale_sign_column_always = 1

-- Prettier가 로컬 설정 파일을 따르도록 설정
vim.g.ale_javascript_prettier_use_local_config = 1
