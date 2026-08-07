-- mason-lspconfig v2: 지원 옵션은 ensure_installed와 automatic_enable 뿐이다.
-- (v1의 handlers / automatic_installation / max_concurrent_installers는 제거되어 무시됨)
--
-- 서버별 세부 설정은 config/nvim-lspconfig.lua의 servers 테이블에서 vim.lsp.config()로
-- 등록되고, 공통 capabilities는 vim.lsp.config("*")로 적용된다.
-- 여기서는 설치 보장과 vim.lsp.enable() 자동 호출만 담당한다.
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls", -- Lua
    "ts_ls", -- TypeScript
    "eslint", -- ESLint
    -- oxlint: JS/TS용 Rust 린터. eslint를 대체하는 게 아니라 병행한다.
    -- oxlint는 eslint.config.js를 읽지 않고 .oxlintrc.json이 따로 필요하므로,
    -- CI가 eslint를 돌리는 레포에서 에디터만 교체하면 진단이 CI와 어긋난다.
    -- 대신 lspconfig의 oxlint 설정이 workspace_required = true이고, root marker로
    -- .oxlintrc.json / .oxlintrc.jsonc / oxlint.config.ts,
    -- package.json의 oxlint·vite-plus 필드,
    -- lint: 필드가 있는 vite.config.ts(Vite+)만 찾는다.
    -- 그래서 oxlint를 설정하지 않은 프로젝트에서는 서버가 아예 시작되지 않는다
    -- (vim/lsp.lua의 workspace_required 스킵 경로).
    -- 주의: 두 설정이 **모두** 있는 레포에서는 eslint와 oxlint가 같이 붙어
    -- 겹치는 룰이 이중으로 뜬다. 그건 프로젝트 쪽에서 eslint-plugin-oxlint로
    -- 중복 룰을 끄는 것으로 해결한다(에디터 설정으로 풀 문제가 아니다).
    "oxlint",
    "pyright", -- Python
    "marksman", -- Markdown

    -- rust_analyzer는 여기서 설치하지 않는다.
    -- rustup 컴포넌트(~/.cargo/bin/rust-analyzer)가 이미 있고, mason이
    -- 자기 bin을 vim.env.PATH 앞에 붙이므로(mason 기본값 PATH="prepend",
    -- mason-core/installer/InstallLocation.lua의 set_env) lspconfig의
    -- cmd = { "rust-analyzer" }가 mason 쪽 standalone 바이너리로 해석된다.
    -- 그러면 rustc와 버전이 어긋나 proc-macro 확장이 깨질 수 있다
    -- (이 설정은 edition 2024 + unstable_features를 쓴다).
    -- 툴체인과 버전이 맞는 rustup 쪽을 쓰기 위해 mason 설치를 뺀다.
    --
    -- 주의: 이 목록에서 빼는 것만으로는 이미 설치된 패키지가 지워지지 않는다.
    -- ensure_installed는 미설치 패키지를 설치만 하고 제거는 하지 않는다
    -- (mason-lspconfig/features/ensure_installed.lua의 not pkg:is_installed() 분기).
    -- 이전에 mason으로 rust-analyzer를 깔았던 머신에서는 한 번
    --   :MasonUninstall rust-analyzer
    -- 를 실행해야 PATH 우선순위가 rustup 쪽으로 넘어간다.

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
