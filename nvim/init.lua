-- init
require("init")
require("keys")

-- plugin manager
require("plugin")

-- fold settings
require("config.fold").setup()

-- 0.11 UI 기능 활성화
vim.o.mousemoveevent = true -- 마우스 이벤트 기능 활성화 (부동 창 호버 기능 등을 위해 필요)

-- 0.11 추가 기능 활성화
-- 터미널 개선 기능
vim.g.term_conceal = true -- 터미널 줄 숨김 기능 활성화
vim.g.term_reflow = true -- 터미널 리플로우 활성화

-- 0.11 성능 최적화 설정
vim.g._ts_force_sync_parsing = false -- Treesitter 비동기 파싱 사용

-- statuscolumn 개선 - 0.11에서 개선된 'statuscolumn' 기능 활용
vim.opt.statuscolumn = "%l %s"

-- 노멀 모드에서만 커서 라인 표시 (0.11 개선 기능)
local cursorline_group = vim.api.nvim_create_augroup("CursorLineControl", { clear = true })
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
	group = cursorline_group,
	callback = function()
		vim.opt_local.cursorline = false
	end,
})
vim.api.nvim_create_autocmd({ "InsertLeave" }, {
	group = cursorline_group,
	callback = function()
		vim.opt_local.cursorline = true
	end,
})

-- 명령줄 모드에서 이상한 문자가 나타나는 문제 해결
-- 키 매핑 문제 해결
vim.api.nvim_set_keymap("n", ":", ":", { noremap = true })

-- 입력 메소드 문제 해결
vim.api.nvim_create_autocmd({ "CmdlineEnter" }, {
	callback = function()
		-- 명령줄 모드에 들어갈 때 영문 입력 모드로 강제 전환 (im-select 플러그인이 있는 경우)
		if vim.fn.exists(":ImSelectEnable") == 2 then
			vim.cmd("ImSelectEnable")
		end

		-- Kitty 터미널 키보드 프로토콜 비활성화 (터미널 문제인 경우)
		if vim.env.TERM == "xterm-kitty" then
			vim.opt.ttimeoutlen = 10
		end
	end,
})

-- 터미널 문제 해결을 위한 환경 설정
vim.opt.timeout = true
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 50 -- 터미널 키 코드 타임아웃 단축
