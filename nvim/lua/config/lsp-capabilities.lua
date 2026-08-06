local M = {}

-- LSP 클라이언트 capabilities.
--
-- blink.cmp가 지원하는 completion 관련 capability를 반환한다.
-- 부분 테이블만 넘겨도 되는 이유: Neovim 0.12는 클라이언트 생성 시
--   vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), config.capabilities)
-- 로 병합한다 (runtime/lua/vim/lsp/client.lua). 기존 cmp-nvim-lsp 시절에도
-- cmp_nvim_lsp.default_capabilities()가 textDocument.completion만 담은 부분 테이블이었고,
-- 그 위에 같은 필드를 다시 수동으로 세팅하던 코드는 중복이었으므로 함께 정리했다.
--
-- 참고: blink은 plugin/blink-cmp.lua에서 vim.lsp.config("*", { capabilities = ... })를
-- 스스로 등록한다. 이 함수는 서버별 config와 nvim-metals(vim.lsp.config를 거치지 않음)를
-- 위해 남겨 둔다. vim.lsp.config()는 tbl_deep_extend로 병합되므로 이중 등록은 무해하다.
---@param override? lsp.ClientCapabilities blink 기본값 위에 덮어쓸 capability
---@return lsp.ClientCapabilities
function M.default_capabilities(override)
	local ok, blink = pcall(require, "blink.cmp")
	if not ok then
		return vim.lsp.protocol.make_client_capabilities()
	end
	return blink.get_lsp_capabilities(override)
end

return M
