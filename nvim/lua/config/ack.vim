if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif
" Open the Ag command and place the cursor into the quotes
nnoremap <leader>ag :Ack "<cword>"<CR>
nnoremap <leader>af :AckFile "<cword>"<CR>
 
nnoremap ,ag :Ack ""<Left>
nnoremap ,af :AckFile ""<Left>
