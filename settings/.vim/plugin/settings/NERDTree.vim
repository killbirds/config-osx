" NERDTree
"nnoremap <F4> :NERDTreeToggle<CR>  
"silent! nmap <C-p> :NERDTreeToggle<CR>
silent! map <F2> :NERDTreeToggle<CR>
silent! map <F3> :NERDTreeFind<CR>
let g:NERDTreeToggle="<F2>"
"let g:NERDTreeMapActivateNode="<F3>"
"let g:NERDTreeMapPreview="<F4>"

"let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeShowHidden= 1
let g:NERDTreeWinSize = 30

let NERDTreeIgnore=['node_modules', '.git$', '.metals', '.bloop', '.DS_Store']
