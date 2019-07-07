set laststatus=2
let g:airline_theme='solarized'
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"

let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = '|'

" 버퍼 목록 켜기
let g:airline#extensions#tabline#enabled = 1

" 파일명만 출력
let g:airline#extensions#tabline#fnamemod = ':t'

" ale integration
let g:airline#extensions#ale#enabled = 1

" coc integration
"let g:airline#extensions#coc#enabled = 1

