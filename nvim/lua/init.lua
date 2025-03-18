-- init
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.history = 1000
vim.opt.showcmd = true
vim.opt.showmode = true
vim.opt.guicursor = "a:blinkon0"
vim.opt.visualbell = true
vim.opt.autoread = true
vim.opt.autowrite = true
vim.opt.ruler = true
vim.opt.title = true
vim.opt.cursorline = true
vim.opt.hidden = true

-- UI 개선
vim.opt.relativenumber = false -- 절대 번호
vim.opt.signcolumn = "yes" -- 항상 사인 컬럼 표시 (LSP, Git 등)
vim.opt.scrolloff = 8 -- 커서 위아래 최소 줄 수
vim.opt.sidescrolloff = 8 -- 커서 좌우 최소 컬럼 수
vim.opt.wrap = false -- 긴 줄 자동 줄바꿈 비활성화
vim.opt.colorcolumn = "120" -- 80자 컬럼 표시

-- 프로젝트별 설정 지원 (exrc)
vim.opt.exrc = true -- 프로젝트 디렉토리의 .nvim.lua, .nvimrc, .exrc 파일을 로드
vim.opt.secure = true -- 보안을 위해 일부 명령어 제한 (exrc와 함께 사용 권장)

-- 리더 키 설정 (lazy.nvim과 공유)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- leader 키 응답 시간 설정
vim.opt.timeout = true
vim.opt.timeoutlen = 300 -- 기본값 1000ms보다 짧게 설정하여 더 빠른 응답

-- 파일 관련 설정
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- 성능 최적화 설정
vim.opt.lazyredraw = true -- 매크로 실행 중 화면을 다시 그리지 않음
vim.opt.synmaxcol = 200 -- 긴 줄에서 구문 강조 제한 (성능 향상)
vim.opt.updatetime = 100 -- 스왑 파일 쓰기 및 CursorHold 이벤트 트리거 시간 (ms)

-- 검색 설정 개선
vim.opt.ignorecase = true -- 검색 시 대소문자 무시
vim.opt.smartcase = true -- 대문자가 포함되면 대소문자 구분
vim.opt.incsearch = true -- 타이핑하는 동안 검색
vim.opt.hlsearch = true -- 검색 결과 강조

-- 유용한 자동 명령
local augroup = vim.api.nvim_create_augroup("UserAutoCommands", { clear = true })

-- 마지막으로 편집한 위치로 이동
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	pattern = "*",
	callback = function()
		local line = vim.fn.line("'\"")
		if line > 1 and line <= vim.fn.line("$") then
			vim.cmd("normal! g'\"")
		end
	end,
})

-- 파일 저장 시 트레일링 공백 제거
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	pattern = "*",
	callback = function()
		local save_cursor = vim.fn.getpos(".")
		vim.cmd([[%s/\s\+$//e]])
		vim.fn.setpos(".", save_cursor)
	end,
})

-- 파일 타입별 설정
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "lua" },
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "python" },
	callback = function()
		vim.opt_local.shiftwidth = 4
		vim.opt_local.tabstop = 4
	end,
})

-- 들여쓰기 설정
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.smarttab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true

-- nvim-tree
-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true
vim.opt.background = "dark"

-- 클립보드 설정 (시스템 클립보드와 통합)
vim.opt.clipboard = "unnamedplus"

-- 창 이동 단축키
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- 비주얼 모드에서 들여쓰기 후 선택 유지
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- 참고: 다음 매핑들은 keys.lua로 이동되었습니다
-- 1. ESC로 하이라이트 끄기
-- 2. 버퍼 탐색 관련 키 매핑
-- 3. 선택 영역 이동 관련 키 매핑
-- 4. 클립보드 관련 추가 매핑
