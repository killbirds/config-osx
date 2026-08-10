return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  -- config/nvim-lint.lua가 만드는 명령은 전부 여기 있어야 한다.
  -- 빠지면 파일 인자 없이 nvim만 띄운 상태에서 그 명령이 존재하지 않는다
  -- (BufReadPre로도 로드되므로 파일을 열면 생기지만, 그건 우연에 기대는 것이다).
  cmd = { "Lint", "LintRecheck" },
  config = function()
    require("config.nvim-lint")
  end,
}
