require("mason-lspconfig").setup({
  ensure_installed = {
    -- 핵심 서버만 기본 설치
    "lua_ls",      -- Lua
    "rust_analyzer", -- Rust
    "ts_ls",       -- TypeScript
    "eslint",      -- ESLint

    -- 자주 사용하는 서버는 필요에 따라 주석 해제
    -- "pyright", -- Python
    -- "cssls", -- CSS
    -- "html", -- HTML
    -- "jsonls", -- JSON
    -- "yamlls", -- YAML
    -- "marksman", -- Markdown
    -- "bashls", -- Bash
    -- "clangd", -- C/C++
    -- "gopls", -- Go
  },
  automatic_installation = true, -- 자동 설치 활성화
  automatic_enable = true,      -- 자동 활성화
  max_concurrent_installers = 2, -- 동시에 설치할 수 있는 서버 수 제한
  handlers = {
    -- 기본 핸들러: 모든 서버에 대해 기본 설정 적용
    function(server_name)
      -- nvim-lspconfig.lua에서 이미 설정된 서버는 건너뛰기
      local servers = require("config.nvim-lspconfig").get_servers()
      if servers[server_name] then
        -- 이미 설정된 서버는 건너뛰기 (중복 방지)
        return
      end

      -- 기본 설정으로 서버 시작
      vim.lsp.config(server_name, {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
    end,
  },
})
