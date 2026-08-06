local function should_lsp_fallback(bufnr)
  return vim.bo[bufnr].filetype ~= "java"
end

require("conform").setup({
  -- 파일 타입별 포매터 설정
  formatters_by_ft = {
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    java = { "google-java-format" },
    html = { "prettier" },
    css = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    lua = { "stylua" },
    python = { "ruff_format" },
    rust = { "rustfmt" },
    go = { "gofmt" },
  },

  -- 저장 시 자동 포매팅 설정
  format_on_save = function(bufnr)
    -- 특정 파일 유형은 자동 포맷팅에서 제외
    -- scala/sbt는 nvim-metals의 BufWritePre 포맷이 담당하므로 이중 포맷을 막기 위해 제외
    local exclude_filetypes = { "sql", "text", "scala", "sbt" }
    if vim.tbl_contains(exclude_filetypes, vim.bo[bufnr].filetype) then
      return
    end

    return {
      timeout_ms = 500,
      lsp_fallback = should_lsp_fallback(bufnr),
      quiet = true, -- 포맷팅 메시지 숨김
    }
  end,

  -- 포매터별 커스터마이징 (선택적)
  formatters = {
    prettier = {
      command = "prettier",
      args = { "--stdin-filepath", "$FILENAME" },
    },
    ["google-java-format"] = {
      command = "google-java-format",
      args = { "--assume-filename", "$FILENAME", "-" },
      stdin = true,
    },
    stylua = {
      command = "stylua",
    },
    ruff_format = {
      command = "ruff",
      args = { "format", "--quiet", "--stdin-filename", "$FILENAME", "-" },
      stdin = true,
    },
    rustfmt = {
      command = "rustfmt", -- Rust 기본 포매터
      args = { "--edition", "2024", "--emit", "stdout" }, -- Rust 2024 에디션 사용
    },
    gofmt = {
      command = "gofmt",
    },
  },

  -- 포매팅 로그 레벨
  log_level = vim.log.levels.WARN, -- 경고 레벨로 업그레이드

  -- 노티피케이션 설정
  notify_on_error = true, -- 오류 발생 시 알림
})

-- conform의 range 계약은 { start = {row, col}, ["end"] = {row, col} }이며
-- row는 1-based, col은 0-based다 (conform/types.lua의 conform.FormatOpts.range,
-- conform/util.lua:65-67이 range.start[1] / range["end"][2]를 인덱싱).
-- 이전 코드는 { line1, line2 } 평평한 배열을 넘겨
-- "attempt to index field 'start' (a nil value)"로 범위 포맷이 실패했다.
---@param line1 integer 1-based 시작 행
---@param line2 integer 1-based 끝 행
local function line_range(line1, line2)
  local last = vim.api.nvim_buf_get_lines(0, line2 - 1, line2, true)[1] or ""
  return { start = { line1, 0 }, ["end"] = { line2, #last } }
end

local M = {}

-- visual 선택 영역 포맷.
-- conform에 range를 넘기지 않으면 스스로 선택 영역을 계산하지만
-- (conform/init.lua:440-442의 range_from_selection), V 모드에서 start_col = 1을
-- 쓰는 탓에 선택의 **마지막 행이 포맷되지 않는다**(실측: 3~4행 선택 시 3행만 적용).
-- 그래서 마크가 아니라 현재 선택 위치로 range를 직접 만들어 넘긴다.
function M.format_visual()
  local l1, l2 = vim.fn.line("v"), vim.fn.line(".")
  if l1 > l2 then
    l1, l2 = l2, l1
  end
  require("conform").format({
    async = true,
    lsp_fallback = should_lsp_fallback(vim.api.nvim_get_current_buf()),
    range = line_range(l1, l2),
  })
end

-- 수동 포매팅 명령 추가 (선택적)
vim.api.nvim_create_user_command("Format", function(args)
  local bufnr = vim.api.nvim_get_current_buf()
  require("conform").format({
    async = true,
    lsp_fallback = should_lsp_fallback(bufnr),
    range = args.range ~= 0 and line_range(args.line1, args.line2) or nil,
  })
end, { range = true, desc = "Format buffer or range" })

return M
