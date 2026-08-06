return {
  -- Git
  -- fugitive/flog는 트리거가 없으면 startup에 로드된다. 명령으로만 쓰므로 cmd로 미룬다.
  -- 목록은 각 플러그인이 실제로 정의하는 명령에서 뽑았다
  -- (vim-fugitive/plugin/fugitive.vim, vim-flog/plugin/flog.vim).
  {
    "tpope/vim-fugitive",
    -- 목록은 fugitive를 강제 로드한 뒤 nvim_get_commands()로 실제 정의된 것을 뽑았다.
    -- 하나라도 빠지면 그 명령으로는 지연 로드가 트리거되지 않으므로 전부 나열한다.
    cmd = {
      "G",
      "Git",
      "Gedit",
      "Ge",
      "Gsplit",
      "Gvsplit",
      "Gtabedit",
      "Gpedit",
      "Gdrop",
      "Gread",
      "Gr",
      "Gwrite",
      "Gw",
      "Gwq",
      "Gdiffsplit",
      "Gvdiffsplit",
      "Ghdiffsplit",
      "Gclog",
      "GcLog",
      "Gllog",
      "GlLog",
      "Ggrep",
      "Glgrep",
      "Gcd",
      "Glcd",
      "GMove",
      "Gmove",
      "GRename",
      "Grename",
      "GDelete",
      "Gdelete",
      "GRemove",
      "Gremove",
      "GUnlink",
      "GBrowse",
      "Gbrowse",
    },
  },
  {
    "rbong/vim-flog",
    dependencies = "tpope/vim-fugitive",
    cmd = { "Flog", "Flogsplit", "Floggit" },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("config.gitsigns")
    end,
  },
}
