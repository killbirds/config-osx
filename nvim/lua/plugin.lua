-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- 참고: mapleader와 maplocalleader는 init.lua에서 설정됩니다.

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- import your plugins
		{ import = "plugins" },
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "catppuccin" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
	-- Neovim 0.11+ ui 개선 사항 적용
	ui = {
		border = "rounded", -- 0.10 이상에서 테두리 스타일 지원 개선
		title = "Lazy Plugin Manager", -- 창 제목 설정
		backdrop = 80, -- 0.11 이상에서 배경 어둡게 설정 (0-100)
		icons = {
			-- 0.11에서 아이콘 개선을 위한 설정
			loaded = "●",
			not_loaded = "○",
		},
	},
	performance = {
		-- 0.11 권장 성능 최적화 설정
		rtp = {
			reset = false, -- 필수 플러그인만 로드하지 않음
			disabled_plugins = {
				"tohtml",
				"gzip",
				"matchit",
				"zipPlugin",
				"netrwPlugin",
				"tarPlugin",
				"tutor", -- 0.11에서 권장하는 추가 비활성화 플러그인
				"matchparen",
				"health",
				"man",
			}, -- 사용하지 않는 기본 플러그인 비활성화
		},
	},
	-- 0.11 호환성 설정 추가
	change_detection = {
		-- 파일 변경 감지 개선
		notify = true, -- 변경 감지 시 알림 표시
	},
})

-- Neovim 0.11 전용 추가 설정
if vim.fn.has("nvim-0.11") == 1 then
	-- Treesitter 비동기 하이라이팅 활성화 (기본값이지만 명시적으로 설정)
	vim.g._ts_force_sync_parsing = false

	-- 터미널 개선 기능 활용
	-- OSC 52 클립보드 지원 활성화 (기본값)
	vim.g.termfeatures = { osc52 = true }

	-- 진단 설정 개선
	vim.diagnostic.config({
		virtual_text = true, -- 0.11에서 기본 비활성화됨, 필요시 활성화
		severity_sort = true, -- 심각도별 정렬
	})

	-- LSP 기본 키매핑은 Neovim 0.11에서 자동 설정됨
	-- (grn, grr, gri, gO, gra, CTRL-S 등)
end
