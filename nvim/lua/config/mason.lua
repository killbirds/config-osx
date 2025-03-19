require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
		border = "rounded",
		width = 0.8,
		height = 0.8,
		keymaps = {
			toggle_package_expand = "<CR>",
			install_package = "i",
			update_package = "u",
			check_package_version = "c",
			update_all_packages = "U",
			check_outdated_packages = "C",
			uninstall_package = "X",
			cancel_installation = "<C-c>",
			apply_language_filter = "<C-f>",
		},
	},
	log_level = vim.log.levels.INFO,
	max_concurrent_installers = 4, -- 동시 설치 제한

	-- GitHub 요청 속도 제한에 도달할 경우 토큰 사용
	-- github = {
	--     -- 개인 액세스 토큰 설정
	--     -- 이 부분은 사용자가 직접 설정할 필요가 있습니다.
	--     -- token = "개인_토큰_입력",
	-- },

	-- 프록시 설정 (필요한 경우 주석 해제)
	-- install_root_dir = vim.fn.stdpath("data") .. "/mason",
	-- PATH = "prepend", -- "skip" | "prepend" | "append"
})
