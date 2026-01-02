require("nvim-treesitter.configs").setup({
  modules = {},

  -- 설치할 파서 목록 (0.11 최적화)
  ensure_installed = {
    "scala",
    "typescript",
    "javascript",
    "rust",
    "toml",
    "python",
    "html",
    "css",
    "lua",           -- Lua 추가 (Neovim 설정에 유용)
    "query",         -- Treesitter 쿼리 언어 (플레이그라운드용)
    "vimdoc",        -- Neovim 문서 파서 (0.11에서 개선됨)
    "markdown",      -- 0.11에서 개선된 마크다운 지원
    "markdown_inline", -- 마크다운 인라인 요소 지원
    "json",          -- JSON 지원 추가
    "yaml",          -- YAML 지원 추가
    "bash",          -- Shell script 지원
  },

  -- 0.11 성능 최적화 설정
  sync_install = false, -- 비동기 설치로 시작 시간 단축
  auto_install = true, -- 누락된 파서 자동 설치

  -- 설치 제외 파서 (사용하지 않는 언어)
  ignore_install = { "haskell", "php", "perl" },

  -- 구문 강조 설정 (0.11 비동기 하이라이팅)
  highlight = {
    enable = true,

    -- 0.11 핵심 최적화: 비동기 하이라이팅 활성화
    additional_vim_regex_highlighting = false, -- Vim 기본 하이라이팅 비활성화

    -- 대용량 파일 성능 최적화
    disable = function(lang, buf)
      local max_filesize = 500 * 1024 -- 500KB로 임계값 증가 (0.11 성능 향상으로)
      local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end

      -- 대용량 버퍼 감지
      local line_count = vim.api.nvim_buf_line_count(buf)
      if line_count > 10000 then -- 10000줄 이상
        return true
      end

      return false
    end,
  },

  -- 들여쓰기 설정 (0.11 개선)
  indent = {
    enable = true,
    disable = { "python" }, -- Python은 기본 indent가 더 나을 수 있음
  },

  -- 점진적 선택 설정
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<C-space>", -- vim-visual-multi와 충돌 방지
      node_incremental = "<C-space>",
      node_decremental = "<C-b>",
      scope_incremental = "<C-s>",
    },
  },

  -- 텍스트 객체 설정 (0.11 향상됨)
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- 다음 객체를 미리 탐지
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
        ["ab"] = "@block.outer",
        ["ib"] = "@block.inner",
        -- 0.11 추가 텍스트 객체
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
        ["ad"] = "@conditional.outer",
        ["id"] = "@conditional.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- 점프 리스트에 추가
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
        ["]d"] = "@conditional.outer",
        ["]l"] = "@loop.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
        ["[d"] = "@conditional.outer",
        ["[l"] = "@loop.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
  },
})

-- 0.11 접기 설정 (비동기 접기 지원)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- 0.11 새로운 접기 함수
vim.opt.foldenable = false                           -- 기본적으로 접힌 상태로 시작하지 않음
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99                          -- 파일 열 때 모든 접기 펼쳐진 상태

-- 0.11 Treesitter 성능 최적화 설정
-- 비동기 파싱 활성화
vim.g._ts_force_sync_parsing = false

-- 0.11 핵심 성능 설정
local ts_config = {
  -- 비동기 처리 최적화
  async_timeout = 400, -- 비동기 타임아웃 (ms)
  max_lines = 50000,  -- 최대 처리 라인 수

  -- 쿼리 캐싱 강화 (0.11 새 기능)
  query_cache_enabled = true,
  query_cache_max_size = 100, -- 캐시할 쿼리 최대 개수

  -- 메모리 최적화
  memory_limit = 64 * 1024 * 1024, -- 64MB 메모리 제한
  gc_frequency = 100,             -- 가비지 컬렉션 빈도
}

-- TreeSitter 전역 설정 적용
for key, value in pairs(ts_config) do
  vim.g["treesitter_" .. key] = value
end

-- 마크다운 파일에서 0.11 새 기능 활용
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- 0.11에서 개선된 conceallevel 설정
    vim.wo.conceallevel = 2
    vim.wo.concealcursor = "nc" -- normal과 command 모드에서만 conceal

    -- 코드 블록 펜스 라인 수직 숨김 활성화
    if vim.b.ts_highlight then
      vim.b.ts_markdown_conceals = true
    end
  end,
})

-- 성능 모니터링 (개발 환경에서만)
if vim.env.NVIM_TS_DEBUG then
  vim.api.nvim_create_autocmd("User", {
    pattern = "TSHighlightPerformance",
    callback = function(args)
      local data = args.data
      if data.duration > 50 then -- 50ms 이상 걸린 경우 경고
        vim.notify(
          string.format("Treesitter highlighting took %dms for %s", data.duration, data.filetype),
          vim.log.levels.WARN
        )
      end
    end,
  })
end

-- TreesitterContext 설정 (있는 경우에만)
local has_context, ts_context = pcall(require, "treesitter-context")
if has_context then
  ts_context.setup({
    enable = true,
    max_lines = 4,         -- 0.11 최적화: 3줄에서 4줄로 증가
    min_window_height = 20,
    multiline_threshold = 3, -- 여러 줄 컨텍스트 표시 임계값 감소
    trim_scope = "inner",
    mode = "cursor",       -- 0.11에서 권장하는 모드
    separator = nil,       -- 구분선 비활성화 (성능 향상)
  })
end

-- 0.11 추가 최적화: 파일 타입별 특별 처리
local optimize_filetypes = {
  -- 대용량 파일이 흔한 파일 타입들
  json = { max_lines = 5000 },
  log = { disable_highlight = true },
  csv = { disable_highlight = true },
  tsv = { disable_highlight = true },
}

for filetype, config in pairs(optimize_filetypes) do
  vim.api.nvim_create_autocmd("FileType", {
    pattern = filetype,
    callback = function()
      if config.disable_highlight then
        vim.treesitter.stop()
      elseif config.max_lines then
        local line_count = vim.api.nvim_buf_line_count(0)
        if line_count > config.max_lines then
          vim.treesitter.stop()
        end
      end
    end,
  })
end
