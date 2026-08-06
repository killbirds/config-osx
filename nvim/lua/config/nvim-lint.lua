local lint = require("lint")

-- 사용자 설정 옵션
local config = {
  -- 지원하는 파일 타입
  filetypes = {
    "python",
    "lua",
    "rust",
    "scala",
    "java",
  },

  -- 지원하는 파일 패턴
  patterns = { "*.py", "*.lua", "*.rs", "*.scala", "*.java" },

  -- 디바운스 설정 (ms)
  debounce = {
    buffer_enter = 1000, -- 버퍼 진입 시 지연 시간
    diagnostic_changed = 300, -- 진단 변경 시 지연 시간
  },

  -- Quickfix 설정
  quickfix = {
    -- 진단이 바뀔 때마다 창이 열리고 닫히는 것이 산만하므로 자동 열기는 끈다.
    -- 전용 목록(:Lint로 생성)이 있는 동안은 백그라운드로 갱신된다.
    -- :copen(:chistory로 목록 전환) 또는 <leader>xQ(Trouble)로 확인.
    auto_open = false,
    min_severity = vim.diagnostic.severity.WARN, -- 최소 심각도 수준
  },

  -- 자동 실행 설정
  auto_lint = {
    on_enter = true, -- 버퍼 진입 시 린팅
    on_save = true, -- 저장 시 린팅
  },
}

local function resolve_command(candidates)
  for _, candidate in ipairs(candidates) do
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end

  return nil
end

local scalafix_cmd = resolve_command({
  "scalafix",
  "/opt/homebrew/bin/scalafix",
  "/usr/local/bin/scalafix",
})

local coursier_cmd = resolve_command({
  "coursier",
  "/opt/homebrew/bin/coursier",
  "/usr/local/bin/coursier",
})

local checkstyle_cmd = resolve_command({
  "checkstyle",
  "/opt/homebrew/bin/checkstyle",
  "/usr/local/bin/checkstyle",
})

local luacheck_cmd = resolve_command({
  "/opt/homebrew/bin/luacheck",
  "/usr/local/bin/luacheck",
  "luacheck",
})

local java_checkstyle_config = vim.fn.expand("~/.custom_java_checks.xml")

local function is_linter_runnable(linter)
  if type(linter.condition) == "function" then
    local ok, should_run = pcall(linter.condition)
    if not ok or not should_run then
      return false
    end
  end

  local cmd = linter.cmd
  if type(cmd) == "function" then
    local ok, resolved_cmd = pcall(cmd)
    if not ok or type(resolved_cmd) ~= "string" or resolved_cmd == "" then
      return false
    end
    cmd = resolved_cmd
  end

  return type(cmd) == "string" and vim.fn.executable(cmd) == 1
end

-- upstream try_lint()은 대상 버퍼와 filetype을 **호출 시점의**
-- nvim_get_current_buf() / vim.bo.filetype에서 읽고 bufnr 옵션이 없다
-- (nvim-lint/lua/lint.lua:69의 _resolve_linter_by_ft(vim.bo.filetype),
--  :89의 api.nvim_get_current_buf()).
-- 디바운스 타이머가 늦게 발동하는 동안 다른 버퍼로 이동하면 엉뚱한 버퍼를
-- lint하게 되므로, 캡처한 버퍼를 받아 그 컨텍스트에서 실행한다.
-- (타이머 콜백은 vim.schedule_wrap 안이라 nvim_buf_call이 안전하다)
---@param bufnr? integer 대상 버퍼. nil이면 현재 버퍼.
local function try_lint_safe(bufnr)
  local function run()
    lint.try_lint(nil, {
      filter = function(linter)
        return is_linter_runnable(linter)
      end,
    })
  end

  if bufnr and vim.api.nvim_buf_is_valid(bufnr) and bufnr ~= vim.api.nvim_get_current_buf() then
    vim.api.nvim_buf_call(bufnr, run)
  else
    run()
  end
end

-- 타이머 관리 모듈화
local timers = {
  buffer = {}, -- 버퍼별 타이머
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
  python = { "ruff" }, -- Python 린팅 (ruff)
  lua = { "luacheck" }, -- Lua 린팅
  rust = { "clippy" }, -- Rust 린팅 (cargo clippy)
  scala = (scalafix_cmd or coursier_cmd) and { "scalafix" } or {}, -- Scala 린팅 (scalafix)
  java = { "java_checkstyle" },
}

-- clippy는 cargo clippy를 실행하므로 Cargo 프로젝트가 아닌 단일 .rs 파일에서는 실패하고,
-- cwd 지정이 없으면 Neovim의 cwd에서 실행되어 프로젝트 밖 cwd일 때 Cargo.toml을 못 찾는다.
-- 함수형 정의로 감싸 버퍼 기준 Cargo 루트를 찾아 cwd로 지정하고, 루트가 없으면
-- condition으로 실행을 건너뛴다 (조건 판정은 try_lint_safe의 filter가 수행).
local base_clippy = lint.linters.clippy
lint.linters.clippy = function()
  local cargo_root = vim.fs.root(0, "Cargo.toml")
  return vim.tbl_extend("force", base_clippy, {
    cwd = cargo_root,
    condition = function()
      return cargo_root ~= nil
    end,
  })
end

-- 커스텀 린터 설정
-- 주의: nvim-lint는 args의 문자열을 그대로 전달한다(%filepath 같은 플레이스홀더 치환 없음).
-- 파일명이 필요하면 args에 함수를 넣거나(호출 시점에 평가됨),
-- stdin=false + append_fname(기본값 true)으로 자동으로 덧붙이게 한다.
-- (JS/TS 린팅은 LSP의 eslint 서버가 담당하므로 여기에는 없음)

-- luacheck: 내장 정의를 쓰되 homebrew 경로 해석과 --filename 만 보강
lint.linters.luacheck.cmd = luacheck_cmd or "luacheck"
lint.linters.luacheck.args = {
  "--formatter",
  "plain",
  "--codes",
  "--ranges",
  "--filename",
  function()
    return vim.api.nvim_buf_get_name(0)
  end,
  "-",
}

lint.linters.scalafix = function()
  local cmd = scalafix_cmd
  local args = { "--check" } -- 파일명은 append_fname(stdin=false 기본값)으로 자동 추가됨

  if not cmd and coursier_cmd then
    cmd = coursier_cmd
    args = { "launch", "scalafix", "--", "--check" }
  end

  cmd = cmd or "scalafix"

  return {
    name = "scalafix",
    cmd = cmd,
    args = args,
    stream = "stdout",
    ignore_exitcode = true,
    stdin = false,
    parser = require("lint.parser").from_errorformat("%f:%l:%c: %m,%f:%l: %m", {
      source = "scalafix",
      severity = vim.diagnostic.severity.WARN,
    }),
  }
end

lint.linters.java_checkstyle = function()
  return {
    name = "java_checkstyle",
    cmd = checkstyle_cmd or "checkstyle",
    args = { "-f", "sarif", "-c", java_checkstyle_config },
    stream = "stdout",
    ignore_exitcode = true,
    stdin = false,
    append_fname = true,
    condition = function()
      return checkstyle_cmd ~= nil and vim.uv.fs_stat(java_checkstyle_config) ~= nil
    end,
    parser = require("lint.parser").for_sarif({
      source = "checkstyle",
    }),
  }
end

-- ruff는 nvim-lint 내장 린터를 그대로 사용한다.
-- (기존 커스텀 정의는 치환되지 않는 %filepath 인자와 최신 ruff에서 제거된
--  --output-format=text 때문에 항상 실패했음)

-- 진단 quickfix 목록 타이틀 (다른 용도의 목록과 구분하는 식별자)
local QF_TITLE = "Diagnostics (nvim-lint)"

-- quickfix 스택 전체에서 우리 목록의 id를 찾는다 (없으면 nil).
-- 현재 목록만 검사하면 :grep 등 다른 목록이 현재일 때 우리 목록이 stale해지므로,
-- vim.diagnostic.setqflist와 같은 방식으로 title 기반 id를 추적해
-- 현재가 아닌 목록도 제자리 갱신한다.
local function find_qflist_id()
  for nr = 1, vim.fn.getqflist({ nr = "$" }).nr do
    local info = vim.fn.getqflist({ nr = nr, id = 0, title = 1 })
    if info.title == QF_TITLE then
      return info.id
    end
  end
  return nil
end

-- 진단 결과를 quickfix에 표시하는 함수 (현재 프로젝트의 진단만 표시)
-- opts.create가 참이면(수동 :Lint) 전용 목록이 없을 때 새로 만든다.
-- 백그라운드 갱신은 기존 전용 목록의 제자리 갱신만 한다 — 새 목록을 만들면
-- 사용자가 보던 현재 목록(:grep 등)을 스택에서 밀어내기 때문이다.
local function update_quickfix(opts)
  opts = opts or {}

  local qf_id = find_qflist_id()
  if not qf_id and not opts.create and vim.fn.getqflist({ nr = "$" }).nr ~= 0 then
    return
  end

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

  -- 현재 윈도우 ID 저장 (cwindow가 포커스를 옮길 수 있음)
  local current_win = vim.api.nvim_get_current_win()

  -- 우리 목록이 있으면 id로 지정해 제자리 갱신('u': 현재 선택 위치 보존 시도),
  -- 없으면 새 목록 생성(' '). 다른 용도의 현재 목록은 건드리지 않으며,
  -- 진단이 없어도 창을 강제로 닫지 않는다 (사용자가 연 창은 사용자가 닫는다).
  local ok, err = pcall(vim.fn.setqflist, {}, qf_id and "u" or " ", {
    id = qf_id,
    title = QF_TITLE,
    items = all_diagnostics,
  })

  if not ok then
    vim.notify("Quickfix 업데이트 오류: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  if config.quickfix.auto_open and #all_diagnostics > 0 then
    -- 우리 목록이 현재 목록일 때만 창을 연다 (다른 목록 사용을 방해하지 않음)
    if not qf_id or vim.fn.getqflist({ id = 0 }).id == qf_id then
      vim.cmd("cwindow")
      if vim.api.nvim_win_is_valid(current_win) then
        vim.api.nvim_set_current_win(current_win)
      end
    end
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
            try_lint_safe(bufnr)
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
          try_lint_safe(bufnr)
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
  try_lint_safe()
  -- 수동 실행은 전용 quickfix 목록이 없으면 새로 만든다
  update_quickfix({ create = true })
end, { desc = "수동으로 린팅 실행" })

-- 참고: 상태줄 진단 표시는 lualine의 diagnostics 컴포넌트가 담당한다.
-- (이전의 _G.lint_status는 같은 vim.diagnostic 정보를 중복 표시했음)
