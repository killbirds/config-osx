" 화면 오른쪽을 사용
let g:buffergator_viewport_split_policy = 'R'

" 단축키를 직접 지정하겠음
let g:buffergator_suppress_keymaps = 1

" 버퍼 돌기 (Looper buffers)
"let g:buffergator_mru_cycle_loop = 1

" 이전 버퍼로 이동
nmap <C-I> :BuffergatorMruCyclePrev<CR>

" 다음 버퍼로 이동
nmap <C-O> :BuffergatorMruCycleNext<CR>

" 모든 버퍼 보기
nmap <leader>bl :BuffergatorOpen<CR>

" 위의 첫번재 해결책과 공유하는 단축키 (버퍼 닫기를 뜻함)
nmap <leader>T :enew<CR>
" nmap <leader>bq :bp <BAR> bd #<CR>
