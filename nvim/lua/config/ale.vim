" Put this in vimrc or a plugin file of your own.
" After this is configured, :ALEFix will try and fix your JS code with ESLint.
let g:ale_fixers = {
\   'javascript': ['prettier'],
\   'javascriptreact': ['prettier'],
\   'js': ['prettier'],
\   'typescript': ['prettier'],
\   'typescriptreact': ['prettier'],
\   'scss': ['prettier'],
\   'css': ['prettier'],
\   'json': ['prettier'],
\   'java': [],
\   'scala': [],
\}

let g:ale_lint_on_save = 0
let g:ale_linters_explicit = 1

let g:ale_linters = {
\   'java': [],
\   'javascript': ['eslint'],
\   'scala': [],
\   'typescript': [],
\}

" Set this setting in vimrc if you want to fix files automatically on save.
" This is off by default.
let g:ale_fix_on_save = 1

" Language Server Protocol linters
let g:ale_completion_enabled = 0
let g:ale_disable_lsp = 1

let g:ale_sign_column_always = 1

let g:ale_javascript_prettier_use_local_config = 1

let g:ale_scala_scalafmt_executable = 'ng'

let g:ale_java_google_java_format_options = '--aosp --skip-sorting-imports --offset 0 --length 120'

let g:ale_java_checkstyle_options = '-c ~/.custom_java_checks.xml'

