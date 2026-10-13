return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- 키가 둘 이상인 <leader> 접두어에 이름을 붙인다. 없으면 "+N keymaps"로만 보인다.
    -- 새 접두어를 만들면 여기에도 추가할 것.
    spec = {
      { "<leader>b", group = "buffer" },
      { "<leader>d", group = "diagnostics" },
      { "<leader>f", group = "find / format" },
      { "<leader>h", group = "git hunk" },
      { "<leader>L", group = "LSP" },
      { "<leader>m", group = "multicursor" },
      { "<leader>t", group = "toggle / terminal / tree" },
      { "<leader>x", group = "trouble" },
      { "<leader>z", group = "fold" },
    },
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
