"" ensime-sbt
"autocmd BufWritePost *.scala :EnTypeCheck
"nnoremap <localleader>t :EnTypeCheck<CR>
"au FileType scala nnoremap <localleader>df :EnDeclarationSplit v<CR>

if !exists(':EnTypeCheck')
  nnoremap <localleader>t :EnTypeCheck<CR>
  au FileType scala nnoremap <localleader>df :EnDeclarationSplit v<CR>
endif
