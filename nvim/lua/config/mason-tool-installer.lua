require("mason-tool-installer").setup({
  ensure_installed = {
    -- 필수 린터만 포함
    "luacheck", -- Lua
    "flake8", -- Python

    -- 필수 포매터만 포함
    "stylua", -- Lua
    "prettier", -- JavaScript/TypeScript/HTML/CSS/JSON

    -- 필요할 때 주석 해제
    -- "black", -- Python
    -- "gofumpt", -- Go
  },
  auto_update = false,          -- 자동 업데이트 비활성화
  run_on_start = false,         -- 시작 시 실행하지 않고 필요할 때만 수동으로 실행
  start_delay = 10000,          -- 지연 시간 10초로 증가 (3초에서 10초로)
  debounce_hours = 48,          -- 최소 48시간 설치/업데이트 시도 간격 (24시간에서 48시간으로)
  max_concurrent_installers = 2, -- 동시 설치 가능한 도구 수 제한 (4에서 2로)
})
