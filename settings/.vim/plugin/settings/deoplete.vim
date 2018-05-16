let g:deoplete#enable_at_startup = 1

" Map standard Ctrl-N completion to Ctrl-Space
inoremap <C-Space> <C-n>

function g:Multiple_cursors_before()
  let g:deoplete#disable_auto_complete = 1
endfunction
function g:Multiple_cursors_after()
  let g:deoplete#disable_auto_complete = 0
endfunction

" neovim-python 0.2.4+ is required.
" https://github.com/Shougo/deoplete.nvim/issues/694
let g:deoplete#num_processes = 1
