local M = {}

-- 공통 키맵 설정 함수
local function set_keymap(bufnr, mode, lhs, rhs, desc)
	local opts = { noremap = true, silent = true, buffer = bufnr, desc = desc }
	vim.keymap.set(mode, lhs, rhs, opts)
end

-- 공통 LSP 설정을 적용하는 함수
local function setup_buffer_options(bufnr)
	-- 오므니펑션 설정 (LSP 기반 자동완성)
	vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
	-- 버퍼별 추가 옵션 (선택적)
	vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr()"
end

-- on_attach 함수: LSP 클라이언트가 버퍼에 연결될 때 호출
M.on_attach = function(client, bufnr)
	-- 버퍼 옵션 설정
	setup_buffer_options(bufnr)

	-- LSP 기본 키바인딩
	set_keymap(bufnr, "n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
	set_keymap(bufnr, "n", "gd", vim.lsp.buf.definition, "Go to Definition")
	set_keymap(bufnr, "n", "K", vim.lsp.buf.hover, "Show Hover Documentation")
	set_keymap(bufnr, "n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
	set_keymap(bufnr, "n", "gy", vim.lsp.buf.type_definition, "Go to Type Definition")
	set_keymap(bufnr, "n", "gr", vim.lsp.buf.references, "List References")

	-- 워크스페이스 관련 키맵
	set_keymap(bufnr, "n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder")
	set_keymap(bufnr, "n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")
	set_keymap(bufnr, "n", "<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, "List Workspace Folders")

	-- 코드 조작 관련 키맵
	set_keymap(bufnr, "n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
	set_keymap(bufnr, "n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
	set_keymap(bufnr, "n", "<leader>f", function()
		vim.lsp.buf.format({
			async = true,
			filter = function(c)
				return c.name ~= "tsserver"
			end,
		})
	end, "Format Buffer")

	-- 진단 관련 키맵 (추가)
	set_keymap(bufnr, "n", "<leader>e", vim.diagnostic.open_float, "Show Line Diagnostics")
	set_keymap(bufnr, "n", "[d", vim.diagnostic.goto_prev, "Go to Previous Diagnostic")
	set_keymap(bufnr, "n", "]d", vim.diagnostic.goto_next, "Go to Next Diagnostic")
	set_keymap(bufnr, "n", "<leader>q", vim.diagnostic.setloclist, "Set Loclist with Diagnostics")

	-- 서버별 조건부 설정 (예시)
	if client.server_capabilities.documentFormattingProvider then
		vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
			vim.lsp.buf.format({ async = true })
		end, { desc = "Format current buffer with LSP" })
	end
end

-- 추가 유틸리티 함수 (선택적)
M.setup = function()
	-- 전역 진단 설정 (필요 시)
	vim.diagnostic.config({
		virtual_text = true, -- 가상 텍스트로 진단 표시
		signs = true, -- 사이드 컬럼에 기호 표시
		update_in_insert = false, -- 삽입 모드에서 업데이트 비활성화 (성능 최적화)
		severity_sort = true, -- 심각도順 정렬
	})
end

return M
