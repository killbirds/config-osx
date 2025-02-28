local metals = require("metals")
local keys = require("config.nvim-lspconfig-keys")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

-- 전역 설정 조정
vim.opt_global.shortmess:remove("F") -- API 메시지 표시 활성화

-- Metals 기본 설정
local metals_config = metals.bare_config()

-- Metals 설정 커스터마이징
metals_config.settings = {
	serverVersion = "1.4.1", -- Metals 서버 버전 고정
	showImplicitArguments = true, -- 암묵적 인수 표시
	ammoniteJvmProperties = { "-Xmx2G" }, -- Ammonite JVM 메모리 설정
	bloopSbtAlreadyInstalled = true, -- Bloop과 SBT 설치 가정
	excludedPackages = { -- LSP에서 제외할 패키지 목록
		"akka.actor.typed.javadsl",
		"com.github.swagger.akka.javadsl",
	},
	showInferredType = true, -- 추론된 타입 표시 (추가 기능)
	superMethodLensesEnabled = true, -- 슈퍼 메서드 렌즈 활성화
}

-- 공통 LSP 설정 적용
metals_config.on_attach = function(client, bufnr)
	keys.on_attach(client, bufnr) -- 기존 키맵 설정 호출
	-- Metals 특화 명령어 추가 (선택적)
	vim.api.nvim_buf_create_user_command(bufnr, "MetalsRestart", function()
		metals.restart_server()
	end, { desc = "Restart Metals server" })
end

metals_config.capabilities = cmp_nvim_lsp.default_capabilities() -- nvim-cmp 통합
metals_config.init_options = {
	statusBarProvider = "show-message", -- 상태 표시줄을 메시지로 표시 (더 가볍게)
	isHttpEnabled = true, -- HTTP 인터페이스 활성화 (디버깅용)
}

-- 프로젝트 루트 탐지 패턴
metals_config.root_patterns = { ".git", "build.sbt", "build.sc", "project" }

-- Metals 전용 자동 명령 그룹
local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })

-- Scala 및 SBT 파일에서 Metals 초기화
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "scala", "sbt", "java" }, -- Java도 추가 (Scala 프로젝트에서 유용)
	group = nvim_metals_group,
	callback = function(opts)
		metals.initialize_or_attach(metals_config)

		-- 저장 시 자동 포매팅 및 정리
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = opts.buf,
			group = nvim_metals_group,
			callback = function()
				vim.lsp.buf.format({
					timeout_ms = 3000, -- 포매팅 타임아웃 3초
					filter = function(c)
						return c.name == "metals"
					end, -- Metals만 대상
				})
			end,
			desc = "Format Scala/SBT buffer on save",
		})

		-- Metals 상태 확인 (선택적)
		vim.api.nvim_buf_create_user_command(opts.buf, "MetalsInfo", function()
			metals.metals_info()
		end, { desc = "Show Metals server info" })
	end,
	desc = "Initialize Metals for Scala/SBT files",
})

-- Metals 로그 설정 (디버깅용, 선택적)
metals_config.handlers = {
	["metals/status"] = function(_, status, ctx)
		if status.show then
			vim.notify(status.text, vim.log.levels.INFO, { title = "Metals" })
		end
	end,
}

-- Metals 설치 확인 및 초기화 (선택적)
vim.api.nvim_create_autocmd("VimEnter", {
	group = nvim_metals_group,
	callback = function()
		if vim.fn.executable("coursier") == 0 then
			vim.notify("Coursier not found. Metals may not work properly.", vim.log.levels.WARN)
		end
	end,
	desc = "Check Coursier availability",
})
