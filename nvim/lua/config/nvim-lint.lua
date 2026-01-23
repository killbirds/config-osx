local lint = require("lint")

-- 사용자 설정 옵션
local config = {
  -- 지원하는 파일 타입
  filetypes = {
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "python",
    "lua",
    "rust",
    "scala",
  },

  -- 지원하는 파일 패턴
  patterns = { "*.js", "*.ts", "*.jsx", "*.tsx", "*.py", "*.lua", "*.rs", "*.scala" },

  -- 디바운스 설정 (ms)
  debounce = {
    buffer_enter = 1000,    -- 버퍼 진입 시 지연 시간
    diagnostic_changed = 300, -- 진단 변경 시 지연 시간
  },

  -- Quickfix 설정
  quickfix = {
    auto_open = true,                          -- 자동으로 quickfix 창 열기 여부
    min_severity = vim.diagnostic.severity.WARN, -- 최소 심각도 수준
  },

  -- 자동 실행 설정
  auto_lint = {
    on_enter = true, -- 버퍼 진입 시 린팅
    on_save = true, -- 저장 시 린팅
  },
}

-- 타이머 관리 모듈화
local timers = {
  buffer = {},     -- 버퍼별 타이머
  diagnostic = nil, -- 진단 타이머
}

-- 타이머 생성 및 시작 헬퍼 함수
function timers.start(timer_type, id, callback)
  -- 기존 타이머 정리
  timers.stop(timer_type, id)

  -- 새 타이머 생성
  local timer = vim.uv.new_timer()
  if not timer then
    return
  end

  -- 타이머 저장
  if timer_type == "buffer" then
    timers.buffer[id] = timer
  else -- diagnostic
    timers.diagnostic = timer
  end

  -- 타이머 시작
  local debounce_time = timer_type == "buffer" and config.debounce.buffer_enter or config.debounce.diagnostic_changed

  timer:start(
    debounce_time,
    0,
    vim.schedule_wrap(function()
      -- 콜백 실행
      callback()

      -- 타이머 정리
      timers.stop(timer_type, id)
    end)
  )

  return timer
end

-- 타이머 정지 및 정리 헬퍼 함수
function timers.stop(timer_type, id)
  local timer = nil

  if timer_type == "buffer" then
    timer = timers.buffer[id]
    if timer then
      timers.buffer[id] = nil
    end
  else -- diagnostic
    timer = timers.diagnostic
    if timer then
      timers.diagnostic = nil
    end
  end

  if timer and not timer:is_closing() then
    timer:stop()
    timer:close()
  end
end

-- 파일 타입별 린터 설정
lint.linters_by_ft = {
  python = { "ruff" },           -- Python 린팅 (ruff)
  lua = { "luacheck" },          -- Lua 린팅
  rust = { "clippy" },           -- Rust 린팅 (cargo clippy)
  scala = { "scalafix" },        -- Scala 린팅 (scalafix)
}

-- 커스텀 린터 설정 (선택적)
lint.linters.eslint = {
  name = "eslint",                                                          -- 린터 이름
  cmd = "eslint",                                                           -- 실행 명령어
  args = { "--format", "json", "--stdin", "--stdin-filename", "%filepath" }, -- JSON 출력 설정
  stream = "stdout",                                                        -- 출력 스트림
  ignore_exitcode = true,                                                   -- 종료 코드 무시 (에러가 있어도 계속 진행)
  env = {
    ESLINT_USE_FLAT_CONFIG = "true",                                        -- eslint.config.mjs 파일을 인식하기 위한 환경 변수
  },
}

lint.linters.luacheck = {
  name = "luacheck",
  cmd = "luacheck",
  args = { "--formatter", "plain", "--codes", "--ranges", "--filename", "%filepath", "-" },
  stream = "stdout",
}

lint.linters.scalafix = {
  name = "scalafix",
  cmd = "scalafix",
  args = { "--check", "%filepath" },
  stream = "stdout",
  ignore_exitcode = true,
  stdin = false,
  condition = function()
    return vim.fn.executable("scalafix") == 1
  end,
  parser = require("lint.parser").from_errorformat("%f:%l:%c: %m,%f:%l: %m", {
    source = "scalafix",
    severity = vim.diagnostic.severity.WARN,
  }),
}

lint.linters.ruff = {
  name = "ruff",
  cmd = "ruff",
  args = { "check", "--output-format=text", "--quiet", "%filepath" },
  stream = "stdout",
  ignore_exitcode = true,
  stdin = false,
  condition = function()
    return vim.fn.executable("ruff") == 1
  end,
  parser = require("lint.parser").from_errorformat("%f:%l:%c: %t%n %m", {
    source = "ruff",
  }),
}

-- 진단 결과를 quickfix에 표시하는 함수 (현재 프로젝트의 진단만 표시)
local function update_quickfix()
  -- 현재 작업 디렉토리(프로젝트 루트) 가져오기
  local cwd = vim.fn.getcwd()

  -- 모든 열린 버퍼에서 진단 수집
  local all_diagnostics = {}
  local buffers = vim.api.nvim_list_bufs()

  -- 성능 최적화: 각 버퍼별로 진단 캐시
  local diagnostic_cache = {}

  for _, buf in ipairs(buffers) do
    if vim.api.nvim_buf_is_valid(buf) then
      local buf_name = vim.api.nvim_buf_get_name(buf)

      -- 파일이 현재 프로젝트 내에 있는지 확인
      if buf_name and buf_name:find(cwd, 1, true) then
        -- 진단이 변경되지 않았으면 캐시된 결과 사용
        if not diagnostic_cache[buf] then
          diagnostic_cache[buf] = vim.diagnostic.get(buf, {
            severity = { min = config.quickfix.min_severity },
          })
        end

        local buf_diagnostics = diagnostic_cache[buf]
        for _, diag in ipairs(buf_diagnostics) do
          table.insert(all_diagnostics, {
            bufnr = buf,
            lnum = diag.lnum + 1,
            col = diag.col + 1,
            text = diag.message .. " [" .. vim.fn.fnamemodify(buf_name, ":~:.") .. "]",
            type = (diag.severity == vim.diagnostic.severity.ERROR and "E" or "W"),
            severity = diag.severity, -- 정렬을 위해 원래 심각도 저장
          })
        end
      end
    end
  end

  -- 심각도에 따라 정렬 (ERROR가 WARN보다 위에 표시)
  table.sort(all_diagnostics, function(a, b)
    -- 현재 열려있는 파일 우선 (현재 버퍼 가져오기)
    local current_buf = vim.api.nvim_get_current_buf()
    if a.bufnr == current_buf and b.bufnr ~= current_buf then
      return true
    elseif a.bufnr ~= current_buf and b.bufnr == current_buf then
      return false
    end

    -- 먼저 심각도로 정렬 (ERROR가 WARN보다 우선)
    if a.severity ~= b.severity then
      return a.severity < b.severity
    end

    -- 같은 심각도일 경우 파일명으로 정렬
    if a.bufnr ~= b.bufnr then
      local a_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(a.bufnr), ":~:.")
      local b_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b.bufnr), ":~:.")
      return a_name < b_name
    end

    -- 같은 파일 내에서는 줄 번호로 정렬
    if a.lnum ~= b.lnum then
      return a.lnum < b.lnum
    end

    -- 같은 줄이면 열 번호로 정렬
    return a.col < b.col
  end)

  -- 정렬 후 severity 필드 제거 (quickfix에서 사용하지 않음)
  for _, item in ipairs(all_diagnostics) do
    item.severity = nil
  end

  -- 현재 윈도우 ID 저장
  local current_win = vim.api.nvim_get_current_win()

  -- pcall을 사용해 안전하게 quickfix 목록 업데이트
  local ok, err = pcall(function()
    -- 무조건 목록 초기화 (진단이 없는 경우에도)
    vim.fn.setqflist(all_diagnostics)

    if #all_diagnostics > 0 then
      -- 진단이 있으면 quickfix 창 열기
      if config.quickfix.auto_open then
        vim.cmd("cwindow")
      end
    else
      -- 진단이 없으면 quickfix 창 닫기
      vim.cmd("cclose")
    end
  end)

  -- 에러가 있을 경우 로그 출력
  if not ok then
    vim.notify("Quickfix 업데이트 오류: " .. tostring(err), vim.log.levels.ERROR)
  end

  -- 에러가 없고 현재 윈도우가 여전히 유효할 경우에만 원래 윈도우로 포커스 돌려놓기
  if ok and vim.api.nvim_win_is_valid(current_win) then
    vim.api.nvim_set_current_win(current_win)
  end
end

-- 자동 린팅 및 Quickfix 출력 설정 - 파일 저장 시에만 실행
if config.auto_lint.on_save then
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = config.patterns,
    group = vim.api.nvim_create_augroup("Linting", { clear = true }),
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      local ft = vim.bo.filetype

      -- 지원되는 파일 타입에 대해서만 타이머 생성
      if vim.tbl_contains(config.filetypes, ft) then
        -- 타이머 생성 및 시작 (저장 후 지연된 린팅 실행)
        timers.start("buffer", bufnr, function()
          if vim.api.nvim_buf_is_valid(bufnr) then
            lint.try_lint()
            update_quickfix()
          end
        end)
      end
    end,
  })
end

-- 버퍼 진입 시에 린팅 적용
if config.auto_lint.on_enter then
  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = config.patterns,
    group = vim.api.nvim_create_augroup("LintOnEnter", { clear = true }),
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()

      -- 파일이 닫혀 있으면 실행 중지
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      -- 타이머 생성 및 시작
      timers.start("buffer", bufnr, function()
        if vim.api.nvim_buf_is_valid(bufnr) then
          lint.try_lint()
        end
      end)
    end,
  })
end

-- 버퍼가 닫힐 때 타이머 정리
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(ev)
    timers.stop("buffer", ev.buf)
  end,
})

-- 파일 수정 후 또는 저장하지 않은 상태에서도 진단 결과 반영
vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = vim.api.nvim_create_augroup("DiagnosticQuickfix", { clear = true }),
  callback = function()
    -- vim.in_fast_event()로 빠른 이벤트 내에 있는지 확인
    if vim.in_fast_event() then
      return
    end

    -- vim.api.nvim_get_mode()를 통해 현재 모드 확인
    local mode = vim.api.nvim_get_mode().mode
    if mode:find("c") or mode:find("t") then
      -- 명령 모드나 터미널 모드에서는 실행하지 않음
      return
    end

    -- 현재 버퍼 파일 타입 확인
    local ft = vim.bo.filetype
    if vim.tbl_contains(config.filetypes, ft) then
      -- 타이머 생성 및 시작
      timers.start("diagnostic", nil, function()
        -- pcall로 안전하게 실행
        local ok, err = pcall(update_quickfix)
        if not ok then
          vim.notify("진단 업데이트 오류: " .. tostring(err), vim.log.levels.ERROR)
        end
      end)
    end
  end,
})

-- Quickfix 창에서 'o' 키로 항목 열기
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf", -- Quickfix 창에 적용
  group = vim.api.nvim_create_augroup("QuickfixKeymap", { clear = true }),
  callback = function()
    vim.keymap.set("n", "o", "<CR>", {
      buffer = true,
      silent = true,
      desc = "Open Quickfix item",
    })
  end,
})

-- 편의 기능: 린팅 수동 실행 명령어 추가
vim.api.nvim_create_user_command("Lint", function()
  lint.try_lint()
  update_quickfix()
end, { desc = "수동으로 린팅 실행" })

-- 상태 표시줄 함수 추가 (lualine 등에서 사용 가능)
local function lint_status()
  if vim.bo.buftype ~= "" or not vim.tbl_contains(config.filetypes, vim.bo.filetype) then
    return ""
  end

  -- 현재 버퍼의 진단 정보 가져오기
  local diagnostics = vim.diagnostic.get(0)
  if #diagnostics == 0 then
    return "✓" -- 이상 없음
  end

  -- 오류, 경고, 정보, 힌트 개수 집계
  local counts = {
    errors = 0,
    warnings = 0,
    info = 0,
    hints = 0,
  }

  for _, diagnostic in ipairs(diagnostics) do
    if diagnostic.severity == vim.diagnostic.severity.ERROR then
      counts.errors = counts.errors + 1
    elseif diagnostic.severity == vim.diagnostic.severity.WARN then
      counts.warnings = counts.warnings + 1
    elseif diagnostic.severity == vim.diagnostic.severity.INFO then
      counts.info = counts.info + 1
    elseif diagnostic.severity == vim.diagnostic.severity.HINT then
      counts.hints = counts.hints + 1
    end
  end

  -- 상태 문자열 만들기
  local status = {}
  if counts.errors > 0 then
    table.insert(status, string.format("E:%d", counts.errors))
  end
  if counts.warnings > 0 then
    table.insert(status, string.format("W:%d", counts.warnings))
  end
  if counts.info > 0 then
    table.insert(status, string.format("I:%d", counts.info))
  end
  if counts.hints > 0 then
    table.insert(status, string.format("H:%d", counts.hints))
  end

  return table.concat(status, " ")
end

-- 글로벌 함수로 노출 (lualine 등에서 사용 가능)
_G.lint_status = lint_status
