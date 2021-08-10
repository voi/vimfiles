" set viminfo=
"
vnoremap syy :EncloseText -a 
vnoremap sdd :EncloseText -d 
vnoremap srr :EncloseText -r 

""
command! -nargs=? -complete=dir StallFiles Stall -fitsize files <args>

nnoremap <Leader>b :Stall -fitsize buffer<CR>
nnoremap <Leader>u :Stall -fitsize history<CR>
nnoremap <Leader>f :Stall -fitsize files<CR>
nnoremap <Leader>F :StallFiles 


""
nnoremap <silent> <Leader><Leader> :up<CR>


""
nnoremap <silent> <F9>    :lnext<CR>zz
nnoremap <silent> <S-F9>  :lprevious<CR>zz
nnoremap <silent> <C-F9>  :topleft lw<CR>

nnoremap <silent> <F10>   :cnext<CR>zz
nnoremap <silent> <S-F10> :cprevious<CR>zz
nnoremap <silent> <C-F10> :topleft cw<CR>

nnoremap <silent> <F11>   :Stall -fitsize ctags<CR>

nnoremap <silent> <F12>   :GTag <C-r><C-w><CR>

"
inoremap <silent> <M-e> <C-r>=Vimrc_Emoji_Complete()<CR>

"
inoremap <silent> ; <C-r>=SnippetFile_TriggerKey(';')<CR>

