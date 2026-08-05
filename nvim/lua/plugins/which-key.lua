return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  keys = {
    {
      -- which-key 기본 키. Comment.nvim 블록 주석이 쓰고 있어 <leader>K로
      -- 우회했었지만, 플러그인 제거로 <leader>?가 비어서 되돌렸다.
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
