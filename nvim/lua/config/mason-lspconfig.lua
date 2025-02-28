require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "rust_analyzer", "ts_ls", "eslint" },
	automatic_installation = true,
})
