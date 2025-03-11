-- jj로 <Esc> 대체
vim.keymap.set("i", "jj", "<Esc>", { noremap = true })

-- 검색 하이라이트 제거
-- init.lua에 <Esc>로 하이라이트 끄는 매핑이 있으므로, 여기서는 추가 옵션으로 제공
vim.keymap.set("n", "<Leader><Space>", ":nohlsearch<CR>", { noremap = true, desc = "Clear search highlight" })

-- 시스템 클립보드 매핑 (+ 레지스터)
vim.keymap.set("v", "<Leader>y", '"+y', { noremap = true })
vim.keymap.set("v", "<Leader>d", '"+d', { noremap = true })
vim.keymap.set("n", "<Leader>p", '"+p', { noremap = true })
vim.keymap.set("n", "<Leader>P", '"+P', { noremap = true })
vim.keymap.set("v", "<Leader>p", '"+p', { noremap = true })
vim.keymap.set("v", "<Leader>P", '"+P', { noremap = true })

-- 선택 클립보드 매핑 (* 레지스터)
vim.keymap.set("", "<Leader>Y", '"*y', { noremap = true })
vim.keymap.set("", "<Leader>P", '"*p', { noremap = true })

-- 창 크기 조정
vim.keymap.set("n", "<Up>", ":resize -5<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Down>", ":resize +5<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Left>", ":vertical resize -10<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Right>", ":vertical resize +10<CR>", { noremap = true, silent = true })

-- 버퍼 탐색
vim.keymap.set("n", "<Leader>bn", ":bnext<CR>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<Leader>bp", ":bprevious<CR>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<Leader>bd", ":Bdelete<CR>", { noremap = true, silent = true, desc = "Delete buffer" })

-- 줄 이동
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { noremap = true, desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { noremap = true, desc = "Move line up" })
vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { noremap = true, desc = "Move line down" })
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { noremap = true, desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { noremap = true, desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { noremap = true, desc = "Move selection up" })

-- 터미널 모드
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true })
vim.keymap.set(
	"n",
	"<Leader>tt",
	":split | terminal<CR>i",
	{ noremap = true, desc = "Open terminal in horizontal split" }
)
vim.keymap.set(
	"n",
	"<Leader>tv",
	":vsplit | terminal<CR>i",
	{ noremap = true, desc = "Open terminal in vertical split" }
)

-- vim-visual-multi 관련 설명
-- 기본 키 매핑:
-- <C-n>: 커서 아래 단어 선택 및 다음 일치 항목 찾기
-- <C-j>/<C-k>: 커서를 위/아래로 추가
-- <S-Left/Right>: 선택 영역 확장/축소
-- 자세한 설정은 config/vim-visual-multi.lua 파일 참조

-- 오타 방지 명령어
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Q", "q", {})
vim.api.nvim_create_user_command("Wq", "wq", {})
vim.api.nvim_create_user_command("WQ", "wq", {})
