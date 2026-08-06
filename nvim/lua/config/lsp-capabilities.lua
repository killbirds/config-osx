local M = {}

-- LSP 클라이언트 capabilities.
--
-- blink.cmp가 지원하는 completion 관련 capability를 반환한다.
-- 부분 테이블만 넘겨도 되는 이유: Neovim 0.12는 클라이언트 생성 시
--   vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), config.capabilities)
-- 로 병합한다 (runtime/lua/vim/lsp/client.lua:436-437). 기존 cmp-nvim-lsp 시절에도
-- cmp_nvim_lsp.default_capabilities()가 textDocument.completion만 담은 부분 테이블이었다.
--
-- 주의: 광고하는 capability 집합은 기존과 동일하지 않다. blink v1.10.2는
-- (blink.cmp/lua/blink/cmp/sources/lib/init.lua:301-343)
--   commitCharactersSupport  true  -> false
--   preselectSupport         true  -> false
--   insertTextModeSupport    {1,2} -> {1}
--   resolveSupport           insertTextFormat/insertTextMode 제거, detail/data 추가
-- 로 좁아진다. blink이 실제로 지원하지 않는 기능을 true로 광고하지 않는 것이므로
-- 이쪽이 정확하지만, 서버가 commit character / preselect / adjustIndentation 처리와
-- lazy resolve 필드 구성을 바꿀 수 있다는 뜻이다. 기존 파일이 수동으로 세팅하던
-- 필드들이 전부 무의미한 중복이었던 것은 아니다.
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
