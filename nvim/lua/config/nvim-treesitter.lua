local treesitter = require("nvim-treesitter")

local parser_languages = {
  "scala",
  "java",
  "typescript",
  -- tsx는 typescript와 별개 파서/쿼리다. 빠져 있으면 .tsx 파일에서
  -- 파서는 tsx로 잡히는데 queries/tsx/highlights.scm이 설치되지 않아
  -- 구문 강조가 전혀 되지 않는다(get_captures_at_pos가 빈 테이블).
  -- 부수 효과: JSX의 bo.commentstring 메타데이터도 함께 사라져
  -- 내장 gc가 JSX에 `//`를 넣었다.
  "tsx",
  "javascript",
  "rust",
  "toml",
  "python",
  "html",
  "css",
  "lua",
  "query",
  "vimdoc",
  "markdown",
  "markdown_inline",
  "json",
  "yaml",
  "bash",
}

local highlight_disabled_filetypes = {
  log = true,
  csv = true,
  tsv = true,
}

local indent_disabled_languages = {
  python = true,
}

local filetype_line_limits = {
  json = 5000,
}

local max_filesize = 500 * 1024
local max_lines = 10000
local treesitter_group = vim.api.nvim_create_augroup("NvimTreesitterMain", { clear = true })

treesitter.setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

treesitter.install(parser_languages)

local function get_buffer_language(bufnr)
  local filetype = vim.bo[bufnr].filetype
  if filetype == "" then
    return nil
  end

  local ok, language = pcall(vim.treesitter.language.get_lang, filetype)
  if ok and language and language ~= "" then
    return language
  end

  return filetype
end

local function should_disable_highlighting(bufnr)
  local filetype = vim.bo[bufnr].filetype
  if highlight_disabled_filetypes[filetype] then
    return true
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename ~= "" then
    local ok, stats = pcall(vim.uv.fs_stat, filename)
    if ok and stats and stats.size > max_filesize then
      return true
    end
  end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if line_count > max_lines then
    return true
  end

  local filetype_max_lines = filetype_line_limits[filetype]
  if filetype_max_lines and line_count > filetype_max_lines then
    return true
  end

  return false
end

local function configure_buffer(bufnr)
  local language = get_buffer_language(bufnr)
  if not language then
    return
  end

  if should_disable_highlighting(bufnr) then
    pcall(vim.treesitter.stop, bufnr)
    return
  end

  local ok = pcall(vim.treesitter.start, bufnr, language)
  if not ok then
    return
  end

  if indent_disabled_languages[language] then
    return
  end

  vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
  group = treesitter_group,
  pattern = "*",
  callback = function(args)
    configure_buffer(args.buf)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = treesitter_group,
  pattern = "markdown",
  callback = function()
    vim.wo.conceallevel = 2
    vim.wo.concealcursor = "nc"
  end,
})

-- 참고: nvim-treesitter-context 설정이 있었지만 플러그인이 설치되어 있지 않아
-- 동작한 적이 없어 제거함. 필요하면 plugins/editor.lua에
-- "nvim-treesitter/nvim-treesitter-context"를 추가하고 여기서 setup할 것.
