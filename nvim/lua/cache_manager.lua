-- cache_manager.lua
-- 0.11 최적화된 캐시 및 성능 관리자

local M = {}

-- 무시할 디렉토리 패턴 목록 (0.11 확장)
local ignore_patterns = {
	"%.cache",
	"%.git",
	"node_modules",
	"target",
	"dist",
	"%.svelte%-kit",
	"%.next",
	"build",
	"out",
	"coverage",
	"%.yarn",
	"%.pnpm",
	-- 0.11 추가 패턴
	"%.venv",
	"%.env",
	"venv",
	"__pycache__",
	"%.pytest_cache",
	"%.mypy_cache",
	"%.ruff_cache",
	"%.nx",
	"%.nuxt",
	"%.output",
	"%.turbo",
	"%.vercel",
	"%.netlify",
}

-- 0.11 향상된 디렉토리 스캔
function M.find_ignore_dirs()
	local cwd = vim.fn.getcwd()
	local handle = vim.uv.fs_scandir(cwd)
	local ignore_dirs = {}

	if handle then
		while true do
			local name, type = vim.uv.fs_scandir_next(handle)
			if not name then
				break
			end

			-- 디렉토리일 경우만 처리
			if type == "directory" then
				for _, pattern in ipairs(ignore_patterns) do
					if name:match(pattern) then
						table.insert(ignore_dirs, name)
						break
					end
				end
			end
		end
	end

	return ignore_dirs
end

-- 0.11 최적화된 파일 시스템 설정
function M.setup_fs_optimizations()
	local ignore_dirs = M.find_ignore_dirs()

	-- 기존 wildignore 패턴에 추가
	if #ignore_dirs > 0 then
		for _, dir in ipairs(ignore_dirs) do
			vim.opt.wildignore:append("**/" .. dir .. "/**")
		end

		-- 파일 시스템 감시 제외 패턴 설정
		for _, dir in ipairs(ignore_dirs) do
			vim.opt.wildignore:append(dir .. "/**")
		end

		vim.g.cache_dirs_found = ignore_dirs
	end

	return ignore_dirs
end

-- 0.11 메모리 최적화
function M.setup_memory_optimizations()
	-- 0.11에서 개선된 메모리 관리

	-- Treesitter 메모리 최적화
	vim.g.ts_max_memory_usage = 100 * 1024 * 1024 -- 100MB 제한

	-- LSP 메모리 최적화
	vim.lsp.set_log_level("WARN") -- 로그 레벨 최적화

	-- 진단 설정은 config/diagnostics.lua에서 중앙 관리됨
end

-- 0.11 버퍼 캐시 최적화
function M.setup_buffer_cache()
	local augroup = vim.api.nvim_create_augroup("CacheManager", { clear = true })

	-- 대용량 파일 감지 및 최적화
	vim.api.nvim_create_autocmd("BufReadPre", {
		group = augroup,
		pattern = "*",
		callback = function(args)
			local bufnr = args.buf
			local filename = vim.api.nvim_buf_get_name(bufnr)
			local ok, stats = pcall(vim.uv.fs_stat, filename)

			if ok and stats and stats.size > 10 * 1024 * 1024 then -- 10MB 이상
				-- 대용량 파일 최적화
				vim.b[bufnr]._large_file = true
				vim.bo[bufnr].swapfile = false
				vim.bo[bufnr].undofile = false
			end
		end,
	})

	-- 비활성 버퍼 정리 (0.11 최적화)
	vim.api.nvim_create_autocmd("BufHidden", {
		group = augroup,
		pattern = "*",
		callback = function(args)
			local bufnr = args.buf

			-- 0.11에서 개선된 버퍼 정리
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(bufnr) and not vim.bo[bufnr].modified and vim.b[bufnr]._large_file then
					vim.api.nvim_buf_delete(bufnr, { force = false })
				end
			end)
		end,
	})
end

-- 0.11 성능 모니터링
function M.setup_performance_monitoring()
	if vim.env.NVIM_PERF_MONITOR then
		local start_time = vim.uv.hrtime()

		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function()
				local load_time = (vim.uv.hrtime() - start_time) / 1e6 -- ms로 변환
				vim.schedule(function()
					vim.notify(
						string.format("Neovim loaded in %.2fms", load_time),
						vim.log.levels.INFO,
						{ title = "Performance" }
					)
				end)
			end,
		})
	end
end

-- 메인 설정 함수 (0.11 최적화)
function M.setup()
	-- 기본 파일 시스템 최적화
	local ignore_dirs = M.setup_fs_optimizations()

	-- 0.11 최적화 설정
	M.setup_memory_optimizations()
	M.setup_buffer_cache()
	M.setup_performance_monitoring()

	-- 디버그용 정보 (환경 변수로 제어)
	if vim.env.NVIM_CACHE_DEBUG and #ignore_dirs > 0 then
		vim.schedule(function()
			vim.notify(
				"Cache optimization enabled for " .. #ignore_dirs .. " directories: " .. table.concat(ignore_dirs, ", "),
				vim.log.levels.INFO,
				{ title = "Cache Manager", timeout = 3000 }
			)
		end)
	end
end

return M
