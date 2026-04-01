return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "Lint" },
  config = function()
    require("config.nvim-lint")
  end,
}
