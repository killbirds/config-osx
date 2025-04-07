require("mason-lspconfig").setup({
	ensure_installed = {
		-- 핵심 서버만 기본 설치
		"lua_ls", -- Lua
		"rust_analyzer", -- Rust
		"ts_ls", -- TypeScript
		"eslint", -- ESLint

		-- 자주 사용하는 서버는 필요에 따라 주석 해제
		-- "pyright", -- Python
		-- "cssls", -- CSS
		-- "html", -- HTML
		-- "jsonls", -- JSON
		-- "yamlls", -- YAML
		-- "marksman", -- Markdown
		-- "bashls", -- Bash
		-- "clangd", -- C/C++
		-- "gopls", -- Go
	},
	automatic_installation = false, -- 자동 설치는 비활성화하고 필요할 때만 수동으로 설치
	max_concurrent_installers = 2, -- 동시에 설치할 수 있는 서버 수 제한
	handlers = {
		-- LSP 서버 지연 로딩을 위한 핸들러
		function(server_name)
			-- 여기서는 아무것도 하지 않음
			-- nvim-lspconfig.lua에서 지연 로딩으로 처리
		end,
	},
})
