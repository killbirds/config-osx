local keys = require("config.nvim-lspconfig-keys")
local lsp_capabilities = require("config.lsp-capabilities")

-- 서버별 추가 설정 (LspAttach 시 적용)
local function apply_server_specific_config(client, bufnr)
  if client.name == "ts_ls" then
    -- tsserver는 prettier에 포매팅 위임
    client.server_capabilities.documentFormattingProvider = false
  end
end

-- Inlay Hints 토글 키맵(<leader>th)은 plugins/lsp.lua의 lazy keys에서 정의됨

-- 공통 옵션 설정 (on_attach는 사용하지 않고 LspAttach autocmd로 통일)
local default_opts = {
  capabilities = lsp_capabilities.default_capabilities(), -- blink.cmp와의 통합
  flags = {
    debounce_text_changes = 150, -- 텍스트 변경 후 지연 시간 (ms)
  },
}

-- servers 테이블에 없는 서버(mason-lspconfig automatic_enable로 시작되는 서버 포함)에도
-- blink.cmp capabilities가 적용되도록 전역 기본값을 등록한다.
vim.lsp.config("*", {
  capabilities = lsp_capabilities.default_capabilities(),
})

-- 어떤 서버가 붙든 공통 키맵/버퍼 옵션이 적용되도록 보장한다.
-- on_attach 대신 LspAttach autocmd 하나로 통일하여 중복 호출을 방지한다.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspAttachKeys", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end
    keys.on_attach(client, args.buf)
    apply_server_specific_config(client, args.buf)
  end,
})

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

local js_ts_filetypes = {
	"javascript",
	"javascriptreact",
	"typescript",
	"typescriptreact",
}

local servers = {
	ts_ls = {
		-- TypeScript/JavaScript 설정
		filetypes = js_ts_filetypes,
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
		filetypes = js_ts_filetypes,
		-- ESLint 9+ 로컬 설치를 가정하고 deprecated 옵션을 정리함:
		-- - packageManager("yarn")는 전역 설치 탐색 경로에만 쓰여 로컬 설치에서는 불필요
		-- - flat config는 9.x부터 기본. 8.57~8.x 프로젝트는 settings.useFlatConfig = true,
		--   8.21~8.56 프로젝트는 settings.experimental.useFlatConfig = true가 필요하므로
		--   구버전 프로젝트를 다루게 되면 복원할 것.
		handlers = {
			["eslint/openDoc"] = function(_, result)
				if result then
					vim.fn.system({ "open", result.url })
				end
			end,
		},
	},
	marksman = {
		filetypes = { "markdown" },
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
					source = "discover", -- 러스트 소스 자동 탐색
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
					maxLength = 25, -- 힌트 최대 길이
					closingBraceHints = true, -- 닫는 중괄호에 힌트 표시 여부
					closureReturnTypeHints = "always", -- 클로저 반환 유형 힌트
					lifetimeElisionHints = { enable = true, useParameterNames = true },
					reborrowHints = "never", -- 재대여 힌트 비활성화
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
			--
			-- 주의: 이 설정 레포에는 nvim/.luarc.json이 있으므로 여기서 early return 한다.
			-- 즉 아래 Lua 설정은 **이 레포에서는 적용되지 않고** .luarc.json이 대신한다.
			-- (.luarc.json은 lua_ls root_markers 1순위라 root_dir도 nvim/으로 잡힌다)
			-- 아래 블록을 고칠 일이 생기면 nvim/.luarc.json도 같이 고쳐야 한다.
			-- 여기 남겨 두는 이유는 .luarc.json이 없는 다른 프로젝트의 Lua 파일을
			-- 편집할 때는 여전히 이 경로가 쓰이기 때문이다.
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
			-- workspace.library는 lazydev.nvim이 관리한다:
			-- 열린 파일의 require()에 맞춰 Neovim 런타임과 플러그인 경로를
			-- 지연 추가하므로 여기서 수동으로 나열하지 않는다.
			client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
				runtime = {
					-- Neovim은 LuaJIT 사용
					-- 주의: runtime.path는 "?.lua" 형태의 모듈 검색 패턴 목록이므로
					-- 디렉토리 목록을 넣으면 안 된다. 기본값을 그대로 사용한다.
					version = "LuaJIT",
				},
				workspace = {
					-- 서드파티 라이브러리 검사 비활성화 (성능 향상)
					checkThirdParty = false,
				},
				-- 향상된 진단 설정
				diagnostics = {
					globals = { "vim" }, -- vim 전역 변수 인식
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
					enable = true, -- inlay hints 활성화
					arrayIndex = "Disable", -- 배열 인덱스 힌트 비활성화
					setType = true, -- 변수 유형 힌트 표시
					paramName = "All", -- 매개변수 이름 힌트 표시
					paramType = true, -- 매개변수 유형 힌트 표시
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

		merged_config.on_exit = function(code, signal, client_id)
			-- on_exit는 fast event context에서 호출될 수 있으므로 API 호출을 예약한다.
			vim.schedule(function()
				local client = vim.lsp.get_client_by_id(client_id)
				local server_name = client and client.name or "알 수 없음"

				if code ~= 0 or signal ~= 0 then
					vim.notify(
						string.format("LSP 서버 '%s' 비정상 종료 (code: %d, signal: %d)", server_name, code, signal),
						vim.log.levels.ERROR,
						{ title = "LSP 오류" }
					)
				end
			end)
		end

		-- 서버 시작 시도
		local ok, err = pcall(function()
			vim.lsp.config(server, merged_config)
			vim.lsp.enable(server)
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

-- 모듈 실행을 즉시 로딩으로 변경 (지연 로딩 문제 해결)
setup_lsp_servers()

-- LSP 클라이언트 관리 유틸리티 함수들
local function cleanup_duplicate_clients()
	local clients_by_name = {}
	local clients_to_stop = {}

	-- 클라이언트를 이름별로 그룹화
	for _, client in ipairs(vim.lsp.get_clients()) do
		if client.name ~= "metals" then
			if not clients_by_name[client.name] then
				clients_by_name[client.name] = {}
			end
			table.insert(clients_by_name[client.name], client)
		end
	end

	-- 중복 클라이언트 찾기
	for _, clients in pairs(clients_by_name) do
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
		client:stop()
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
		-- vim.lsp.get_buffers_by_client_id()는 deprecated이고 Neovim 0.13에서 제거된다
		-- (runtime/lua/vim/lsp.lua의 vim.deprecate(..., '0.13')).
		local buffers = vim.tbl_keys(client.attached_buffers or {})
		table.sort(buffers)
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

	local restartable_clients = {}
	for _, client in ipairs(clients) do
		if client.name ~= "metals" then
			table.insert(restartable_clients, client)
		end
	end

	if #restartable_clients == 0 then
		vim.notify("Metals는 LspRestart 대상에서 제외됩니다. :MetalsRestart를 사용하세요.", vim.log.levels.INFO)
		return
	end

	-- vim.lsp.enable(name)은 이미 enabled 상태면 no-op이므로 stop() 후 다시 호출해도
	-- 재시작되지 않는다. enable(name, false)로 내렸다가 잠시 후 다시 올린다.
	local names = {}
	for _, client in ipairs(restartable_clients) do
		names[client.name] = true
	end

	for name in pairs(names) do
		vim.notify(string.format("LSP 서버 '%s' 재시작 중...", name), vim.log.levels.INFO, {
			title = "LSP 재시작",
			timeout = 1000,
		})
		vim.lsp.enable(name, false)
	end

	vim.defer_fn(function()
		for name in pairs(names) do
			local ok, err = pcall(vim.lsp.enable, name)
			if not ok then
				vim.notify(
					string.format("LSP 서버 '%s' 재시작 실패: %s", name, err),
					vim.log.levels.WARN,
					{ title = "LSP 재시작" }
				)
			end
		end
	end, 500)
end, { desc = "현재 버퍼의 LSP 서버 재시작" })

-- LSP 관리 키맵 (전역이므로 on_attach가 아닌 여기서 한 번만 등록)
-- <leader>l은 라인 주석 토글(내장 gcc)이므로, timeout 지연을 만들지 않도록
-- 관리용 키는 <leader>L 네임스페이스를 사용한다.
local lsp_admin_opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>Lc", "<cmd>LspCleanup<cr>",
	vim.tbl_extend("force", lsp_admin_opts, { desc = "LSP 중복 클라이언트 정리" }))
vim.keymap.set("n", "<leader>Ls", "<cmd>LspStatus<cr>",
	vim.tbl_extend("force", lsp_admin_opts, { desc = "LSP 상태 확인" }))
vim.keymap.set("n", "<leader>Lr", "<cmd>LspRestart<cr>",
	vim.tbl_extend("force", lsp_admin_opts, { desc = "LSP 재시작" }))

return {
	setup = setup_lsp_servers, -- 기존 즉시 로딩 방식 (호환성 유지)
	get_servers = function()
		return servers
	end, -- 설정된 서버 목록 반환
	get_default_capabilities = function()
		return lsp_capabilities.default_capabilities()
	end,
	cleanup_duplicates = cleanup_duplicate_clients, -- 중복 클라이언트 정리
	show_status = show_lsp_status, -- LSP 상태 확인
}
