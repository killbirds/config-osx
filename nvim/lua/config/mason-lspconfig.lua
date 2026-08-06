-- mason-lspconfig v2: 지원 옵션은 ensure_installed와 automatic_enable 뿐이다.
-- (v1의 handlers / automatic_installation / max_concurrent_installers는 제거되어 무시됨)
--
-- 서버별 세부 설정은 config/nvim-lspconfig.lua의 servers 테이블에서 vim.lsp.config()로
-- 등록되고, 공통 capabilities는 vim.lsp.config("*")로 적용된다.
-- 여기서는 설치 보장과 vim.lsp.enable() 자동 호출만 담당한다.
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls", -- Lua
    "rust_analyzer", -- Rust
    "ts_ls", -- TypeScript
    "eslint", -- ESLint
    "pyright", -- Python
    "marksman", -- Markdown

    -- 자주 사용하는 서버는 필요에 따라 주석 해제
    -- "cssls", -- CSS
    -- "html", -- HTML
    -- "jsonls", -- JSON
    -- "yamlls", -- YAML
    -- "bashls", -- Bash
    -- "clangd", -- C/C++
    -- "gopls", -- Go
  },
  -- 설치된 서버를 자동으로 vim.lsp.enable() 한다.
  -- servers 테이블에 있는 서버는 nvim-lspconfig.lua에서도 enable하지만 중복 호출은 무해하다.
  -- ruff는 mason 패키지(린터 바이너리)가 LSP 서버로도 등록되는데,
  -- Python 린팅은 nvim-lint의 ruff가 담당하므로 진단 중복을 막기 위해 제외한다.
  automatic_enable = {
    -- ruff: 진단/포맷은 conform + nvim-lint가 담당하므로 LSP로 띄우지 않는다.
    -- stylua: mason이 formatter로 설치하는데 mason-lspconfig의 filetype 매핑에
    --   Lua 서버 후보로 들어 있어 LSP로도 자동 활성된다. 그러면 Lua 버퍼에
    --   lua_ls와 stylua 두 formatting client가 붙고, :LspFormat이
    --   vim.lsp.buf.format()에 필터 없이 호출돼 둘 다 대상이 된다(이중 포맷).
    --   포맷은 conform의 stylua 경로가 담당하므로 LSP는 제외한다.
    exclude = { "ruff", "stylua" },
  },
})
