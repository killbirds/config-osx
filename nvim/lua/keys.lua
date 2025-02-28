-- jj로 <Esc> 대체
vim.keymap.set("i", "jj", "<Esc>", { noremap = true })

-- 검색 하이라이트 제거
vim.keymap.set("n", "<Leader><Space>", ":nohlsearch<CR>", { noremap = true })

-- 저장 및 종료
vim.keymap.set("n", "<Leader>w", ":w<CR>", { noremap = true })
vim.keymap.set("n", "<Leader>q", ":q<CR>", { noremap = true })

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

-- 터미널 모드
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true })

-- 오타 방지 명령어
vim.api.nvim_create_user_command("W", "w", {})
