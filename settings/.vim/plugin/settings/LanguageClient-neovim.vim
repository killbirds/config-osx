" Required for operations modifying multiple buffers like rename.
set hidden
set completeopt=menu
set signcolumn=yes

let g:LanguageClient_useVirtualText = 0	
let g:LanguageClient_loadSettings = 1
let g:LanguageClient_autoStart = 0
"autocmd FileType javascript LanguageClientStart

let g:LanguageClient_serverCommands = {
    \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
    \ 'javascript': ['flow-language-server', '--try-flow-bin', '--stdio'],
    \ 'javascript.jsx': ['flow-language-server', '--try-flow-bin', '--stdio'],
    \ 'scala': ['metals-vim']
    \ }


let g:LanguageClient_rootMarkers = {
    \ 'javascript': ['project.json', '.git'],
    \ 'scala': ['build.sbt', '.git'],
    \ }

nnoremap <F5> :call LanguageClient_contextMenu()<CR>
" Or map each action separately
"nnoremap <leader> K :call LanguageClient#textDocument_hover()<CR>
"nnoremap <leader> gd :call LanguageClient#textDocument_definition()<CR>
"nnoremap <leader> <F2> :call LanguageClient#textDocument_rename()<CR>
