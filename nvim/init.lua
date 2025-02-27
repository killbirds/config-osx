-- init.lua

-- Lua 모듈 로드
require("init")
require("plugins.packer")
require("colors")

-- Vim 설정 파일 로드
vim.cmd("source ~/.config/nvim/core/globals.vim")
vim.cmd("source ~/.config/nvim/core/keys.vim")
