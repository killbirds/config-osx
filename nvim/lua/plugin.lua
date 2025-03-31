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
			}, -- 사용하지 않는 기본 플러그인 비활성화
		},
	},
})
