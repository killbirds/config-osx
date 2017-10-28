"" ensime-sbt
"autocmd BufWritePost *.scala :EnTypeCheck
"nnoremap <localleader>t :EnTypeCheck<CR>
"au FileType scala nnoremap <localleader>df :EnDeclarationSplit v<CR>

if !exists(':EnTypeCheck')
  autocmd BufWritePost *.scala silent :EnTypeCheck
  nnoremap <localleader>t :EnType<CR>
  au FileType scala nnoremap <localleader>df :EnDeclarationSplit v<CR>
endif
