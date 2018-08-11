" deoplete options

let g:deoplete#enable_at_startup = 1

autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" Disable the candidates in Comment/String syntaxes.
call deoplete#custom#source('_', 'disabled_syntaxes', ['Comment', 'String'])

call deoplete#custom#source('LanguageClient', 'min_pattern_length', 2)

" set custom sources
"call deoplete#custom#option('sources', {
"    \ '_': ['buffer'],
"    \ 'javascript': ['LanguageClient', 'buffer'],
"    \})

" Map standard Ctrl-N completion to Ctrl-Space
inoremap <C-Space> <C-n>

" disable autocomplete by default
" call deoplete#custom#buffer_option('auto_complete', v:false)

" You must disable deoplete when using vim-multiple-cursors.
function g:Multiple_cursors_before()
  call deoplete#custom#buffer_option('auto_complete', v:false)
endfunction
function g:Multiple_cursors_after()
  call deoplete#custom#buffer_option('auto_complete', v:true)
endfunction

" for debug
"call deoplete#custom#option('profile', v:true)
"call deoplete#enable_logging('DEBUG', 'deoplete.log')
"call deoplete#custom#source('javascript', 'is_debug_enabled', 1)
