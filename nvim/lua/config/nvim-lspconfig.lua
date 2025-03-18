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
			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		end
	end

	-- 서버별 추가 설정 (선택적)
	if client.name == "ts_ls" then
		client.server_capabilities.documentFormattingProvider = false -- tsserver는 prettier에 위임 가능
	end
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
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous Diagnostic" }))
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next Diagnostic" }))
	vim.keymap.set(
		"n",
		"<leader>q",
		vim.diagnostic.setloclist,
		vim.tbl_extend("force", opts, { desc = "Diagnostics to Loclist" })
	)

	-- Inlay Hints 키 매핑 설정 (최신 Neovim 버전 확인)
	if vim.lsp.inlay_hint and vim.fn.has("nvim-0.10.0") == 1 then
		setup_inlay_hints_keymaps()
	end
end

-- LSP 서버별 설정
local servers = {
	ts_ls = {
		-- TypeScript/JavaScript 설정
		settings = {
			typescript = {
				inlayHints = {
					includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
					includeInlayParameterNameHintsWhenArgumentMatchesName = true,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = true,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
			},
			javascript = {
				inlayHints = {
					includeInlayParameterNameHints = "all",
					includeInlayParameterNameHintsWhenArgumentMatchesName = true,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = true,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
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
				inlayHints = {
					maxLength = 25, -- 힌트 최대 길이
					closingBraceHints = true, -- 닫는 중괄호에 힌트 표시 여부
					closureReturnTypeHints = "always", -- 클로저 반환 유형 힌트
					lifetimeElisionHints = { enable = true, useParameterNames = true },
					reborrowHints = "always",
				},
			},
		},
	},
	lua_ls = {
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" }, -- Neovim의 LuaJIT 사용
				diagnostics = { globals = { "vim" } }, -- vim 전역 변수 인식
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true), -- Neovim 런타임 파일
					checkThirdParty = false, -- 성능 최적화
				},
				telemetry = { enable = false }, -- 텔레메트리 비활성화
				hint = {
					enable = true, -- lua_ls inlay hints 활성화
					arrayIndex = "All", -- 배열 인덱스 힌트 표시
					setType = true, -- 변수 유형 힌트 표시
					paramName = "All", -- 매개변수 이름 힌트 표시
					paramType = true, -- 매개변수 유형 힌트 표시
				},
			},
		},
	},
}

-- LSP 초기화 함수
local function setup_lsp_servers()
	setup_global_keymaps() -- 전역 키맵 설정

	-- 모든 서버에 대해 설정 적용
	for server, config in pairs(servers) do
		lspconfig[server].setup(vim.tbl_deep_extend("force", default_opts, config))
	end
end

-- 진단 설정 (선택적)
vim.diagnostic.config({
	virtual_text = { prefix = "●" }, -- 가상 텍스트 표시 스타일
	signs = true,
	update_in_insert = false, -- 삽입 모드 업데이트 비활성화 (성능 개선)
	severity_sort = true, -- 심각도순 정렬
})

-- 모듈 실행
setup_lsp_servers()

return {
	setup = setup_lsp_servers, -- 외부에서 재호출 가능
}
