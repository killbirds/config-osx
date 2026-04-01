local metals = require("metals")
local keys = require("config.nvim-lspconfig-keys")
local lsp_capabilities = require("config.lsp-capabilities")

-- ========== 설정 변수 ========== --
-- 개발/프로덕션 환경에 따른 조건부 설정
local DEV_MODE = true -- 개발 모드 활성화 여부 (true = 개발 모드, false = 프로덕션 모드)
local ENABLE_AUTO_FORMATTING = true -- 자동 포맷팅 활성화 여부
local AUTO_START_METALS = true -- Metals 자동 시작 활성화 여부 (기본: 자동 기동)

-- 전역 설정 조정
vim.opt_global.shortmess:remove("F") -- API 메시지 표시 활성화

-- Metals 기본 설정
local metals_config = metals.bare_config()
metals_config.find_root_dir_max_project_nesting = 2

-- Metals 전용 자동 명령 그룹 (미리 정의하여 다른 함수에서 사용할 수 있게 함)
local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
local nvim_metals_autostart_group = vim.api.nvim_create_augroup("nvim-metals-autostart", { clear = true })
local metals_starting = false

local function resolve_java_home()
	local java_home = vim.env.JAVA_HOME
	if type(java_home) == "string" and java_home ~= "" and vim.fn.isdirectory(java_home) == 1 then
		return java_home
	end

	return nil
end

-- ========== 사용자 구성 함수 ========== --
-- Metals 기능별 조건부 활성화 함수
local function configure_metals_settings()
	-- 기본 설정
	local settings = {
		serverVersion = "1.6.6",
		showImplicitArguments = true, -- 암묵적 인수 표시
		ammoniteJvmProperties = { "-Xmx2G" }, -- Ammonite JVM 메모리 설정
		bloopSbtAlreadyInstalled = true,
		autoImportBuild = "initial",
		fallbackScalaVersion = "2.13.16",
		excludedPackages = { -- LSP에서 제외할 패키지 목록
			"akka.actor.typed.javadsl",
			"com.github.swagger.akka.javadsl",
		},
		-- 엄격한 null 체크 (타입 안전성 향상)
		strictMode = true,
		-- 서버 속성 설정 (JVM 옵션)
		serverProperties = {
			"-Xms1G",
			"-Xmx4G",
			"-XX:+UseG1GC",
			"-XX:+UseStringDeduplication",
		},
	}

	local java_home = resolve_java_home()
	if java_home then
		settings.javaHome = java_home
	end

	-- 조건부 기능 활성화
	-- 성능 비용이 큰 기능들은 필요에 따라 활성화
	settings.showInferredType = true -- 추론된 타입 표시 (항상 유용함)
	settings.superMethodLensesEnabled = true -- 슈퍼 메서드 렌즈 활성화

	-- 개발자 모드 전용 설정
	if DEV_MODE then
		settings.enableSemanticHighlighting = true -- 시맨틱 하이라이팅 (개발 모드에서만)
	end

	return settings
end

local function apply_metals_settings()
	metals_config.settings = metals_config.settings or {}
	metals_config.settings.metals = configure_metals_settings()
	metals_config.settings.trace = {
		server = "verbose",
	}

	metals_config.init_options = {
		statusBarProvider = "off",
		compilerOptions = {
			snippetAutoIndent = false,
		},
		debuggingProvider = DEV_MODE,
		isHttpEnabled = DEV_MODE,
	}
end

-- 에러 처리 핸들러 설정
local function setup_error_handlers()
	-- Metals 연결 및 초기화 실패 이벤트는 직접 핸들러로 등록하지 않고
	-- handlers 필드를 통해 처리합니다
end

-- 시스템 환경 확인 함수 (초기화 전에 직접 실행)
local function check_system_requirements()
	-- Java 버전 확인
	local java_version = vim.fn.system("java -version 2>&1 | head -n 1")
	local raw_version = java_version:match('version%s+"([^"]+)"')
	if raw_version == nil then
		vim.notify(
			"Java not found or unsupported version. Metals requires Java 11 or newer (Java 17 recommended). Set JAVA_HOME to a JDK.",
			vim.log.levels.WARN,
			{ title = "Metals 환경 확인" }
		)
		return false
	end

	local major = tonumber(raw_version:match("^(%d+)"))
	if major == 1 then
		major = tonumber(raw_version:match("^1%.(%d+)"))
	end

	if not major or major < 11 then
		vim.notify(
			string.format(
				"Unsupported Java version '%s'. Metals requires Java 11 or newer (Java 17 recommended). Set JAVA_HOME to a JDK.",
				raw_version
			),
			vim.log.levels.WARN,
			{ title = "Metals 환경 확인" }
		)
		return false
	end

	return true
end

local function setup_format_on_save(bufnr)
	if not ENABLE_AUTO_FORMATTING then
		return
	end

	if vim.bo[bufnr].filetype == "java" then
		return
	end

	vim.api.nvim_clear_autocmds({ group = nvim_metals_group, buffer = bufnr })
	vim.api.nvim_create_autocmd("BufWritePre", {
		buffer = bufnr,
		group = nvim_metals_group,
		callback = function()
			vim.lsp.buf.format({
				timeout_ms = 3000,
				filter = function(c)
					return c.name == "metals"
				end,
			})
		end,
		desc = "Format Scala/SBT buffer on save",
	})
end

-- 지연 로딩 처리 함수
local function initialize_metals_lazy()
	if metals_starting then
		return
	end

	-- 먼저 시스템 요구사항 확인
	if not check_system_requirements() then
		vim.notify(
			"시스템 요구사항이 충족되지 않아 Metals 초기화를 중단합니다.",
			vim.log.levels.ERROR,
			{ title = "Metals 초기화 오류" }
		)
		return
	end

	metals_starting = true
	local ok, err = pcall(function()
		metals.initialize_or_attach(metals_config)
	end)

	metals_starting = false

	if not ok then
		vim.notify(
			string.format("Metals 초기화 실패: %s", err),
			vim.log.levels.ERROR,
			{ title = "Metals 초기화 오류" }
		)
	end
end

-- Metals 자동 시작 설정
local function setup_auto_start()
	vim.api.nvim_clear_autocmds({ group = nvim_metals_autostart_group })

	if not AUTO_START_METALS then
		return
	end

	-- Scala/SBT 파일 타입 감지 시 Metals 초기화
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "scala", "sbt", "java" },
		group = nvim_metals_autostart_group,
		callback = function()
			initialize_metals_lazy()
		end,
		desc = "Initialize Metals for Scala/SBT/Java files",
	})

	if vim.tbl_contains({ "scala", "sbt", "java" }, vim.bo.filetype) then
		initialize_metals_lazy()
	end
end

-- 공통 LSP 설정 적용
metals_config.on_attach = function(client, bufnr)
	-- 공통 LSP 키맵 설정 적용
	keys.on_attach(client, bufnr)
	setup_format_on_save(bufnr)

	-- Metals 특화 명령어 추가
	vim.api.nvim_buf_create_user_command(bufnr, "MetalsRestart", function()
		metals.restart_metals()
	end, { desc = "Restart Metals server" })

	-- 추가 Metals 명령어
	vim.api.nvim_buf_create_user_command(bufnr, "MetalsInfo", function()
		metals.info()
	end, { desc = "Show Metals server info" })

end

metals_config.capabilities = lsp_capabilities.default_capabilities() -- nvim-cmp 통합

-- LSP 디버깅 활성화
metals_config.flags = {
	allow_incremental_sync = true,
	debounce_text_changes = 150,
}

-- 에러 핸들러 설정
setup_error_handlers()

-- ========== 설정 적용 ========== --
apply_metals_settings()

-- Metals 로그 설정 (디버깅용, 선택적)
metals_config.handlers = {
	["metals/status"] = function(_, status)
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

-- 자동 시작 설정 적용 (필요 시에만)
setup_auto_start()

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
		if vim.fn.executable("bloop") == 0 and metals_config.settings.metals.bloopSbtAlreadyInstalled then
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

-- 수동 Metals 시작 명령어
vim.api.nvim_create_user_command("MetalsStart", function()
	initialize_metals_lazy()
end, { desc = "Start Metals manually" })

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

			if opts.auto_start ~= nil then
				AUTO_START_METALS = opts.auto_start
			end

			-- 기타 설정 병합
			metals_config = vim.tbl_deep_extend("force", metals_config, opts)
		end
		apply_metals_settings()
		setup_auto_start()
		return metals_config
	end,
	-- 수동 초기화 함수
	initialize = function()
		initialize_metals_lazy()
	end,
}
