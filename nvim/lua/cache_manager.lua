-- cache_manager.lua
-- .cache 디렉토리와 같은 불필요한 파일들을 무시하여 성능 향상

local M = {}

-- 무시할 디렉토리 패턴 목록
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
}

-- 현재 작업 디렉토리에서 무시할 디렉토리 찾기
function M.find_ignore_dirs()
	local handle = vim.uv.fs_scandir(vim.fn.getcwd())
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

-- 파일 시스템 감시에서 캐시 디렉토리 제외
function M.setup_fs_watcher_exclude()
	local ignore_dirs = M.find_ignore_dirs()

	-- 추가 Neovim 전역 옵션 설정
	if #ignore_dirs > 0 then
		-- 이미 있는 패턴에 추가
		for _, dir in ipairs(ignore_dirs) do
			vim.opt.wildignore:append("**/" .. dir .. "/**")
		end

		-- 추가 정보 설정 (필요시)
		vim.g.cache_dirs_found = ignore_dirs
	end

	return ignore_dirs
end

-- 현재 프로젝트에서 캐시 디렉토리를 제외하도록 설정
function M.setup()
	local ignore_dirs = M.setup_fs_watcher_exclude()

	-- 디버그용 알림 (필요시 활성화)
	-- if #ignore_dirs > 0 then
	--   vim.notify(
	--     "성능 향상을 위해 " .. #ignore_dirs .. "개의 캐시 디렉토리가 무시됩니다: " ..
	--     table.concat(ignore_dirs, ", "),
	--     vim.log.levels.INFO,
	--     { title = "캐시 관리", timeout = 2000 }
	--   )
	-- end
end

return M

