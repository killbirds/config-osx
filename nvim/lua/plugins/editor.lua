return {
  -- 기본 편집 도구
  {
    "tpope/vim-sensible",
    lazy = false, -- 기본 설정이므로 즉시 로드
    priority = 1000,
  },
  -- {
  -- 	"kylechui/nvim-surround",
  -- 	event = "VeryLazy", -- 필요할 때만 로드
  -- 	config = true,
  -- },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("config.comment")
    end,
  },
  {
    "mg979/vim-visual-multi",
    branch = "master",
    config = function()
      require("config.vim-visual-multi").setup()
    end,
  },

  -- 자동 괄호 닫기
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      -- 성능 최적화 옵션 추가
      check_ts = true, -- treesitter 통합
      disable_filetype = { "TelescopePrompt", "spectre_panel" },
      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = [=[[%'%"%>%]%)%}%,]]=],
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "Search",
        highlight_grey = "Comment",
      },
    },
  },

  -- 하이라이트된 단어 모두 표시
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("illuminate").configure({
        providers = { "lsp", "treesitter", "regex" },
        delay = 200, -- 100에서 200으로 증가 (성능 개선)
        filetypes_denylist = {
          "NvimTree",
          "Telescope",
          "lazy",
          "mason",
          "help",
          "alpha",
        },
        -- 대용량 파일에서 비활성화
        large_file_cutoff = 2000,
        large_file_overrides = {
          providers = { "lsp" },
        },
      })
    end,
  },

  -- im-select.nvim for Korean input method management
  {
    "keaising/im-select.nvim",
    event = "InsertEnter", -- 입력 시에만 로드
    config = function()
      require("config.im-select")
    end,
  },

  -- 터미널 통합
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" }, -- 명령어 사용시에만 로드
    keys = { [[<c-\>]] },
    opts = {
      open_mapping = [[<c-\>]],
      direction = "float",
      float_opts = {
        border = "curved",
      },
      -- 성능 최적화
      persist_size = true,
      persist_mode = true,
    },
  },

  -- 마크다운 렌더링 (일반 마크다운용)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" }, -- 마크다운 파일에서만 로드
    opts = {
      file_types = { "markdown" },
      enabled = false,
      render_tags = false, -- 태그를 그대로 표시
    },
  },
}
