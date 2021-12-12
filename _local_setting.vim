" set viminfo=
""""""""""""""""""""""""""""""""
let g:netrw_altv=1
let g:netrw_banner=0
let g:netrw_browse_split=4
let g:netrw_liststyle=3
let g:netrw_preview=1
let g:netrw_timefmt="%Y-%m-%d %H:%M:%S"
let g:netrw_winsize=30


""""""""""""""""""""""""""""""""
let g:vimrc_template_path = expand('~/vimfiles/template')
let g:Vimrc_ctags_command = expand('~') . '\scoop\apps\universal-ctags\current\ctags.exe --options=' . expand('~/vimfiles')
let g:vimrc_gtags_command = expand('~') . '\scoop\apps\global\current\bin\global.exe'
let g:stall_source_bookmark_save_file = expand('~/vimfiles/.stall.bookmark')


""""""""""""""""""""""""""""""""
"
vnoremap syy :EncloseText -a 
vnoremap sdd :EncloseText -d 
vnoremap srr :EncloseText -r 

""
command! -nargs=? -complete=dir StallFiles Stall files <args>

nnoremap <Leader>b :Stall buffer<CR>
nnoremap <Leader>u :Stall history<CR>
nnoremap <Leader>f :Stall files<CR>
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

nnoremap <silent> <F11>   :Stall ctags<CR>

nnoremap <silent> <F12>   :GTag <C-r><C-w><CR>

"
inoremap <silent> <M-e> <C-r>=Vimrc_Emoji_Complete()<CR>

"
inoremap <silent> ; <C-r>=SnippetFile_TriggerKey(';')<CR>

