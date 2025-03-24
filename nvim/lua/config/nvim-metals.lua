local metals = require("metals")
local keys = require("config.nvim-lspconfig-keys")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

-- ========== 설정 변수 ========== --
-- 개발/프로덕션 환경에 따른 조건부 설정
local DEV_MODE = false -- 개발 모드 활성화 여부 (true = 개발 모드, false = 프로덕션 모드)
local ENABLE_VERBOSE_LOGGING = false -- 상세 로그 활성화 여부
local ENABLE_AUTO_FORMATTING = true -- 자동 포맷팅 활성화 여부
local AUTO_START_METALS = true -- Metals 자동 시작 활성화 여부

-- 전역 설정 조정
vim.opt_global.shortmess:remove("F") -- API 메시지 표시 활성화

-- Metals 기본 설정
local metals_config = metals.bare_config()

-- Metals 전용 자동 명령 그룹 (미리 정의하여 다른 함수에서 사용할 수 있게 함)
local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })

-- ========== 사용자 구성 함수 ========== --
-- Metals 기능별 조건부 활성화 함수
local function configure_metals_settings()
	-- 기본 설정
	local settings = {
		serverVersion = "1.5.1", -- Metals 서버 버전 고정
		showImplicitArguments = true, -- 암묵적 인수 표시
		ammoniteJvmProperties = { "-Xmx2G" }, -- Ammonite JVM 메모리 설정
		bloopSbtAlreadyInstalled = true, -- Bloop과 SBT 설치 가정
		excludedPackages = { -- LSP에서 제외할 패키지 목록
			"akka.actor.typed.javadsl",
			"com.github.swagger.akka.javadsl",
		},
	}

	-- 조건부 기능 활성화
	-- 성능 비용이 큰 기능들은 필요에 따라 활성화
	settings.showInferredType = true -- 추론된 타입 표시 (항상 유용함)
	settings.superMethodLensesEnabled = true -- 슈퍼 메서드 렌즈 활성화

	-- 개발자 모드 전용 설정
	if DEV_MODE then
		settings.enableSemanticHighlighting = true -- 시맨틱 하이라이팅 (개발 모드에서만)
		settings.statistics = {
			didFocus = true,
			didChange = true,
		} -- 통계 수집 (디버깅용)
	end

	return settings
end

-- 에러 처리 핸들러 설정
local function setup_error_handlers()
	-- Metals 연결 실패 핸들러
	metals_config.init_options.onConnectFailure = function(err)
		vim.notify(string.format("Metals 연결 실패: %s", err), vim.log.levels.ERROR, { title = "Metals 오류" })
	end

	-- Metals 초기화 실패 핸들러
	metals_config.init_options.onInitializationFailure = function(err)
		vim.notify(string.format("Metals 초기화 실패: %s", err), vim.log.levels.ERROR, { title = "Metals 오류" })
	end

	-- 로깅 및 디버깅 설정
	if ENABLE_VERBOSE_LOGGING then
		metals_config.settings.customLogging = true
		metals_config.settings.logLevel = "debug" -- 디버그 로그 활성화
	end

	-- 시스템 환경 확인
	metals_config.init_options.systemCheck = function()
		-- Java 버전 확인
		local java_version = vim.fn.system("java -version 2>&1 | head -n 1")
		if java_version:match("java version") == nil and java_version:match("openjdk version") == nil then
			vim.notify(
				"Java not found or incorrect version. Metals requires Java 8 or higher.",
				vim.log.levels.WARN,
				{ title = "Metals 환경 확인" }
			)
			return false
		end
		return true
	end
end

-- 디버깅 설정 함수
local function configure_debug_options()
	-- 개발 모드에서만 HTTP 인터페이스 및 디버깅 기능 활성화
	if DEV_MODE then
		return {
			statusBarProvider = "show-message", -- 상태 표시줄을 메시지로 표시 (더 가볍게)
			isHttpEnabled = true, -- HTTP 인터페이스 활성화 (디버깅용)
			debuggingProvider = true, -- DAP 디버깅 활성화
		}
	else
		return {
			statusBarProvider = "show-message", -- 상태 표시줄을 메시지로 표시 (더 가볍게)
			isHttpEnabled = false, -- 프로덕션에서는 HTTP 인터페이스 비활성화
			debuggingProvider = false, -- 프로덕션에서는 디버깅 비활성화
		}
	end
end

-- 지연 로딩 처리 함수
local function initialize_metals_lazy(bufnr)
	-- 이미 초기화되었는지 확인
	local clients = vim.lsp.get_clients()
	for _, client in ipairs(clients) do
		if client.name == "metals" then
			-- 이미 실행 중이면 건너뛰기
			return
		end
	end

	-- 서버 시작 시도
	local ok, err = pcall(function()
		metals.initialize_or_attach(metals_config)
	end)

	-- 에러 처리
	if not ok then
		vim.notify(
			string.format("Metals 초기화 실패: %s", err),
			vim.log.levels.ERROR,
			{ title = "Metals 초기화 오류" }
		)
	else
		-- 초기화 성공 시 BufWritePre 이벤트 설정 (자동 포맷팅)
		if ENABLE_AUTO_FORMATTING then
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = bufnr,
				group = nvim_metals_group,
				callback = function()
					vim.lsp.buf.format({
						timeout_ms = 3000, -- 포맷팅 타임아웃 3초
						filter = function(c)
							return c.name == "metals"
						end, -- Metals만 대상
					})
				end,
				desc = "Format Scala/SBT buffer on save",
			})
		end
	end
end

-- Scala 프로젝트 감지 함수
local function is_scala_project()
	local project_files = {
		"build.sbt",
		"build.sc",
		"project/build.properties",
		"project/plugins.sbt",
		".scala-build",
		"project/metals.sbt"
	}
	
	for _, file in ipairs(project_files) do
		if vim.fn.filereadable(file) == 1 then
			return true
		end
	end
	
	-- 디렉토리 내 Scala 파일 확인
	local scala_files = vim.fn.glob("**/*.scala", false, true)
	return #scala_files > 0
end

-- Metals 자동 시작 설정
local function setup_auto_start()
	if not AUTO_START_METALS then return end
	
	-- Scala/SBT 파일 타입 감지 시 Metals 초기화
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "scala", "sbt" },
		group = nvim_metals_group,
		callback = function(opts)
			if is_scala_project() then
				initialize_metals_lazy(opts.buf)
			end
		end,
		desc = "Initialize Metals for Scala/SBT files",
	})
	
	-- 디렉토리 변경 시 Metals 초기화
	vim.api.nvim_create_autocmd("DirChanged", {
		group = nvim_metals_group,
		callback = function()
			if is_scala_project() then
				initialize_metals_lazy(0)
			end
		end,
		desc = "Initialize Metals when entering Scala project directory",
	})

	-- Vim 시작 시 Scala 프로젝트 확인
	vim.api.nvim_create_autocmd("VimEnter", {
		group = nvim_metals_group,
		callback = function()
			if is_scala_project() then
				initialize_metals_lazy(0)
			end
		end,
		desc = "Initialize Metals on VimEnter if in Scala project",
	})
end

-- ========== 설정 적용 ========== --
-- Metals 설정 적용
metals_config.settings = configure_metals_settings()

-- 자동 시작 설정 적용
setup_auto_start()

-- 공통 LSP 설정 적용
metals_config.on_attach = function(client, bufnr)
	-- LSP 키맵 설정
	local opts = { noremap = true, silent = true, buffer = bufnr }
	
	-- 정의로 이동
	vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, opts)
	vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, opts)
	vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, opts)
	vim.keymap.set('n', '<leader>go', vim.lsp.buf.type_definition, opts)
	vim.keymap.set('n', '<leader>gs', vim.lsp.buf.signature_help, opts)
	vim.keymap.set('n', '<leader>gD', vim.lsp.buf.declaration, opts)
	vim.keymap.set('n', '<leader>ga', vim.lsp.buf.code_action, opts)
	vim.keymap.set('n', '<leader>ge', vim.diagnostic.open_float, opts)
	vim.keymap.set('n', '<leader>gE', vim.diagnostic.setloclist, opts)
	vim.keymap.set('n', '<leader>gK', vim.lsp.buf.hover, opts)
	vim.keymap.set('n', '<leader>gR', vim.lsp.buf.rename, opts)
	vim.keymap.set('n', '<leader>gS', vim.lsp.buf.workspace_symbol, opts)
	vim.keymap.set('n', '<leader>gW', vim.lsp.buf.workspace_symbol, { noremap = true, silent = true, buffer = bufnr, query = '' })
	vim.keymap.set('n', '<leader>gD', vim.lsp.buf.declaration, opts)
	vim.keymap.set('n', '<leader>gT', vim.lsp.buf.type_definition, opts)
	vim.keymap.set('n', '<leader>gI', vim.lsp.buf.implementation, opts)
	vim.keymap.set('n', '<leader>gR', vim.lsp.buf.rename, opts)
	vim.keymap.set('n', '<leader>gF', vim.lsp.buf.format, opts)
	vim.keymap.set('n', '<leader>gC', vim.lsp.buf.incoming_calls, opts)
	vim.keymap.set('n', '<leader>gO', vim.lsp.buf.outgoing_calls, opts)

	-- Metals 특화 명령어 추가
	vim.api.nvim_buf_create_user_command(bufnr, "MetalsRestart", function()
		metals.restart_server()
	end, { desc = "Restart Metals server" })

	-- 추가 Metals 명령어
	vim.api.nvim_buf_create_user_command(bufnr, "MetalsInfo", function()
		metals.metals_info()
	end, { desc = "Show Metals server info" })

	vim.api.nvim_buf_create_user_command(bufnr, "MetalsToggleImplicit", function()
		metals.toggle_implicit_conversions()
	end, { desc = "Toggle implicit parameter display" })

	-- 연결 성공 알림
	vim.notify(
		string.format("Metals 서버 연결됨 (버전: %s)", metals_config.settings.serverVersion),
		vim.log.levels.INFO,
		{ title = "Metals", timeout = 2000 }
	)
end

metals_config.capabilities = cmp_nvim_lsp.default_capabilities() -- nvim-cmp 통합

-- 디버깅 설정 적용
metals_config.init_options = configure_debug_options()

-- 에러 핸들러 설정
setup_error_handlers()

-- 프로젝트 루트 탐지 패턴
metals_config.root_patterns = { ".git", "build.sbt", "build.sc", "project" }

-- Metals 로그 설정 (디버깅용, 선택적)
metals_config.handlers = {
	["metals/status"] = function(_, status, ctx)
		if status.show then
			local level = vim.log.levels.INFO
			if status.text:match("error") or status.text:match("Error") then
				level = vim.log.levels.ERROR
			elseif status.text:match("warn") or status.text:match("Warning") then
				level = vim.log.levels.WARN
			end

			vim.notify(status.text, level, { title = "Metals 상태" })
		end
	end,
}

-- Metals 설치 확인 및 초기화
vim.api.nvim_create_autocmd("VimEnter", {
	group = nvim_metals_group,
	callback = function()
		local missing_tools = {}

		-- Coursier 확인
		if vim.fn.executable("coursier") == 0 then
			table.insert(missing_tools, "coursier")
		end

		-- Java 확인
		if vim.fn.executable("java") == 0 then
			table.insert(missing_tools, "java")
		end

		-- Bloop 확인 (선택적)
		if vim.fn.executable("bloop") == 0 and metals_config.settings.bloopSbtAlreadyInstalled then
			table.insert(missing_tools, "bloop")
		end

		-- 누락된 도구가 있으면 경고
		if #missing_tools > 0 then
			vim.notify(
				"Metals에 필요한 도구가 없습니다: " .. table.concat(missing_tools, ", "),
				vim.log.levels.WARN,
				{ title = "Metals 환경 확인" }
			)
		end
	end,
	desc = "Check Metals dependencies",
})

-- 모듈 반환
return {
	config = metals_config, -- 현재 설정 반환
	-- 사용자 설정 변경 함수
	setup = function(opts)
		-- 사용자 정의 설정 병합
		if opts then
			-- DEV_MODE 설정 적용
			if opts.dev_mode ~= nil then
				DEV_MODE = opts.dev_mode
			end

			-- 자동 포맷팅 설정 적용
			if opts.auto_formatting ~= nil then
				ENABLE_AUTO_FORMATTING = opts.auto_formatting
			end

			-- 기타 설정 병합
			metals_config = vim.tbl_deep_extend("force", metals_config, opts)
		end

		return metals_config
	end,
	-- 수동 초기화 함수
	initialize = function(bufnr)
		initialize_metals_lazy(bufnr or 0)
	end,
}
