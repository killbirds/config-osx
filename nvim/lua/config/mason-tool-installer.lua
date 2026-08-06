require("mason-tool-installer").setup({
  ensure_installed = {
    -- 필수 린터만 포함
    "luacheck", -- Lua
    "ruff", -- Python

    -- 필수 포매터만 포함
    "stylua", -- Lua
    "prettier", -- JavaScript/TypeScript/HTML/CSS/JSON

    -- 필요할 때 주석 해제
    -- "gofumpt", -- Go
  },
  auto_update = false,
  run_on_start = false,
  debounce_hours = 48,
  -- max_concurrent_installers는 이 플러그인이 아니라 mason.nvim의 옵션이다.
  -- config/mason.lua의 require("mason").setup()에서 설정한다.
})
