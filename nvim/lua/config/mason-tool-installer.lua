require("mason-tool-installer").setup({
	ensure_installed = {
		-- LSP
		"lua-language-server", -- lua_ls
		"rust-analyzer", -- rust_analyzer
		"typescript-language-server", -- ts_ls
		"eslint-lsp", -- eslint

		-- Linters
		"luacheck",

		-- Formatters
		"stylua",
		"shfmt",
	},
	auto_update = true,
	run_on_start = true,
	start_delay = 3000, -- 3 seconds delay
	debounce_hours = 24, -- at least 24 hours between attempts to install/update
})
