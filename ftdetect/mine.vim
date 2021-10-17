" ** filetype
autocmd BufNewFile,BufRead *.vcproj,*.sln,*.xaml setf xml
autocmd BufNewFile,BufRead *.cas setf casl2
autocmd BufNewFile,BufRead [Tt]odo.txt set filetype=todotxt
autocmd BufNewFile,BufRead *.[Tt]odo.txt set filetype=todotxt
autocmd BufNewFile,BufRead [Dd]one.txt set filetype=todotxt
autocmd BufNewFile,BufRead *.[Dd]one.txt set filetype=todotxt
autocmd BufNewFile,BufRead *.changelog.md,changelog.md set filetype=markdown.changelogmd
