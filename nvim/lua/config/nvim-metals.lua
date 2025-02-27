local keys = require("config.nvim-lspconfig-keys")

-- 기본 메시지 설정 수정
vim.opt_global.shortmess:remove("F")

-- Metals 설정
local metals_config = require("metals").bare_config()

metals_config.settings = {
	serverVersion = "1.4.1", -- 서버 버전 지정
	showImplicitArguments = true, -- 암묵적인 인수 표시
	ammoniteJvmProperties = { "-Xmx2G" }, -- JVM 메모리 크기 설정
	bloopSbtAlreadyInstalled = true, -- bloop과 sbt 설치 여부
	excludedPackages = { -- LSP에서 제외할 패키지
		"akka.actor.typed.javadsl",
		"com.github.swagger.akka.javadsl",
	},
}

metals_config.on_attach = keys.on_attach -- LSP 연결 시 단축키 설정
metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities() -- 자동 완성 설정
metals_config.init_options.statusBarProvider = "on" -- 상태 표시줄 설정
metals_config.root_patterns = { ".git", "build.sbt", "project" } -- 프로젝트 루트 기준 설정

-- Autocmd 그룹 설정
local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "scala", "sbt" }, -- .scala, .sbt 파일에서 LSP 시작
	callback = function(opts)
		require("metals").initialize_or_attach(metals_config) -- LSP 서버 초기화/연결

		-- 저장 시 자동 포매팅
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = opts.buf,
			callback = function()
				vim.lsp.buf.format({ timeout_ms = 3000 }) -- 3초 내에 포매팅
			end,
		})
	end,
	group = nvim_metals_group,
})
