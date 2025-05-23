-- utils.lua
-- 유틸리티 함수들

local M = {}

-- 성능 측정 함수
function M.profile_function(func, name)
	name = name or "Function"
	local start_time = vim.uv.hrtime()
	local result = func()
	local end_time = vim.uv.hrtime()
	local duration = (end_time - start_time) / 1e6 -- 밀리초로 변환

	if duration > 100 then -- 100ms 이상일 때만 경고
		vim.notify(
			string.format("%s took %.2fms", name, duration),
			vim.log.levels.WARN,
			{ title = "Performance Warning" }
		)
	end

	return result
end

-- 메모리 사용량 확인
function M.check_memory_usage()
	local mem_usage = vim.fn.system("ps -o rss= -p " .. vim.fn.getpid())
	local mem_kb = tonumber(mem_usage:match("%d+")) or 0
	local mem_mb = math.floor(mem_kb / 1024)

	vim.notify(string.format("Neovim memory usage: %d MB", mem_mb), vim.log.levels.INFO, { title = "Memory Usage" })

	return mem_mb
end

-- LSP 서버 상태 확인
function M.check_lsp_status()
	local clients = vim.lsp.get_clients()
	if #clients == 0 then
		vim.notify("No LSP clients attached", vim.log.levels.WARN)
		return
	end

	local status_lines = {}
	for _, client in ipairs(clients) do
		table.insert(
			status_lines,
			string.format("• %s: %s", client.name, client.is_stopped() and "stopped" or "running")
		)
	end

	vim.notify(table.concat(status_lines, "\n"), vim.log.levels.INFO, { title = "LSP Status" })
end

-- 플러그인 로딩 시간 확인 (Lazy.nvim 전용)
function M.check_plugin_load_times()
	local ok, lazy = pcall(require, "lazy")
	if not ok then
		vim.notify("Lazy.nvim not found", vim.log.levels.ERROR)
		return
	end

	local stats = lazy.stats()
	vim.notify(
		string.format(
			"Plugin stats:\n• Total: %d plugins\n• Loaded: %d plugins\n• Startup time: %.2fms",
			stats.count,
			stats.loaded,
			stats.startuptime
		),
		vim.log.levels.INFO,
		{ title = "Plugin Performance" }
	)
end

-- 대용량 파일 감지
function M.is_large_file(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local filename = vim.api.nvim_buf_get_name(bufnr)

	if filename == "" then
		return false
	end

	local ok, stats = pcall(vim.uv.fs_stat, filename)
	if not ok or not stats then
		return false
	end

	-- 1MB 이상을 대용량 파일로 간주
	return stats.size > 1024 * 1024
end

-- 현재 버퍼 최적화 적용
function M.optimize_current_buffer()
	local bufnr = vim.api.nvim_get_current_buf()

	if M.is_large_file(bufnr) then
		vim.bo[bufnr].swapfile = false
		vim.bo[bufnr].undofile = false
		vim.wo.foldmethod = "manual"
		vim.wo.list = false

		vim.notify("Large file optimizations applied", vim.log.levels.INFO)
	end
end

-- 진단 요약 표시
function M.show_diagnostics_summary()
	local diagnostics = vim.diagnostic.get(0)
	local counts = { ERROR = 0, WARN = 0, INFO = 0, HINT = 0 }

	for _, diag in ipairs(diagnostics) do
		local severity = vim.diagnostic.severity[diag.severity]
		counts[severity] = counts[severity] + 1
	end

	local summary = string.format(
		"Diagnostics: %d errors, %d warnings, %d info, %d hints",
		counts.ERROR,
		counts.WARN,
		counts.INFO,
		counts.HINT
	)

	vim.notify(summary, vim.log.levels.INFO, { title = "Diagnostics Summary" })
end

-- 사용자 명령 생성
vim.api.nvim_create_user_command("CheckMemory", M.check_memory_usage, { desc = "Check Neovim memory usage" })
vim.api.nvim_create_user_command("CheckLSP", M.check_lsp_status, { desc = "Check LSP server status" })
vim.api.nvim_create_user_command("CheckPlugins", M.check_plugin_load_times, { desc = "Check plugin load times" })
vim.api.nvim_create_user_command("OptimizeBuffer", M.optimize_current_buffer, { desc = "Optimize current buffer" })
vim.api.nvim_create_user_command("DiagSummary", M.show_diagnostics_summary, { desc = "Show diagnostics summary" })

return M

