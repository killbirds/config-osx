local M = {}

-- 공통 키맵 설정 함수
local function set_keymap(bufnr, lhs, rhs, desc)
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", lhs, rhs, vim.tbl_extend("force", bufopts, { desc = desc }))
end

-- on_attach 함수: LSP가 버퍼에 연결될 때 실행됩니다.
local on_attach = function(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	-- 기본 LSP 키바인딩
	set_keymap(bufnr, "gD", vim.lsp.buf.declaration, "Go to Declaration")
	set_keymap(bufnr, "gd", vim.lsp.buf.definition, "Go to Definition")
	set_keymap(bufnr, "K", vim.lsp.buf.hover, "Show Hover Documentation")
	set_keymap(bufnr, "gi", vim.lsp.buf.implementation, "Go to Implementation")
	set_keymap(bufnr, "<space>wa", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder")
	set_keymap(bufnr, "<space>wr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")
	set_keymap(bufnr, "<space>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, "List Workspace Folders")
	set_keymap(bufnr, "gy", vim.lsp.buf.type_definition, "Go to Type Definition")
	set_keymap(bufnr, "<space>rn", vim.lsp.buf.rename, "Rename Symbol")
	set_keymap(bufnr, "<space>ca", vim.lsp.buf.code_action, "Code Action")
	set_keymap(bufnr, "gr", vim.lsp.buf.references, "Go to References")
	set_keymap(bufnr, "<space>f", function()
		vim.lsp.buf.format({ async = true })
	end, "Format Buffer")
end

M.on_attach = on_attach

return M
