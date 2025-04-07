local lspconfig = require("lspconfig")
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
	-- 	title = "LSP 연결",
	-- 	timeout = 1500,
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
		debounce_text_changes = 150, -- 텍스트 변경 후 지연 시간 (ms)
	},
	on_attach = setup_lsp,
	-- LSP 타임아웃 및 성능 관련 설정 추가 (0.13에서 핸들러 API 변경으로 제거)
}

-- 전역 진단 키맵 설정
local function setup_global_keymaps()
	local opts = { noremap = true, silent = true }
	vim.keymap.set(
		"n",
		"<leader>e",
		vim.diagnostic.open_float,
		vim.tbl_extend("force", opts, { desc = "Show Line Diagnostics" })
	)
	vim.keymap.set("n", "[d", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, vim.tbl_extend("force", opts, { desc = "Previous Diagnostic" }))
	vim.keymap.set("n", "]d", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, vim.tbl_extend("force", opts, { desc = "Next Diagnostic" }))
	vim.keymap.set(
		"n",
		"<leader>q",
		vim.diagnostic.setqflist,
		vim.tbl_extend("force", opts, { desc = "Diagnostics to Quickfix List" })
	)

	-- Inlay Hints 키 매핑 설정 (최신 Neovim 버전 확인)
	if vim.lsp.inlay_hint and vim.fn.has("nvim-0.10.0") == 1 then
		setup_inlay_hints_keymaps()
	end
end

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
						".cache",
						"target",
						"node_modules",
						"dist",
						".git",
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
					path = vim.split(package.path, ";"),
				},
				workspace = {
					-- 서드파티 라이브러리 검사 비활성화 (성능 향상)
					checkThirdParty = false,
					-- Neovim 런타임 라이브러리 인식
					library = {
						vim.env.VIMRUNTIME,
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
	setup_global_keymaps() -- 전역 키맵 설정

	-- 모든 서버에 대해 설정 적용
	for server, config in pairs(servers) do
		local merged_config = vim.tbl_deep_extend("force", default_opts, config)

		-- 에러 핸들러 추가
		merged_config.on_init = function(client, _)
			vim.notify(string.format("LSP 서버 '%s' 초기화 중...", client.name), vim.log.levels.INFO, {
				title = "LSP 초기화",
				timeout = 1000,
			})
			return true
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
			lspconfig[server].setup(merged_config)
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

-- 진단 설정 (선택적)
vim.diagnostic.config({
	virtual_text = { prefix = "●" }, -- 가상 텍스트 표시 스타일
	signs = true,
	update_in_insert = false, -- 삽입 모드 업데이트 비활성화 (성능 개선)
	severity_sort = true, -- 심각도순 정렬
	float = {
		focusable = false,
		style = "minimal",
		border = "rounded",
		source = true,
		header = "",
		prefix = "",
	},
})

-- LSP 성능 문제 추적을 위한 로깅 설정
vim.lsp.set_log_level("off") -- 일반적으로는 'off'로 설정, 문제 해결 시 'info' 또는 'debug'로 변경

-- LSP 요청 타임아웃 설정
vim.lsp.buf.request_timeout = 5000 -- 모든 LSP 요청 타임아웃을 5초로 설정 (3초에서 5초로 증가)

-- 서버와 파일 유형 간의 매핑
local server_filetype_map = {
	ts_ls = { "typescript", "javascript", "typescriptreact", "javascriptreact", "typescript.tsx", "javascript.jsx" },
	eslint = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
	rust_analyzer = { "rust" },
	lua_ls = { "lua" },
}

-- 지연 로딩을 위한 함수
local function setup_lazy_loading()
	-- 전역 키맵은 항상 설정
	setup_global_keymaps()

	-- 사용자 정의 FileType 자동 명령 그룹 생성
	local lsp_lazy_group = vim.api.nvim_create_augroup("LspLazyLoading", { clear = true })

	-- 각 파일 유형에 대한 LSP 서버 설정
	for server, filetypes in pairs(server_filetype_map) do
		vim.api.nvim_create_autocmd("FileType", {
			group = lsp_lazy_group,
			pattern = filetypes,
			callback = function()
				-- 서버가 이미 시작되었는지 확인
				local is_server_active = false
				for _, client in ipairs(vim.lsp.get_clients()) do
					if client.name == server then
						is_server_active = true
						break
					end
				end

				-- 서버가 활성화되지 않은 경우에만 시작
				if not is_server_active and servers[server] then
					local merged_config = vim.tbl_deep_extend("force", default_opts, servers[server] or {})

					-- 초기화 알림 제거
					merged_config.on_init = function(client, _)
						-- 불필요한 알림 제거
						return true
					end

					-- 비동기로 서버 시작 (지연시간 추가)
					vim.defer_fn(function()
						-- 서버 시작 시도
						local ok, err = pcall(function()
							lspconfig[server].setup(merged_config)
							-- 현재 버퍼에 즉시 연결 시도
							vim.cmd("LspStart " .. server)
						end)

						-- 설정 오류 처리 (중요 오류만 표시)
						if not ok then
							vim.notify(
								string.format("LSP 서버 '%s' 설정 오류: %s", server, err),
								vim.log.levels.ERROR,
								{ title = "LSP 설정 오류" }
							)
						end
					end, 100 * vim.loop.hrtime() % 700) -- 서버마다 시작 시간 분산 (0-700ms)
				end
			end,
			desc = string.format("지연 로딩: %s LSP 서버", server),
		})
	end
end

-- 모듈 실행을 지연 로딩으로 변경
setup_lazy_loading()

return {
	setup = setup_lsp_servers, -- 기존 즉시 로딩 방식 (호환성 유지)
	setup_lazy = setup_lazy_loading, -- 새 지연 로딩 방식
	get_servers = function()
		return servers
	end, -- 설정된 서버 목록 반환
}
