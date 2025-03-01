-- 한글 입력 관련 설정
local M = {}

function M.setup()
	-- 한글 입력 기본 설정
	vim.opt.timeoutlen = 300 -- 키 시퀀스 대기 시간 (ms) - 더 빠른 응답을 위해 감소
	vim.opt.ttimeoutlen = 10 -- 키 코드 지연 시간 감소 (모드 전환 시 더 빠른 응답)

	-- 한글 자판 매핑 (한글 상태에서 노멀 모드 명령어 사용 지원)
	vim.opt.langmap =
		"ㅁa,ㅠb,ㅊc,ㅇd,ㄷe,ㄹf,ㅎg,ㅗh,ㅑi,ㅓj,ㅏk,ㅣl,ㅡm,ㅜn,ㅐo,ㅔp,ㅂq,ㄱr,ㄴs,ㅅt,ㅕu,ㅍv,ㅈw,ㅌx,ㅛy,ㅋz"

	-- 한글 입력 관련 추가 설정
	vim.g.input_toggle = 0 -- 입력 모드 상태 추적을 위한 변수

	-- 한글 입력 상태에서 노멀 모드로 전환 시 더 빠른 응답을 위한 설정
	vim.opt.timeout = true
	vim.opt.ttimeout = true

	-- 한글 상태에서 노멀 모드 명령어 매핑
	local korean_commands = {
		-- 한글 명령어 매핑 (예: ㅈ -> w, ㅂ -> q 등)
		["ㅈ"] = "w",
		["ㅂ"] = "q",
		["ㅉ"] = "wq",
		["ㄱ"] = "g",
		["ㄷ"] = "e",
		["ㄹ"] = "f",
		["ㅁ"] = "a",
		["ㅊ"] = "c",
		["ㅌ"] = "x",
		["ㅛ"] = "y",
		["ㅔ"] = "p",
		["ㅗ"] = "h",
		["ㅓ"] = "j",
		["ㅏ"] = "k",
		["ㅣ"] = "l",
		["ㅇ"] = "d",
		["ㅅ"] = "t",
		["ㅕ"] = "u",
		["ㅑ"] = "i",
		["ㅐ"] = "o",
		["ㅠ"] = "b",
		["ㅜ"] = "n",
		["ㅡ"] = "m",
	}

	-- 한글 명령어 매핑 적용
	for k, v in pairs(korean_commands) do
		vim.keymap.set("n", ":" .. k, ":" .. v, { noremap = true })
	end

	-- 한글 상태에서 노멀 모드 명령어 실행 지원
	vim.api.nvim_create_autocmd("CmdlineEnter", {
		pattern = ":",
		callback = function()
			-- 한글 명령어를 영문으로 변환
			local cmd = vim.fn.getcmdline()
			for k, v in pairs(korean_commands) do
				cmd = cmd:gsub(k, v)
			end
			if cmd ~= vim.fn.getcmdline() then
				vim.fn.setcmdline(cmd)
			end
		end,
	})

	-- 한글 상태에서 자주 사용하는 명령어 매핑
	vim.keymap.set("n", "ㅈㅈ", "ww", { noremap = true }) -- 단어 이동
	vim.keymap.set("n", "ㄷㄷ", "ee", { noremap = true }) -- 단어 끝으로 이동
	vim.keymap.set("n", "ㅂㅂ", "qq", { noremap = true }) -- 매크로 기록
	vim.keymap.set("n", "ㄱㄱ", "gg", { noremap = true }) -- 파일 처음으로 이동
	vim.keymap.set("n", "ㄷㅇ", "dw", { noremap = true }) -- 단어 삭제
	vim.keymap.set("n", "ㅇㄷ", "dd", { noremap = true }) -- 라인 삭제
	vim.keymap.set("n", "ㅇㅈ", "dG", { noremap = true }) -- 현재부터 끝까지 삭제

	-- 한글 상태에서 비주얼 모드 진입
	vim.keymap.set("n", "ㅍ", "v", { noremap = true })
	vim.keymap.set("n", "ㅍㅍ", "V", { noremap = true })
	vim.keymap.set("n", "<C-ㅍ>", "<C-v>", { noremap = true })

	-- 한글 상태에서 자주 사용하는 기타 명령어
	vim.keymap.set("n", "ㅕ", "u", { noremap = true }) -- 실행 취소
	vim.keymap.set("n", "<C-ㄱ>", "<C-r>", { noremap = true }) -- 다시 실행
	vim.keymap.set("n", "ㅎㅎ", "G", { noremap = true }) -- 파일 끝으로 이동
	vim.keymap.set("n", "ㅇㅇ", "o", { noremap = true }) -- 아래에 새 줄 삽입
	vim.keymap.set("n", "ㅒㅒ", "O", { noremap = true }) -- 위에 새 줄 삽입
	vim.keymap.set("n", "ㅊㅊ", "cc", { noremap = true }) -- 라인 변경
	vim.keymap.set("n", "ㅛㅛ", "yy", { noremap = true }) -- 라인 복사

	-- 한글 입력 모드 전환 시 자동 영문 전환 (옵션)
	-- 이 기능을 활성화하려면 아래 주석을 해제하세요
	--[[
	vim.api.nvim_create_autocmd("InsertLeave", {
		callback = function()
			local input_source = vim.fn.system("im-select")
			if input_source:find("com.apple.inputmethod.Korean") then
				vim.fn.system("im-select com.apple.keylayout.ABC")
			end
		end,
	})
	--]]
end

return M
