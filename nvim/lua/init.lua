-- init
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.history = 1000
vim.opt.showcmd = true
-- lualine이 모드를 표시하므로 내장 showmode는 끈다 (중복 표시 방지)
vim.opt.showmode = false

-- 0.11에서 개선된 커서 설정
vim.opt.guicursor =
	"n-v-c-sm:block-blinkwait300-blinkon200-blinkoff150,i-ci-ve:ver25-blinkwait300-blinkon200-blinkoff150,r-cr-o:hor20"
vim.opt.visualbell = true
vim.opt.autoread = true
vim.opt.autowrite = true
vim.opt.title = true
vim.opt.cursorline = true
vim.opt.hidden = true

-- UI 개선
vim.opt.relativenumber = false -- 절대 번호
vim.opt.signcolumn = "yes" -- 항상 사인 컬럼 표시 (LSP, Git 등)
vim.opt.scrolloff = 5 -- 커서 위아래 최소 줄 수
vim.opt.sidescrolloff = 5 -- 커서 좌우 최소 컬럼 수
vim.opt.wrap = false -- 긴 줄 자동 줄바꿈 비활성화
vim.opt.colorcolumn = "120" -- 120자 컬럼 표시

-- 프로젝트별 설정 지원 (exrc)
vim.opt.exrc = false -- 프로젝트 디렉토리의 .nvim.lua 등 로컬 설정 파일을 로드하지 않음
vim.opt.secure = true -- 보안을 위해 일부 명령어 제한 (exrc를 켤 경우 함께 사용 권장)

-- 리더 키 설정 (lazy.nvim과 공유)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.python3_host_prog = vim.fn.expand("~/.local/pipx/venvs/pynvim/bin/python")

-- leader 키 응답 시간 설정
vim.opt.timeout = true
vim.opt.timeoutlen = 300 -- 기본값 1000ms보다 짧게 설정하여 더 빠른 응답

-- 파일 관련 설정
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
-- swap/backup을 모두 껐으므로 영속 undo로 편집 이력을 보존한다.
vim.opt.undofile = true

-- 파일 시스템 성능 최적화
vim.opt.wildignore:append({
	"**/.git/*",
	"**/.cache/*",
	"**/node_modules/*",
	"**/target/*",
	"**/.DS_Store",
	"**/.vscode/*",
	"**/dist/*",
	"**/build/*",
})

-- 그립(grep) 관련 성능 설정
if vim.fn.executable("rg") == 1 then
	-- 리플그립(ripgrep)이 설치된 경우 사용
	vim.o.grepprg = "rg --vimgrep --no-heading --smart-case"
	vim.o.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

-- 성능 관련 설정
vim.opt.redrawtime = 2000 -- 구문 강조 처리 시간 제한 (기본값 2000ms를 명시)
vim.opt.synmaxcol = 300 -- 긴 줄 구문 강조를 300컬럼까지만 처리 (기본 3000에서 축소, 성능 개선)
vim.opt.updatetime = 200 -- 스왑 파일 쓰기 및 CursorHold 이벤트 트리거 시간 단축 (ms)

-- 추가 성능 최적화 설정
vim.opt.maxmempattern = 5000000 -- 패턴 매칭 메모리 제한 (단위 KB — 사실상 무제한으로 상향)
vim.opt.ttimeoutlen = 5 -- 키 코드 대기 시간 단축 (빠른 응답)

-- LSP 성능 최적화
vim.lsp.log.set_level("WARN") -- LSP 로그 레벨을 WARN으로 설정 (ERROR보다 약간 더 많은 정보)

-- LSP 로그 파일이 과도하게 커지는 것을 방지 (시작 시 50MB 초과면 로테이션).
-- truncate 대신 rename을 쓰는 이유: 실행 중인 다른 Neovim 인스턴스는 열어둔 fd로
-- 옮겨진 파일에 계속 쓰므로 진행 중인 로그를 잃지 않는다.
local lsp_log_path = vim.fn.stdpath("state") .. "/lsp.log"
local log_max_bytes = 50 * 1024 * 1024
local log_stat = vim.uv.fs_stat(lsp_log_path)
if log_stat and log_stat.size > log_max_bytes then
  os.rename(lsp_log_path, lsp_log_path .. ".old")
end

-- 내장 완성 동작.
-- blink.cmp는 자체 메뉴를 그려서 completeopt를 보지 않으므로, 이 값은
-- 내장 완성(<C-x><C-o> 등)과 <leader>Lt로 토글하는 vim.lsp.completion에만 적용된다.
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- 검색 설정 개선
vim.opt.ignorecase = true -- 검색 시 대소문자 무시
vim.opt.smartcase = true -- 대문자가 포함되면 대소문자 구분
vim.opt.incsearch = true -- 타이핑하는 동안 검색
vim.opt.hlsearch = true -- 검색 결과 강조

-- 0.11 개선된 splitkeep 설정
vim.opt.splitkeep = "screen" -- 화면 분할 시 커서 위치 유지

-- 유용한 자동 명령
local augroup = vim.api.nvim_create_augroup("UserAutoCommands", { clear = true })

-- 0.11 최적화된 텍스트 yank 하이라이트
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	pattern = "*",
	callback = function()
		vim.hl.on_yank({ timeout = 200 })
	end,
})

-- autoread는 외부 명령 실행 시에만 동작하므로, 포커스 복귀/버퍼 진입 시
-- 파일 변경 여부를 직접 확인해 외부 수정 사항을 반영한다.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
	group = augroup,
	callback = function()
		if vim.api.nvim_get_mode().mode ~= "c" and vim.fn.getcmdwintype() == "" then
			vim.cmd("checktime")
		end
	end,
})

-- 버퍼 메모리 관리는 cache_manager.lua에서 중앙 관리됨

-- 파일 타입별 설정
vim.filetype.add({
	extension = {
		mdx = "markdown",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "lua" },
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
		-- 0.11에서 개선된 Lua omnifunc 활용
		vim.opt_local.omnifunc = "v:lua.vim.lua_omnifunc"
		-- 0.11 기본 foldexpr 활용
		vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.opt_local.foldmethod = "expr"
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

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "java" },
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.tabstop = 2
		vim.opt_local.expandtab = true
		vim.opt_local.colorcolumn = "100"
	end,
})

-- 대용량 파일 처리는 cache_manager.lua에서 중앙 관리됨

-- 터미널 설정 자동화
vim.api.nvim_create_autocmd("TermOpen", {
	group = augroup,
	pattern = "*",
	callback = function()
		-- 0.11에서 터미널 기본 설정은 자동으로 적용됨
		vim.opt_local.relativenumber = false
		vim.opt_local.number = false
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

-- 0.11 기본 매핑 활용 알림
-- grn, grr, gri, gO, gra, CTRL-S 등의 LSP 매핑이 기본으로 제공됨
