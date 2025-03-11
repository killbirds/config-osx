require("conform").setup({
	-- 파일 타입별 포매터 설정
	formatters_by_ft = {
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		html = { "prettier" },
		css = { "prettier" },
		json = { "prettier" },
		yaml = { "prettier" },
		markdown = { "prettier" },
		lua = { "stylua" },
		python = { "black", "isort" },
		rust = { "rustfmt" },
		go = { "gofmt" },
	},

	-- 저장 시 자동 포매팅 설정
	format_on_save = function(bufnr)
		-- 특정 파일 유형은 자동 포맷팅에서 제외
		local exclude_filetypes = { "sql", "text" }
		if vim.tbl_contains(exclude_filetypes, vim.bo[bufnr].filetype) then
			return
		end

		return {
			timeout_ms = 500,
			lsp_fallback = true,
			quiet = true, -- 포맷팅 메시지 숨김
		}
	end,

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
		isort = {
			command = "isort",
			args = { "--profile", "black", "-" },
		},
		rustfmt = {
			command = "rustfmt", -- Rust 기본 포매터
			args = { "--edition", "2024", "--emit", "stdout" }, -- Rust 2024 에디션 사용
		},
		gofmt = {
			command = "gofmt",
		},
	},

	-- 포매팅 로그 레벨
	log_level = vim.log.levels.WARN, -- 경고 레벨로 업그레이드

	-- 노티피케이션 설정
	notify_on_error = true, -- 오류 발생 시 알림
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
vim.keymap.set("n", "<leader>fmt", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { silent = true, desc = "Format buffer" })

-- 비주얼 모드에서 선택 영역만 포맷팅
vim.keymap.set("v", "<leader>fmt", function()
	require("conform").format({
		async = true,
		lsp_fallback = true,
		range = { vim.fn.line("'<"), vim.fn.line("'>") },
	})
end, { silent = true, desc = "Format selected lines" })
