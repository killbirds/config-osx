require("mason-tool-installer").setup({
	ensure_installed = {
		-- 린터만 포함
		"luacheck", -- Lua
		"eslint_d", -- JavaScript/TypeScript
		"flake8", -- Python
		"shellcheck", -- Shell
		"yamllint", -- YAML
		"jsonlint", -- JSON

		-- 포매터만 포함
		"stylua", -- Lua
		"prettier", -- JavaScript/TypeScript/HTML/CSS/JSON
		"shfmt", -- Shell
		"black", -- Python
		"clang-format", -- C/C++
		"gofumpt", -- Go
		"rustfmt", -- Rust
	},
	auto_update = true,
	run_on_start = true,
	start_delay = 3000, -- 3초 지연
	debounce_hours = 24, -- 최소 24시간 설치/업데이트 시도 간격
	max_concurrent_installers = 4, -- 동시 설치 가능한 도구 수 제한
})
