return {
  -- 기본 편집 도구
  -- (tpope/vim-sensible은 Neovim에서 거의 전부 기본값이라 제거함)
  -- {
  -- 	"kylechui/nvim-surround",
  -- 	event = "VeryLazy", -- 필요할 때만 로드
  -- 	config = true,
  -- },
  -- 주석 토글은 Neovim 0.10+ 내장 기능(gc/gcc)을 사용한다. 키맵은 keys.lua 참고.
  -- (numToStr/Comment.nvim은 2024-06 이후 방치되어 0.11에서 바뀐
  --  vim.treesitter.get_parser 동작 때문에 파서 없는 버퍼에서 깨졌으므로 제거함)
  --
  -- (folke/ts-comments.nvim 제거함. treesitter에 tsx 파서/쿼리를 설치한 뒤로는
  --  내장 gc가 JSX에서도 {/* */}를 올바르게 고른다. jsx 쿼리가 jsx_element에
  --  bo.commentstring 메타데이터를 제공하고, javascript/tsx 쿼리가 이를 상속한다
  --  (site/queries/jsx/highlights.scm:154).
  --  실측: typescriptreact/javascriptreact -> {/* */}, rust/java/js/ts -> //.
  --  vue/svelte/terraform 같은 다른 filetype을 쓰게 되면 다시 필요할 수 있다)

  -- (tpope/vim-repeat 제거함. 설치된 플러그인 중 repeat#set을 부르는 곳은 gitsigns뿐인데
  --  선택 사항이고, gitsigns는 operatorfunc로 `.` 반복을 직접 처리한다. 원래 쓰던
  --  nvim-surround·Comment.nvim이 빠진 뒤로는 하는 일이 없었다)

  -- 멀티커서. vim-visual-multi에서 이전함 — VM은 upstream이 2024-09에 멈췄고
  -- (우리 핀 = upstream HEAD) 자체 모드를 만드는 구조라 blink.cmp/스니펫과
  -- 겉돌 여지가 있다. multicursor.nvim은 Neovim API 기반이고 활발히 유지된다.
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    event = "VeryLazy",
    config = function()
      require("config.multicursor").setup()
    end,
  },

  -- 자동 괄호 닫기
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      -- 성능 최적화 옵션 추가
      check_ts = true, -- treesitter 통합
      disable_filetype = { "fzf", "spectre_panel" },
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
        -- "treesitter" provider는 쓰지 않는다. nvim-treesitter.locals를 require하는데
        -- 우리가 쓰는 nvim-treesitter main 브랜치에는 그 모듈이 없어 항상 빈 결과였다
        -- (illuminate/providers/treesitter.lua의 pcall(require, ...) 실패).
        providers = { "lsp", "regex" },
        delay = 200, -- 100에서 200으로 증가 (성능 개선)
        filetypes_denylist = {
          "NvimTree",
          "fzf",
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

  -- (keaising/im-select.nvim 제거함. 노멀 모드에서 입력기를 영문으로 돌리는 일은
  --  config/input-source.lua가 한다 — 이유는 그 파일 머리말)

  -- (akinsho/toggleterm.nvim 제거함. 업스트림이 2025-03 이후 멈췄고 <C-\> 플로팅 터미널을
  --  쓰지 않았다. 터미널은 Herdr pane과 내장 :terminal(<Leader>tt / <Leader>tv)을 쓴다)

  -- (MeanderingProgrammer/render-markdown.nvim 제거함.
  --  opts.enabled = false로 렌더링이 꺼진 상태였어서 실질 동작이 없었다.
  --  쓰려면 다시 추가하고 enabled = true로 둘 것)
}
