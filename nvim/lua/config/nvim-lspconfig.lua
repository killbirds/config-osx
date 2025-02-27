local keys = require("config.nvim-lspconfig-keys")

-- 공통 LSP 설정 함수
local function on_attach_and_flags(client, bufnr)
	keys.on_attach(client, bufnr)
	-- 자동 완성 및 진단 활성화
	client.server_capabilities.document_formatting = true
	client.server_capabilities.document_range_formatting = true
end

local opts = { noremap = true, silent = true }

-- 진단 관련 키 매핑
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)

-- LSP 플래그 설정
local lsp_flags = {
	debounce_text_changes = 150,
}

-- `cmp_nvim_lsp`로 자동 완성 기능 확장
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- TypeScript LSP 설정
require("lspconfig")["ts_ls"].setup({
	on_attach = on_attach_and_flags,
	flags = lsp_flags,
	capabilities = capabilities,
})

-- Rust LSP 설정
require("lspconfig")["rust_analyzer"].setup({
	on_attach = on_attach_and_flags,
	flags = lsp_flags,
	capabilities = capabilities,
	settings = {
		["rust-analyzer"] = {
			cargo = {
				allFeatures = true,
			},
		},
	},
})

-- Lua LSP 설정
require("lspconfig")["lua_ls"].setup({
	on_attach = on_attach_and_flags,
	flags = lsp_flags,
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
			telemetry = {
				enable = false,
			},
		},
	},
})
