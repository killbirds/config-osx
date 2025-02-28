-- init
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

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

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
