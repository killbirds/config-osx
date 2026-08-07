-- 이 플러그인은 **수동 전용**으로 쓴다. 자동 설치는 의도적으로 켜지 않는다.
-- plugins/lsp.lua에서 cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsClean" }
-- 로만 lazy-load 되므로, 그 명령을 치기 전에는 플러그인 자체가 로드되지 않는다.
-- (그래서 run_on_start를 켜도 VimEnter autocmd 등록 시점을 이미 지나 있어 소용없다.
--  자동화하려면 lazy 트리거부터 바꿔야 한다.)
--
-- 새 머신 세팅 순서는 README의 Neovim 설치 절차 참고: nvim 실행 -> :MasonToolsInstall
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
  -- debounce_hours는 설정하지 않는다(기본 nil = 디바운스 없음).
  -- :MasonToolsInstall은 check_install(force_update = false)로 호출되어
  -- debounce_hours의 적용 대상이고, can_run()이 마지막 실행 이후 그 시간이
  -- 지나지 않았으면 **아무 알림 없이 그냥 return** 한다.
  -- 수동 실행이 유일한 설치 경로인 이 구성에서는 그게 곧 "명령이 조용히 무시됨"이다.
  -- (게다가 can_run은 첫 호출에 타임스탬프를 먼저 써서, 설치가 중간에 실패한 뒤
  --  다시 쳐도 무시된다. 우회하려면 debounce를 무시하는 :MasonToolsUpdate를 써야 했다)
  -- max_concurrent_installers는 이 플러그인이 아니라 mason.nvim의 옵션이다.
  -- config/mason.lua의 require("mason").setup()에서 설정한다.
})
