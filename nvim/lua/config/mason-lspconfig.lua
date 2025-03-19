require("mason-lspconfig").setup({
	ensure_installed = {
		-- 기존 서버
		"lua_ls", -- Lua
		"rust_analyzer", -- Rust
		"ts_ls", -- TypeScript
		"eslint", -- ESLint

		-- 추가 서버
		"pyright", -- Python
		"cssls", -- CSS
		"html", -- HTML
		"jsonls", -- JSON
		"yamlls", -- YAML
		"marksman", -- Markdown
		"bashls", -- Bash
		"clangd", -- C/C++
		"gopls", -- Go
	},
	automatic_installation = true,
	handlers = {
		-- 기본 설정 핸들러
		function(server_name)
			require("lspconfig")[server_name].setup({})
		end,
	},
})
