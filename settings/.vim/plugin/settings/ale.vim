" Put this in vimrc or a plugin file of your own.
" After this is configured, :ALEFix will try and fix your JS code with ESLint.
let g:ale_fixers = {
\   'javascript': ['prettier'],
\}

" Set this setting in vimrc if you want to fix files automatically on save.
" This is off by default.
let g:ale_fix_on_save = 1

let g:ale_sign_column_always = 1

let g:ale_javascript_prettier_use_local_config = 1

" Set this. Airline will handle the rest.
let g:airline#extensions#ale#enabled = 1