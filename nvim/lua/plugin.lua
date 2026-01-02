-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- 참고: mapleader와 maplocalleader는 init.lua에서 설정됩니다.

-- Setup lazy.nvim with 0.11 optimizations
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "catppuccin" } },
  -- automatically check for plugin updates
  checker = {
    enabled = true,
    frequency = 86400, -- check once a day (0.11 최적화)
  },
  -- Neovim 0.11+ ui 개선 사항 적용
  ui = {
    border = "rounded", -- 0.11에서 winborder와 일관성 유지
    title = "Lazy Plugin Manager",
    backdrop = 80,    -- 배경 어둡게 설정 (0-100)
    -- 0.11에서 개선된 아이콘 지원
    icons = {
      loaded = "●",
      not_loaded = "○",
      cmd = " ",
      config = "",
      event = "",
      ft = " ",
      init = " ",
      keys = " ",
      plugin = " ",
      runtime = " ",
      require = "󰢱 ",
      source = " ",
      start = "",
      task = "✔ ",
      lazy = "󰒲 ",
    },
  },
  performance = {
    -- 0.11 권장 성능 최적화 설정
    cache = {
      enabled = true,
      path = vim.fn.stdpath("cache") .. "/lazy/cache",
      -- 캐시 수명 연장 (기본 7일 -> 30일)
      ttl = 86400 * 30,
    },
    reset_packpath = true, -- 패키지 경로 재설정으로 성능 향상
    rtp = {
      reset = false,
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen", -- 0.11에서 권장하는 비활성화
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        -- 0.11 추가 권장 비활성화 플러그인
        "2html_plugin",
        "getscript",
        "getscriptPlugin",
        "logipat",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
      },
    },
  },
  -- 0.11 호환성 및 최적화 설정
  change_detection = {
    enabled = true,
    notify = false, -- 성능을 위해 알림 비활성화
  },
  -- 0.11 새로운 기능 활용
  dev = {
    path = "~/projects", -- 개발 플러그인 경로
    patterns = {},     -- 개발 모드에서 로드할 패턴
    fallback = false,  -- fallback 비활성화로 성능 향상
  },
})

-- Neovim 0.11 추가 최적화 (분기 불필요)
-- 새로운 LSP 설정 방식 활용
-- 기본 LSP 구성은 config/nvim-lspconfig.lua에서 처리

-- 진단 설정은 config/diagnostics.lua에서 중앙 관리됨

-- Treesitter 비동기 처리 확인
vim.g._ts_force_sync_parsing = false

-- 새로운 snippet 기능 활용 (0.11 기본 매핑)
-- <Tab>과 <S-Tab>은 기본적으로 매핑됨

-- 성능 모니터링을 위한 설정
if vim.env.NVIM_PROFILE then
  vim.cmd("profile start /tmp/nvim-profile.log")
  vim.cmd("profile file *")
  vim.cmd("profile func *")
end
