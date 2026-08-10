-- cache_manager.lua
-- 0.11 최적화된 캐시 및 성능 관리자

local M = {}

-- 디렉토리 스캔 결과 캐시 (성능 최적화)
local dir_cache = {}
local dir_cache_cwd = ""

-- 무시할 디렉토리 패턴 목록 (0.11 확장)
local ignore_patterns = {
  "%.cache",
  "%.git",
  "node_modules",
  "target",
  "dist",
  "%.svelte%-kit",
  "%.next",
  "build",
  "out",
  "coverage",
  "%.yarn",
  "%.pnpm",
  -- 0.11 추가 패턴
  "%.venv",
  "%.env",
  "venv",
  "__pycache__",
  "%.pytest_cache",
  "%.mypy_cache",
  "%.ruff_cache",
  "%.nx",
  "%.nuxt",
  "%.output",
  "%.turbo",
  "%.vercel",
  "%.netlify",
}

-- 0.11 향상된 디렉토리 스캔 (캐싱 지원)
function M.find_ignore_dirs(force_refresh)
  local cwd = vim.fn.getcwd()
  if cwd == "" then
    return {}
  end

  -- 캐시된 결과가 있고 디렉토리가 변경되지 않았으면 재사용
  if not force_refresh and dir_cache_cwd == cwd and dir_cache[cwd] then
    return dir_cache[cwd]
  end

  local ok, handle = pcall(vim.uv.fs_scandir, cwd)
  if not ok or not handle then
    return {}
  end

  local ignore_dirs = {}
  local seen = {} -- 중복 방지

  while true do
    local name, type = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end

    -- 디렉토리일 경우만 처리
    if type == "directory" then
      -- 이미 추가된 디렉토리는 건너뛰기
      if not seen[name] then
        for _, pattern in ipairs(ignore_patterns) do
          if name:match(pattern) then
            table.insert(ignore_dirs, name)
            seen[name] = true
            break
          end
        end
      end
    end
  end

  -- 결과 캐싱
  dir_cache_cwd = cwd
  dir_cache[cwd] = ignore_dirs

  return ignore_dirs
end

-- 이 모듈이 wildignore에 넣은 패턴. cwd가 바뀔 때 되돌리기 위해 기억한다.
-- 예전에는 시작 시 cwd 기준으로 한 번만 append하고, DirChanged는 디렉토리 스캔 캐시만
-- 비웠다. 그래서 새 cwd의 패턴은 추가되지 않고 이전 cwd의 패턴은 회수되지도 않아,
-- 세션이 길어지면 무관한 프로젝트의 패턴이 wildignore에 쌓였다.
local added_patterns = {}

local function remove_added_patterns()
  for _, pattern in ipairs(added_patterns) do
    -- 사용자가 같은 패턴을 직접 넣었을 수도 있으므로 remove 실패는 무시한다
    pcall(function()
      vim.opt.wildignore:remove(pattern)
    end)
  end
  added_patterns = {}
end

-- 0.11 최적화된 파일 시스템 설정
function M.setup_fs_optimizations()
  -- 이전 cwd에서 넣은 패턴을 먼저 걷어낸다
  remove_added_patterns()

  local ignore_dirs = M.find_ignore_dirs()

  -- 기존 wildignore 패턴에 추가 (중복 방지)
  if #ignore_dirs > 0 then
    local existing_patterns = {}
    for _, pattern in ipairs(vim.opt.wildignore:get()) do
      existing_patterns[pattern] = true
    end

    for _, dir in ipairs(ignore_dirs) do
      local pattern1 = "**/" .. dir .. "/**"
      local pattern2 = dir .. "/**"

      -- 중복되지 않은 패턴만 추가 (우리가 넣은 것만 기억해 나중에 회수한다)
      if not existing_patterns[pattern1] then
        vim.opt.wildignore:append(pattern1)
        existing_patterns[pattern1] = true
        table.insert(added_patterns, pattern1)
      end
      if not existing_patterns[pattern2] then
        vim.opt.wildignore:append(pattern2)
        existing_patterns[pattern2] = true
        table.insert(added_patterns, pattern2)
      end
    end
  end

  vim.g.cache_dirs_found = ignore_dirs

  return ignore_dirs
end

-- 0.11 메모리 최적화
function M.setup_memory_optimizations()
  -- 0.11에서 개선된 메모리 관리

  -- LSP 로그 레벨은 init.lua와 nvim-lspconfig.lua에서 중앙 관리됨
  -- 진단 설정은 config/diagnostics.lua에서 중앙 관리됨
end

-- 0.11 버퍼 캐시 최적화
function M.setup_buffer_cache()
  local augroup = vim.api.nvim_create_augroup("CacheManager", { clear = true })

  -- 대용량 파일 감지 및 최적화 (통합된 버전)
  vim.api.nvim_create_autocmd("BufReadPre", {
    group = augroup,
    pattern = "*",
    callback = function(args)
      local bufnr = args.buf
      local filename = vim.api.nvim_buf_get_name(bufnr)

      -- 빈 버퍼는 건너뛰기
      if filename == "" then
        return
      end

      -- 상대 경로를 절대 경로로 변환 (더 안전한 파일 처리)
      local abs_filename = vim.fn.fnamemodify(filename, ":p")
      local ok, stats = pcall(vim.uv.fs_stat, abs_filename)
      if not ok or not stats then
        return
      end

      local file_size = stats.size
      local size_1mb = 1024 * 1024
      local size_5mb = 5 * 1024 * 1024

      -- 1MB 이상 파일은 진단 비활성화 (diagnostics.lua와 통합)
      -- 주의: vim.diagnostic.config의 두 번째 인자는 namespace이며 bufnr가 아니므로
      -- 버퍼별 비활성화에는 vim.diagnostic.enable(false, { bufnr = ... })을 사용한다.
      if file_size > size_1mb then
        vim.b[bufnr]._large_file = true
        vim.diagnostic.enable(false, { bufnr = bufnr })
      end

      -- 5MB 이상 파일은 추가 최적화 적용 (init.lua와 동일한 임계값 사용)
      -- 주의: swapfile은 여기서 끄지 않는다. lua/init.lua가 이미 전역으로
      -- swapfile/backup/writebackup을 껐으므로 버퍼별로 다시 끄는 것은 죽은 코드다.
      -- 전역 설정을 되살리게 되면 이 자리에 swapfile = false를 다시 넣을 것.
      if file_size > size_5mb then
        vim.b[bufnr]._large_file = true
        vim.bo[bufnr].undofile = false
        -- Window-local options must be set per-window for this buffer
        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(bufnr) then
            return
          end
          local wins = vim.fn.win_findbuf(bufnr)
          for _, win in ipairs(wins) do
            vim.api.nvim_set_option_value("foldmethod", "manual", { win = win })
            vim.api.nvim_set_option_value("list", false, { win = win })
          end
        end)
        -- 파일 크기 정보 저장 (나중에 사용 가능)
        vim.b[bufnr]._file_size = file_size
      end
    end,
  })

  -- 비활성 버퍼 정리 (대용량 파일 한정)
  -- 참고: help/qf 버퍼를 숨겨질 때마다 삭제하던 로직은 제거함.
  -- 도움말을 오갈 때마다 재로드되고 quickfix 목록이 깨지는 부작용이 더 컸고,
  -- 목록에 있던 "nofile"은 filetype이 아니라 buftype이라 매치된 적도 없다.
  vim.api.nvim_create_autocmd("BufHidden", {
    group = augroup,
    pattern = "*",
    callback = function(args)
      local bufnr = args.buf

      -- 대용량 파일 정리 (20MB 이상)
      if vim.b[bufnr]._large_file then
        -- 저장된 파일 크기 정보가 있으면 사용, 없으면 재계산
        local file_size = vim.b[bufnr]._file_size
        if not file_size then
          local filename = vim.api.nvim_buf_get_name(bufnr)
          if filename ~= "" then
            local abs_filename = vim.fn.fnamemodify(filename, ":p")
            local ok, stats = pcall(vim.uv.fs_stat, abs_filename)
            if ok and stats then
              file_size = stats.size
            end
          end
        end

        -- 파일 크기 정보가 없으면 버퍼 크기로 대체 계산
        if not file_size then
          local ok, bufsize = pcall(vim.api.nvim_buf_get_offset, bufnr, vim.api.nvim_buf_line_count(bufnr))
          if ok then
            file_size = bufsize
          end
        end

        -- 20MB 이상 파일 정리
        if file_size and file_size > 20 * 1024 * 1024 then
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(bufnr) and not vim.bo[bufnr].modified then
              vim.api.nvim_buf_delete(bufnr, { force = false })
            end
          end)
        end
      end
    end,
  })
end

-- 0.11 성능 모니터링
function M.setup_performance_monitoring()
  if vim.env.NVIM_PERF_MONITOR then
    -- 모듈 로드 시점부터 측정 시작 (더 정확한 시작 시간)
    local start_time = vim.uv.hrtime()

    vim.api.nvim_create_autocmd("VimEnter", {
      once = true, -- 한 번만 실행
      callback = function()
        local load_time = (vim.uv.hrtime() - start_time) / 1e6 -- ms로 변환
        vim.schedule(function()
          vim.notify(
            string.format("Neovim startup time (cache_manager loaded): %.2fms", load_time),
            vim.log.levels.INFO,
            { title = "Performance", timeout = 5000 }
          )
        end)
      end,
    })
  end
end

-- 디렉토리 변경 시 캐시 무효화
function M.clear_cache()
  dir_cache = {}
  dir_cache_cwd = ""
end

-- 메인 설정 함수 (0.11 최적화)
function M.setup()
  -- 기본 파일 시스템 최적화
  local ignore_dirs = M.setup_fs_optimizations()

  -- 0.11 최적화 설정
  M.setup_memory_optimizations()
  M.setup_buffer_cache()
  M.setup_performance_monitoring()

  -- 디렉토리 변경 시 캐시를 비우고 wildignore를 새 cwd 기준으로 다시 계산한다.
  -- (캐시만 비우면 새 cwd의 패턴이 반영되지 않고 이전 패턴도 남는다)
  vim.api.nvim_create_autocmd("DirChanged", {
    callback = function()
      M.clear_cache()
      M.setup_fs_optimizations()
    end,
  })

  -- 디버그용 정보 (환경 변수로 제어)
  if vim.env.NVIM_CACHE_DEBUG and #ignore_dirs > 0 then
    vim.schedule(function()
      vim.notify(
        "Cache optimization enabled for " .. #ignore_dirs .. " directories: " .. table.concat(ignore_dirs, ", "),
        vim.log.levels.INFO,
        { title = "Cache Manager", timeout = 3000 }
      )
    end)
  end
end

return M
