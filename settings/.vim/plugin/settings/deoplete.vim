" deoplete options

let g:deoplete#enable_at_startup = 1

autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" disable autocomplete by default
call deoplete#custom#buffer_option('auto_complete', v:false)


" Disable the candidates in Comment/String syntaxes.
call deoplete#custom#source('_',
            \ 'disabled_syntaxes', ['Comment', 'String'])

call deoplete#custom#source('LanguageClient',
            \ 'min_pattern_length',
            \ 2)

" set sources
call deoplete#custom#option('sources', {
    \ '_': ['buffer'],
    \ 'javascript': ['LanguageClient', 'buffer'],
    \})

" Map standard Ctrl-N completion to Ctrl-Space
inoremap <C-Space> <C-n>

