lua require('keys')

" inoremap jj <esc> " jk is escape
nnoremap <leader><space> :nohlsearch<CR>

nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>
" Copy & paste to system clipboard with <Space>p and <Space>y:
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

" clipboard
noremap <Leader>y "*y
noremap <Leader>p "*p
noremap <Leader>Y "+y
noremap <Leader>P "+p

" move with arrow key
"nnoremap <silent> <up>    :move-2<cr>
"nnoremap <silent> <down>  :move+<cr>
"nnoremap <silent> <left>  <<
"nnoremap <silent> <right> >>
"xnoremap <silent> <up>    :move-2<cr>gv
"xnoremap <silent> <down>  :move'>+<cr>gv
"xnoremap <silent> <right> >gv
"xnoremap <silent> <left>  <gv
"
" resize window with arrow key
nnoremap <silent> <up>    :res -5<cr>
nnoremap <silent> <down>  :res +5<cr>
nnoremap <silent> <left>  :vertical res -10<cr>
nnoremap <silent> <right> :vertical res +10<cr>


" Find files using Telescope command-line sugar.
nnoremap <silent> <C-p> <cmd>Telescope find_files<cr>
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" terminal
tnoremap <Esc> <C-\><C-n>

" Disable command in command mode
command! -nargs=* W w


