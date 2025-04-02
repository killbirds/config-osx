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

		-- 잠재적인 범위 명령 패턴 감지 시 명령줄 초기화
		vim.schedule(function()
			local cmdline = vim.fn.getcmdline()
			if string.match(cmdline, "^%s*[.,]%+%d+") then
				vim.fn.setcmdline("")
				vim.api.nvim_echo(
					{ { "범위 명령이 감지되어 초기화되었습니다.", "WarningMsg" } },
					false,
					{}
				)
			end
		end)
	end,
})

-- 터미널 문제 해결을 위한 환경 설정
vim.opt.timeout = true
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 50 -- 터미널 키 코드 타임아웃 단축

-- 터미널 포커스 관련 문제 해결
vim.api.nvim_create_autocmd({ "FocusGained" }, {
	callback = function()
		vim.cmd("checktime") -- 외부 변경 확인
		vim.schedule(function()
			-- 입력 버퍼 정리
			vim.api.nvim_feedkeys("", "n", true)

			-- 포커스 획득 직후 플래그 설정 (키 억제용)
			vim.g.focus_just_gained = true

			-- 명령 모드 취소 (콜론 모드에 있을 경우 탈출)
			if vim.fn.mode() == "c" then
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
			end

			-- 터미널 모드에서 돌아올 때 정상 모드로 전환
			if vim.fn.mode() == "t" then
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", true)
			end

			-- 현재 버퍼 명령 큐 초기화
			vim.cmd("redraw!")

			-- 타이머 설정: 짧은 시간 후 플래그 자동 초기화 (안전장치)
			vim.defer_fn(function()
				vim.g.focus_just_gained = false
			end, 1000) -- 1초 후 플래그 초기화
		end)
	end,
})

-- 포커스 획득 후 j/k 키 처리를 위한 매핑 추가
vim.api.nvim_create_autocmd({ "BufEnter" }, {
	callback = function()
		-- 기존 매핑 백업
		if not vim.g.original_j_mapping then
			vim.g.original_j_mapping = vim.fn.maparg("j", "n", false, true)
			vim.g.original_k_mapping = vim.fn.maparg("k", "n", false, true)
		end
	end,
})

-- 첫 j/k 키 입력 제어 (개선된 방식)
local prevent_jump = function(key)
	return function()
		-- 포커스 획득 직후 j/k 키는 무시
		if vim.g.focus_just_gained then
			vim.g.focus_just_gained = false

			-- 파일 수정 상태 원상복구 (수정된 것으로 표시되는 문제 해결)
			if vim.bo.modified and not vim.g.was_modified_before_focus_lost then
				vim.cmd("set nomodified")
			elseif not vim.bo.modified and vim.g.was_modified_before_focus_lost then
				vim.cmd("set modified")
			end

			-- 상태 변수 초기화
			vim.g.was_modified_before_focus_lost = nil

			return "<Ignore>"
		else
			return key
		end
	end
end

-- 개선된 j/k 키 매핑
vim.keymap.set("n", "j", prevent_jump("j"), { expr = true, noremap = true, desc = "Safe j movement" })
vim.keymap.set("n", "k", prevent_jump("k"), { expr = true, noremap = true, desc = "Safe k movement" })

-- 터미널 모드에서 나갈 때 입력 버퍼 정리
vim.api.nvim_create_autocmd({ "TermLeave", "TermEnter" }, {
	callback = function()
		vim.cmd("redraw")
	end,
})

-- 포커스를 잃을 때 상태 저장 및 정리
vim.api.nvim_create_autocmd({ "FocusLost" }, {
	callback = function()
		-- 현재 수정 상태 기록
		vim.g.was_modified_before_focus_lost = vim.bo.modified

		-- 입력 버퍼 정리
		vim.cmd("redraw")

		-- 포커스 획득 플래그 초기화 (안전장치)
		vim.g.focus_just_gained = false
	end,
})

-- BufLeave 이벤트 시 키 맵핑 상태 리셋
vim.api.nvim_create_autocmd({ "BufLeave" }, {
	callback = function()
		vim.g.focus_just_gained = false
	end,
})
