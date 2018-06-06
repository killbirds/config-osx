" deoplete options
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_smart_case = 1

" disable autocomplete by default
let b:deoplete_disable_auto_complete=1
let g:deoplete_disable_auto_complete=1
call deoplete#custom#buffer_option('auto_complete', v:false)


" Disable the candidates in Comment/String syntaxes.
call deoplete#custom#source('_',
            \ 'disabled_syntaxes', ['Comment', 'String'])

autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" set sources
"call deoplete#custom#option('sources', {
"    \ '_': ['buffer'],
"    \ 'javascript': ['LanguageClient', 'buffer'],
"    \})

" Map standard Ctrl-N completion to Ctrl-Space
inoremap <C-Space> <C-n>

function g:Multiple_cursors_before()
  let g:deoplete#disable_auto_complete = 1
endfunction
function g:Multiple_cursors_after()
  let g:deoplete#disable_auto_complete = 0
endfunction

