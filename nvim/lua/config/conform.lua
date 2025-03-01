require("conform").setup({
	-- 파일 타입별 포매터 설정
	formatters_by_ft = {
		javascript = { "prettier" }, -- JavaScript 포매팅
		typescript = { "prettier" }, -- TypeScript 포매팅
		lua = { "stylua" }, -- Lua 포매팅
		python = { "black" }, -- Python 포매팅
		rust = { "rustfmt" }, -- Rust 포매팅
	},

	-- 저장 시 자동 포매팅 설정
	format_on_save = {
		timeout_ms = 500, -- 포매팅 타임아웃 (ms)
		lsp_fallback = true, -- LSP 포매팅으로 대체 (포매터 없을 경우)
	},

	-- 포매터별 커스터마이징 (선택적)
	formatters = {
		prettier = {
			command = "prettier",
			args = { "--stdin-filepath", "$FILENAME" },
		},
		stylua = {
			command = "stylua",
		},
		black = {
			command = "black",
			args = { "--quiet", "--fast", "-" },
		},
		rustfmt = {
			command = "rustfmt", -- Rust 기본 포매터
			args = { "--edition", "2024", "--emit", "stdout" }, -- Rust 2024 에디션 사용
		},
	},

	-- 포매팅 로그 레벨 (디버깅용, 선택적)
	log_level = vim.log.levels.ERROR, -- 오류만 표시
})

-- 수동 포매팅 명령 추가 (선택적)
vim.api.nvim_create_user_command("Format", function(args)
	require("conform").format({
		async = true,
		lsp_fallback = true,
		range = args.range ~= 0 and { args.line1, args.line2 } or nil,
	})
end, { range = true, desc = "Format buffer or range" })

-- 수동 포매팅 키맵 (선택적)
vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { silent = true, desc = "Format buffer" })
