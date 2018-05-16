let g:deoplete#enable_at_startup = 1

" Map standard Ctrl-N completion to Ctrl-Space
inoremap <C-Space> <C-n>

function g:Multiple_cursors_before()
  let g:deoplete#disable_auto_complete = 1
endfunction
function g:Multiple_cursors_after()
  let g:deoplete#disable_auto_complete = 0
endfunction

