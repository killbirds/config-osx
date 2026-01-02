local cmp_nvim_lsp = require("cmp_nvim_lsp")
local keys = require("config.nvim-lspconfig-keys")

-- 공통 LSP 설정 함수
local function setup_lsp(client, bufnr)
  -- 키맵 및 버퍼 설정
  keys.on_attach(client, bufnr)

  -- 포매팅 기능 활성화
  client.server_capabilities.documentFormattingProvider = true
  client.server_capabilities.documentRangeFormattingProvider = true

  -- Inlay Hints 설정 (Neovim 0.10.0+)
  if vim.lsp.inlay_hint and client.server_capabilities.inlayHintProvider then
    -- 버퍼별 inlay hint 활성화 (API 문서 기반 수정)
    if vim.fn.has("nvim-0.10.0") == 1 then
      vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
    end
  end

  -- 서버별 추가 설정 (선택적)
  if client.name == "ts_ls" then
    client.server_capabilities.documentFormattingProvider = false -- tsserver는 prettier에 위임 가능
  end

  -- 서버 연결 성공 알림
  -- vim.notify(string.format("LSP 서버 '%s' 연결 성공", client.name), vim.log.levels.INFO, {
  --   title = "LSP 연결",
  --   timeout = 1500,
  -- })
end

-- Inlay Hints 키 매핑 설정
local function setup_inlay_hints_keymaps()
  local opts = { noremap = true, silent = true }
  -- Inlay hints 토글 키 매핑 (API 문서 기반 수정)
  vim.keymap.set("n", "<leader>th", function()
    -- 현재 버퍼에서만 토글
    local bufnr = vim.api.nvim_get_current_buf()
    local filter = { bufnr = bufnr }
    local enabled = vim.lsp.inlay_hint.is_enabled(filter)
    vim.lsp.inlay_hint.enable(not enabled, filter)
  end, vim.tbl_extend("force", opts, { desc = "Toggle Inlay Hints" }))
end

-- 공통 옵션 설정
local default_opts = {
  capabilities = cmp_nvim_lsp.default_capabilities(), -- nvim-cmp와의 통합
  flags = {
    debounce_text_changes = 150,                     -- 텍스트 변경 후 지연 시간 (ms)
  },
  on_attach = setup_lsp,
  -- LSP 타임아웃 및 성능 관련 설정 추가
  settings = {
    -- 모든 LSP 서버에 적용될 기본 설정
    workspace = {
      -- 무시할 디렉토리 및 파일 패턴
      ignoredFolders = {
        "${workspaceFolder}/.cache",
        "${workspaceFolder}/node_modules",
        "${workspaceFolder}/.git",
        "${workspaceFolder}/target",
        "${workspaceFolder}/dist",
        "${workspaceFolder}/.svelte-kit",
        "${workspaceFolder}/.next",
      },
      maxFileSizeInMegabytes = 5, -- 5MB 이상 파일 LSP 분석 제외
    },
  },
}

-- LSP 서버별 설정
-- 공통 인레이 힌트 설정 테이블
local common_js_ts_inlay_hints = {
  includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
  includeInlayParameterNameHintsWhenArgumentMatchesName = true,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayVariableTypeHints = true,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayEnumMemberValueHints = true,
  includeInlayArrayIndexHints = false, -- 배열 인덱스 힌트 비활성화
}

local servers = {
  ts_ls = {
    -- TypeScript/JavaScript 설정
    settings = {
      typescript = {
        inlayHints = common_js_ts_inlay_hints,
      },
      javascript = {
        inlayHints = common_js_ts_inlay_hints,
      },
    },
  },
  eslint = {
    settings = {
      -- eslint 서버 설정
      packageManager = "yarn", -- 패키지 매니저 (npm, yarn, pnpm 중)
      experimental = {
        useFlatConfig = true, -- eslint.config.mjs와 같은 플랫 설정 파일 지원 활성화
      },
    },
    handlers = {
      ["eslint/openDoc"] = function(_, result)
        if result then
          vim.fn.system({ "open", result.url })
        end
      end,
    },
  },
  rust_analyzer = {
    -- init_options를 직접 설정하지 마세요.
    -- rust-analyzer는 settings["rust-analyzer"]의 내용을 자동으로 init_options로 사용합니다.
    -- 참고: https://github.com/rust-lang/rust-analyzer/blob/eb5da56d839ae0a9e9f50774fa3eb78eb0964550/docs/dev/lsp-extensions.md?plain=1#L26
    settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true, -- 모든 Cargo 기능 활성화
        },
        checkOnSave = true,
        check = { command = "clippy" }, -- 저장 시 Clippy 실행
        rustc = {
          source = "discover",      -- 러스트 소스 자동 탐색
        },
        rust = {
          unstable_features = true,
          edition = "2024", -- Rust Edition 2024 지정
        },
        -- 파일 시스템 스캔 제외 설정 추가
        files = {
          excludeDirs = {
            "data/.cache",
            "\\.cache",
            "target",
            "node_modules",
            "dist",
            ".git",
            ".svelte-kit",
            ".next",
            "build",
            "out",
            "coverage",
            ".yarn",
            ".pnpm",
          },
          watcher = "client", -- 파일 시스템 감시를 클라이언트(Neovim)에 위임
        },
        inlayHints = {
          maxLength = 25,               -- 힌트 최대 길이
          closingBraceHints = true,     -- 닫는 중괄호에 힌트 표시 여부
          closureReturnTypeHints = "always", -- 클로저 반환 유형 힌트
          lifetimeElisionHints = { enable = true, useParameterNames = true },
          reborrowHints = "never",      -- 재대여 힌트 비활성화
          bindingModeHints = { enable = true },
          chainingHints = { enable = true }, -- 체인 메서드 타입 힌트 활성화
          expressionAdjustmentHints = { enable = true },
          typeHints = { enable = true },
          parameterHints = { enable = true },
          implicitDrops = { enable = true },
          arrayIndexHints = { enable = false }, -- 배열 인덱스 힌트 비활성화
        },
      },
    },
  },
  lua_ls = {
    on_init = function(client)
      -- 프로젝트 설정 파일 존재 여부 확인
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        -- Neovim 설정 폴더가 아니면서 자체 .luarc.json 파일이 있으면 기본 설정 유지
        if
            path ~= vim.fn.stdpath("config")
            and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
        then
          return
        end
      end

      -- Neovim 특화 설정으로 확장
      client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
        runtime = {
          -- Neovim은 LuaJIT 사용
          version = "LuaJIT",
          -- 경로 설정
          path = vim.api.nvim_get_runtime_file("", true), -- Use nvim_get_runtime_file for robust path
        },
        workspace = {
          -- 서드파티 라이브러리 검사 비활성화 (성능 향상)
          checkThirdParty = false,
          -- Neovim 런타임 라이브러리 인식
          library = {
            vim.env.VIMRUNTIME,
            vim.api.nvim_get_runtime_file("lua", true), -- Add Lua runtime files
            vim.api.nvim_get_runtime_file("plugin", true), -- Add plugin runtime files
            -- 추가적인 플러그인 경로가 필요하면 아래 주석을 해제하고 사용
            -- "${3rd}/luv/library"
            -- "${3rd}/busted/library",
          },
          -- 최대 preload 파일 수 (대규모 프로젝트 지원)
          maxPreload = 2000,
          preloadFileSize = 1000,
        },
        -- 향상된 진단 설정
        diagnostics = {
          globals = { "vim" },       -- vim 전역 변수 인식
          disable = { "trailing-space" }, -- 불필요한 진단 비활성화
        },
        -- 텔레메트리 비활성화
        telemetry = { enable = false },
        -- 자동 완성 및 힌트 설정
        completion = {
          callSnippet = "Replace", -- 함수 호출 시 파라미터 스니펫 동작
          keywordSnippet = "Replace", -- 키워드 자동 완성 동작
        },
        hint = {
          enable = true,     -- inlay hints 활성화
          arrayIndex = "Disable", -- 배열 인덱스 힌트 비활성화
          setType = true,    -- 변수 유형 힌트 표시
          paramName = "All", -- 매개변수 이름 힌트 표시
          paramType = true,  -- 매개변수 유형 힌트 표시
        },
      })
    end,
    settings = {
      Lua = {},
    },
  },
}

-- LSP 초기화 함수
local function setup_lsp_servers()
  -- 모든 서버에 대해 설정 적용
  for server, config in pairs(servers) do
    local merged_config = vim.tbl_deep_extend("force", default_opts, config)

    -- 에러 핸들러 추가 (기존 on_init가 있으면 유지)
    if not merged_config.on_init then
      merged_config.on_init = function(client, _)
        vim.notify(string.format("LSP 서버 '%s' 초기화 중...", client.name), vim.log.levels.INFO, {
          title = "LSP 초기화",
          timeout = 1000,
        })
      end
    else
      -- 기존 on_init를 래핑하여 알림 추가
      local original_on_init = merged_config.on_init
      merged_config.on_init = function(client, init_result)
        vim.notify(string.format("LSP 서버 '%s' 초기화 중...", client.name), vim.log.levels.INFO, {
          title = "LSP 초기화",
          timeout = 1000,
        })
        return original_on_init(client, init_result)
      end
    end

    merged_config.on_exit = function(code, signal, client_id)
      local client = vim.lsp.get_client_by_id(client_id)
      local server_name = client and client.name or "알 수 없음"

      if code ~= 0 or signal ~= 0 then
        vim.notify(
          string.format("LSP 서버 '%s' 비정상 종료 (code: %d, signal: %d)", server_name, code, signal),
          vim.log.levels.ERROR,
          { title = "LSP 오류" }
        )
      end
    end

    -- 서버 시작 시도
    local ok, err = pcall(function()
      vim.lsp.config(server, merged_config)
    end)

    -- 설정 오류 처리
    if not ok then
      vim.notify(
        string.format("LSP 서버 '%s' 설정 오류: %s", server, err),
        vim.log.levels.ERROR,
        { title = "LSP 설정 오류" }
      )
    end
  end
end

-- 진단 설정은 config/diagnostics.lua에서 중앙 관리됨

-- LSP 성능 문제 추적을 위한 로깅 설정
vim.lsp.set_log_level("off") -- 문제 해결을 위해 일시적으로 'info'로 변경

-- LSP 요청 타임아웃 설정
vim.lsp.buf.request_timeout = 5000 -- 모든 LSP 요청 타임아웃을 5초로 설정 (3초에서 5초로 증가)

-- LSP 핸들러 성능 최적화
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
  max_width = 80,
  max_height = 20,
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "rounded",
  max_width = 80,
  max_height = 15,
})

-- LSP 진단 성능 최적화
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  -- 삽입 모드에서 진단 업데이트 비활성화
  update_in_insert = false,
  -- 진단 디바운싱
  debounce_text_changes = 200,
})

-- 서버와 파일 유형 간의 매핑
local server_filetype_map = {
  ts_ls = { "typescript", "javascript", "typescriptreact", "javascriptreact", "typescript.tsx", "javascript.jsx" },
  eslint = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
  rust_analyzer = { "rust" },
  lua_ls = { "lua" },
}

-- 모듈 실행을 즉시 로딩으로 변경 (지연 로딩 문제 해결)
setup_lsp_servers()

-- LSP 클라이언트 관리 유틸리티 함수들
local function cleanup_duplicate_clients()
  local clients_by_name = {}
  local clients_to_stop = {}

  -- 클라이언트를 이름별로 그룹화
  for _, client in ipairs(vim.lsp.get_clients()) do
    if not clients_by_name[client.name] then
      clients_by_name[client.name] = {}
    end
    table.insert(clients_by_name[client.name], client)
  end

  -- 중복 클라이언트 찾기
  for name, clients in pairs(clients_by_name) do
    if #clients > 1 then
      -- 첫 번째 클라이언트만 유지하고 나머지는 중지
      for i = 2, #clients do
        table.insert(clients_to_stop, clients[i])
      end
    end
  end

  -- 중복 클라이언트 중지
  for _, client in ipairs(clients_to_stop) do
    vim.notify(
      string.format("중복된 LSP 클라이언트 '%s' (id: %d)를 중지합니다.", client.name, client.id),
      vim.log.levels.INFO,
      { title = "LSP 정리" }
    )
    client.stop()
  end

  return #clients_to_stop
end

-- LSP 상태 확인 함수
local function show_lsp_status()
  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    vim.notify("활성화된 LSP 클라이언트가 없습니다.", vim.log.levels.INFO)
    return
  end

  local status_lines = { "활성화된 LSP 클라이언트:" }
  for _, client in ipairs(clients) do
    local buffers = {}
    for _, buf in ipairs(vim.lsp.get_buffers_by_client_id(client.id)) do
      table.insert(buffers, buf)
    end
    table.insert(
      status_lines,
      string.format("- %s (id: %d, buffers: %s)", client.name, client.id, table.concat(buffers, ", "))
    )
  end

  vim.notify(table.concat(status_lines, "\n"), vim.log.levels.INFO, { title = "LSP 상태" })
end

-- 사용자 명령 추가
vim.api.nvim_create_user_command("LspCleanup", function()
  local cleaned = cleanup_duplicate_clients()
  if cleaned > 0 then
    vim.notify(
      string.format("%d개의 중복 LSP 클라이언트를 정리했습니다.", cleaned),
      vim.log.levels.INFO
    )
  else
    vim.notify("중복된 LSP 클라이언트가 없습니다.", vim.log.levels.INFO)
  end
end, { desc = "중복된 LSP 클라이언트 정리" })

vim.api.nvim_create_user_command("LspStatus", show_lsp_status, { desc = "LSP 클라이언트 상태 확인" })

-- LSP 재시작 명령어 추가
vim.api.nvim_create_user_command("LspRestart", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify("재시작할 LSP 클라이언트가 없습니다.", vim.log.levels.WARN)
    return
  end

  for _, client in ipairs(clients) do
    vim.notify(string.format("LSP 서버 '%s' 재시작 중...", client.name), vim.log.levels.INFO, {
      title = "LSP 재시작",
      timeout = 1000,
    })
    client.stop()
    -- 서버 재시작은 자동으로 처리됨 (mason-lspconfig의 automatic_enable)
  end
end, { desc = "현재 버퍼의 LSP 서버 재시작" })

-- 진단 설정 활성화
require("config.diagnostics").setup("development")

return {
  setup = setup_lsp_servers, -- 기존 즉시 로딩 방식 (호환성 유지)
  get_servers = function()
    return servers
  end,                                           -- 설정된 서버 목록 반환
  cleanup_duplicates = cleanup_duplicate_clients, -- 중복 클라이언트 정리
  show_status = show_lsp_status,                 -- LSP 상태 확인
}
