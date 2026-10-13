return {
  "mfussenegger/nvim-lint",
  -- 린터가 있는 filetype에서만 로드한다(config/nvim-lint.lua의 linters_by_ft와 맞출 것).
  -- qf는 그 모듈이 quickfix 창에 거는 'o' 키맵 때문에 포함한다.
  ft = { "python", "lua", "scala", "java", "qf" },
  -- config/nvim-lint.lua가 만드는 명령은 전부 여기 있어야 한다.
  -- 빠지면 해당 filetype 파일을 열기 전에는 그 명령이 존재하지 않는다.
  cmd = { "Lint", "LintRecheck", "Clippy" },
  config = function()
    require("config.nvim-lint")
    -- ft 로드는 첫 버퍼의 BufEnter가 이미 지난 뒤라 진입 시 린트가 돌지 않는다.
    -- 로드한 버퍼에 한 번만 다시 발생시킨다(LintOnEnter 그룹에만).
    pcall(vim.api.nvim_exec_autocmds, "BufEnter", { group = "LintOnEnter", buf = 0 })
  end,
}
