-- mason-lspconfig v2: 지원 옵션은 ensure_installed와 automatic_enable 뿐이다.
-- (v1의 handlers / automatic_installation / max_concurrent_installers는 제거되어 무시됨)
--
-- 역할 분담: 이 파일은 **무엇을 설치하고 무엇을 띄워도 되는지**(허용 목록)만 정한다.
-- 서버별 세부 설정은 config/nvim-lspconfig.lua의 servers 테이블이 vim.lsp.config()로
-- 등록하고 vim.lsp.enable()로 켠다. 공통 capabilities는 vim.lsp.config("*")로 적용된다.

-- 설치 목록이자 automatic_enable의 allowlist. 두 역할에 같은 목록을 쓴다.
local servers = {
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
  -- (rust_analyzer 자체는 servers 테이블에 있으므로 LSP로는 계속 뜬다)

  -- 자주 사용하는 서버는 필요에 따라 주석 해제
  -- "cssls", -- CSS
  -- "html", -- HTML
  -- "jsonls", -- JSON
  -- "yamlls", -- YAML
  -- "bashls", -- Bash
  -- "clangd", -- C/C++
  -- "gopls", -- Go
}

require("mason-lspconfig").setup({
  ensure_installed = servers,

  -- allowlist 모드다. automatic_enable에 exclude 키가 있으면 denylist,
  -- 평범한 배열이면 allowlist로 동작한다(automatic_enable.lua의 enable_server 분기).
  --
  -- denylist(exclude)를 쓰지 않는 이유:
  -- automatic_enable은 자기 ensure_installed가 아니라 **설치된 mason 패키지 전체**를
  -- 순회하고(automatic_enable.lua의 registry.get_installed_package_names()),
  -- 매칭 기준은 filetype이 아니라 레지스트리의 neovim.lspconfig 필드다.
  -- 그래서 LSP로 띄울 생각이 없던 도구도 "설치돼 있다"는 이유만으로 서버가 된다.
  --   ruff   - 린터인데 neovim.lspconfig = "ruff". 진단/포맷은 nvim-lint + conform이
  --            담당하므로 LSP로 뜨면 진단이 중복된다.
  --   stylua - 포매터인데 neovim.lspconfig = "stylua" (lspconfig가 stylua --lsp 실행).
  --            Lua 버퍼에 lua_ls와 함께 formatting client 두 개가 붙고, :LspFormat이
  --            vim.lsp.buf.format()을 필터 없이 부르므로 이중 포맷이 된다.
  -- denylist는 이걸 레지스트리 전체를 상대로 영구히 관리하겠다는 뜻이고, 빠뜨리면
  -- 조용히 서버가 뜬다. (예: oxfmt도 neovim.lspconfig = "oxfmt"다)
  -- allowlist는 목록에 없으면 무조건 막으므로 그 관리 부담이 없다.
  --
  -- 반대로 automatic_enable = false로 아예 끄면 안 되는 이유:
  -- false면 mason-lspconfig가 automatic_enable.init()을 건너뛰고(init.lua의
  -- automatic_enable ~= false 가드), 그 안에서 걸던 package:install:success 구독까지
  -- 사라진다. 그 구독은 설치가 끝날 때마다 vim.lsp.enable()을 다시 부르고,
  -- vim.lsp.enable()은 이미 열려 있는 버퍼에 대해 doautoall('nvim.lsp.enable FileType')로
  -- 시작을 재시도한다(runtime/lua/vim/lsp.lua).
  -- 이게 없으면 새 머신에서 첫 파일을 열었을 때 서버 설치가 끝나도 그 버퍼에는
  -- 붙지 않고, 파일을 다시 열어야 한다.
  automatic_enable = servers,
})
