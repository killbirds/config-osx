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

-- 명령 해석은 **린터 정의가 호출되는 시점**(= 린트 시점)에 한다.
-- 모듈 로드 시점(BufReadPre)에 해석하면 mason이 vim.env.PATH를 prepend하기 전일 수 있어
-- mason에만 설치된 도구를 못 찾는다. 그때 결과를 굳혀 버리면 이후로 영원히 못 찾는다.
local function scalafix_command()
  return resolve_command({
    "scalafix",
    "/opt/homebrew/bin/scalafix",
    "/usr/local/bin/scalafix",
  })
end

local function coursier_command()
  return resolve_command({
    "coursier",
    "/opt/homebrew/bin/coursier",
    "/usr/local/bin/coursier",
  })
end

local function checkstyle_command()
  return resolve_command({
    "checkstyle",
    "/opt/homebrew/bin/checkstyle",
    "/usr/local/bin/checkstyle",
  })
end

-- Lua는 selene을 쓴다(luacheck 아님).
-- luacheck는 mason이 luarocks로 설치하면서 시스템 Lua 인터프리터 경로를 셸 래퍼에
-- 하드코딩하므로 Homebrew lua가 올라갈 때마다 조용히 깨졌다(실측 2회: lua5.4 소멸로
-- exit 126, luacheck 1.1.0을 Lua 5.5로 실행해 exit 1). mason 레지스트리 최신도
-- 1.1.0이라 버전을 올려 해결할 수 없다. selene은 단일 Rust 바이너리다.
-- 기준은 nvim/selene.toml + nvim/neovim.yml이 갖고 있다.

local java_checkstyle_config = vim.fn.expand("~/.custom_java_checks.xml")

-- vim.fn.executable()로는 "파일은 실행 가능한데 실행하면 바로 죽는" 래퍼를 잡을 수 없다.
-- 실측한 두 가지 실패가 모두 그랬고, 둘 다 진단 0건과 구분되지 않았다:
--   1) mason luacheck 래퍼가 사라진 lua5.4를 exec  -> exit 126, stdout 없음
--   2) luacheck 1.1.0을 Lua 5.5로 실행            -> exit 1,   stdout 없음
--      ("attempt to assign to const variable" — 업스트림 비호환)
-- 그래서 종료 코드 목록(126/127)으로 판정하면 2번을 놓친다.
-- 대신 "정상 도구는 --version에 exit 0과 stdout을 낸다"를 기준으로 삼는다.
-- 실측 확인: checkstyle / scalafix / coursier / cargo / ruff / stylua 전부 그렇다.
-- 명령별로 한 번만 판정하고 결과를 캐시한다(:LintRecheck로 초기화).
--
-- 프로브는 **비동기**로 돌린다. `:wait()`로 동기 대기하면 린트 시점에 UI가 멈춘다
-- (실측 단독 소요: selene/scalafix/cargo 0.03초, checkstyle 0.22초 — JVM 기동).
-- 결과가 나오기 전에는 "실행 가능"으로 보아 이전과 같이 린트를 시도하고,
-- 프로브가 실패로 판정하면 그때 경고를 띄우고 이후 호출부터 건너뛴다.
-- 조용히 죽는 것만 막으면 되므로 첫 회 한 번이 늦게 판정되는 것은 문제가 아니다.
local probe_cache = {}
local probe_running = {}

local function start_probe(cmd)
  if probe_running[cmd] then
    return
  end
  probe_running[cmd] = true

  local ok = pcall(function()
    vim.system({ cmd, "--version" }, { text = true }, function(result)
      probe_running[cmd] = nil

      local runnable = true
      local reason
      if result.code ~= 0 or (result.stdout or "") == "" then
        runnable = false
        reason = string.format("`%s --version`이 실패했습니다 (exit %s)", cmd, tostring(result.code))
        local stderr = (result.stderr or ""):gsub("%s+$", "")
        if stderr ~= "" then
          reason = reason .. ": " .. vim.split(stderr, "\n")[1]
        end
      end

      probe_cache[cmd] = runnable

      if not runnable then
        vim.schedule(function()
          vim.notify(
            string.format("린터 '%s'를 건너뜁니다 — %s", cmd, reason),
            vim.log.levels.WARN,
            { title = "nvim-lint" }
          )
        end)
      end
    end)
  end)

  -- spawn 자체가 실패하면(실행 파일이 없거나 실행 불가) 즉시 판정한다
  if not ok then
    probe_running[cmd] = nil
    probe_cache[cmd] = false
    vim.schedule(function()
      vim.notify(
        string.format("린터 '%s'를 건너뜁니다 — 실행할 수 없습니다", cmd),
        vim.log.levels.WARN,
        { title = "nvim-lint" }
      )
    end)
  end
end

local function can_actually_run(cmd)
  local cached = probe_cache[cmd]
  if cached ~= nil then
    return cached
  end

  -- 아직 판정 전이면 프로브만 걸어 두고 이번에는 통과시킨다
  start_probe(cmd)
  return true
end

-- 프로브 캐시를 비워 재판정하게 한다 (도구를 다시 설치한 뒤 쓰면 된다)
local function reset_probe_cache()
  probe_cache = {}
  probe_running = {}
end

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

  if type(cmd) ~= "string" or vim.fn.executable(cmd) ~= 1 then
    return false
  end

  return can_actually_run(cmd)
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
-- 주의: 이 목록을 **로드 시점의** executable() 결과로 가리지 마라.
-- 이 모듈은 BufReadPre에 로드되는데 mason이 vim.env.PATH를 prepend하는 시점보다
-- 앞설 수 있다. 그러면 mason에만 설치된 도구(selene, ruff 등)가 그 순간 안 보여서
-- 목록이 조용히 빈 테이블이 되고, 나중에 PATH가 갖춰져도 영원히 린트되지 않는다.
-- (실측: `lua = selene_cmd and {"selene"} or {}` -> linters_by_ft.lua = {} 인데
--  같은 세션에서 executable("selene") = 1)
-- 실행 가능 여부는 try_lint_safe의 filter(is_linter_runnable)가 **린트 시점에** 본다.
lint.linters_by_ft = {
  python = { "ruff" }, -- Python 린팅 (ruff)
  lua = { "selene" }, -- Lua 린팅 (selene)
  rust = { "clippy" }, -- Rust 린팅 (cargo clippy)
  scala = { "scalafix" }, -- Scala 린팅 (scalafix, 없으면 coursier launch)
  java = { "java_checkstyle" },
}

-- clippy는 cargo clippy를 실행하므로 Cargo 프로젝트가 아닌 단일 .rs 파일에서는 실패하고,
-- cwd 지정이 없으면 Neovim의 cwd에서 실행되어 프로젝트 밖 cwd일 때 Cargo.toml을 못 찾는다.
-- 함수형 정의로 감싸 버퍼 기준 Cargo 루트를 찾아 cwd로 지정하고, 루트가 없으면
-- condition으로 실행을 건너뛴다 (조건 판정은 try_lint_safe의 filter가 수행).
local base_clippy = lint.linters.clippy
lint.linters.clippy = function()
  local cargo_root = vim.fs.root(0, "Cargo.toml")
  -- lint.linters[name]의 선언 타입이 `fun():lint.Linter|lint.Linter` 유니온이라
  -- lua_ls가 table 분기임을 증명하지 못해 경고가 난다. 실제로는 내장 clippy가
  -- table이고(확인함) :Lint도 정상 동작하므로 경고만 억제한다.
  ---@diagnostic disable-next-line: param-type-mismatch
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

-- selene: 내장 정의(stdin + --display-style json)를 그대로 쓰되 실행 위치만 잡아준다.
-- selene은 selene.toml을 찾지 못하면 실행을 거부하고, 설정 탐색은 **cwd 기준**이다.
-- nvim의 cwd가 다른 곳일 때 ~/.config/nvim/lua/*.lua를 열면 설정을 못 찾아 실패하므로,
-- 버퍼 기준으로 selene.toml을 찾아 cwd로 넘긴다. 못 찾으면 건너뛴다
-- (clippy가 Cargo.toml 루트를 다루는 방식과 같다. 설정이 없는 프로젝트에서
--  선택되지 않은 규칙으로 잡음을 내지 않는 쪽이 낫다).
local base_selene = lint.linters.selene
lint.linters.selene = function()
  local selene_root = vim.fs.root(0, { "selene.toml" })
  ---@diagnostic disable-next-line: param-type-mismatch
  return vim.tbl_extend("force", base_selene, {
    cmd = "selene",
    cwd = selene_root,
    condition = function()
      return selene_root ~= nil
    end,
  })
end

lint.linters.scalafix = function()
  local cmd = scalafix_command()
  local args = { "--check" } -- 파일명은 append_fname(stdin=false 기본값)으로 자동 추가됨

  if not cmd then
    local coursier = coursier_command()
    if coursier then
      cmd = coursier
      args = { "launch", "scalafix", "--", "--check" }
    end
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
  local checkstyle = checkstyle_command()
  return {
    name = "java_checkstyle",
    cmd = checkstyle or "checkstyle",
    args = { "-f", "sarif", "-c", java_checkstyle_config },
    stream = "stdout",
    -- ignore_exitcode를 켜지 않는다.
    -- ~/.custom_java_checks.xml은 severity=warning이므로 **위반을 찾아도 exit 0**이고
    -- (실측: 진단 4건에 exit 0), nonzero는 설정 로드 실패·크래시일 때만 나온다.
    -- 즉 종료 코드가 곧 "checkstyle이 제대로 돌았는가" 신호다. 예전에는 이걸 무시해서
    -- 설정이 checkstyle 13과 맞지 않아 로드부터 실패하는 동안에도(LineLength가
    -- TreeWalker 하위, JavadocMethod의 scope 속성) 진단 0건처럼 보였다.
    ignore_exitcode = false,
    stdin = false,
    append_fname = true,
    condition = function()
      return checkstyle ~= nil and vim.uv.fs_stat(java_checkstyle_config) ~= nil
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
  -- 전용 목록이 없고 수동 실행(:Lint)도 아니면 아무것도 하지 않는다.
  -- 예전에는 `and vim.fn.getqflist({ nr = "$" }).nr ~= 0` 조건이 붙어 있어서
  -- quickfix 스택이 **비어 있을 때만** 백그라운드 갱신이 새 목록을 만들었다.
  -- 바로 위 주석("백그라운드 갱신은 기존 전용 목록의 제자리 갱신만")과 어긋났고,
  -- lua 파일 하나만 열어도 묻지 않고 quickfix 목록이 생겼다.
  if not qf_id and not opts.create then
    return
  end

  -- 현재 작업 디렉토리(프로젝트 루트) 가져오기.
  -- 경계까지 포함한 접두어로 비교한다. `find(cwd, 1, true)`는 부분 문자열 검사여서
  -- 경로 중간에 cwd 문자열이 들어간 무관한 파일도 통과했고, "/foo" 아래에서
  -- "/other/foo/x.lua" 같은 경로가 프로젝트 내부로 취급될 수 있었다.
  local cwd = vim.fn.getcwd()
  local cwd_prefix = cwd:gsub("/$", "") .. "/"

  local function in_project(path)
    return path == cwd or vim.startswith(path, cwd_prefix)
  end

  -- 모든 열린 버퍼에서 진단 수집
  local all_diagnostics = {}
  local buffers = vim.api.nvim_list_bufs()

  -- 성능 최적화: 각 버퍼별로 진단 캐시
  local diagnostic_cache = {}

  for _, buf in ipairs(buffers) do
    if vim.api.nvim_buf_is_valid(buf) then
      local buf_name = vim.api.nvim_buf_get_name(buf)

      -- 파일이 현재 프로젝트 내에 있는지 확인
      if buf_name and buf_name ~= "" and in_project(buf_name) then
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

-- 실행 불가로 판정해 건너뛴 린터를 다시 판정하게 한다.
-- (:MasonInstall 등으로 도구를 고친 뒤 Neovim을 재시작하지 않고 반영할 때)
vim.api.nvim_create_user_command("LintRecheck", function()
  reset_probe_cache()
  vim.notify("린터 실행 가능 여부를 다시 판정합니다.", vim.log.levels.INFO, { title = "nvim-lint" })
  try_lint_safe()
end, { desc = "린터 실행 가능 여부 재판정 후 린팅" })

-- 참고: 상태줄 진단 표시는 lualine의 diagnostics 컴포넌트가 담당한다.
-- (이전의 _G.lint_status는 같은 vim.diagnostic 정보를 중복 표시했음)
