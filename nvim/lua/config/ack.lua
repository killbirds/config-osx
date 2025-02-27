-- `ag`가 실행 가능한지 확인하고, 없으면 `rg`를 기본 검색 도구로 설정
if vim.fn.executable("ag") == 1 then
	vim.g.ackprg = "ag --vimgrep"
elseif vim.fn.executable("rg") == 1 then
	vim.g.ackprg = "rg --vimgrep --no-heading --smart-case"
end

local opts = { noremap = true, silent = true }

-- 단축키 설정
vim.keymap.set("n", "<leader>ag", ':Ack "<cword>"<CR>', opts)
vim.keymap.set("n", "<leader>af", ':AckFile "<cword>"<CR>', opts)

vim.keymap.set("n", ",ag", ':Ack ""<Left>', opts)
vim.keymap.set("n", ",af", ':AckFile ""<Left>', opts)
