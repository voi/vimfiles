vim9script

## abbr datetime
inoreabbr -date- <C-r>=strftime('%Y-%m-%d')<CR>
inoreabbr /date/ <C-r>=strftime('%Y/%m/%d')<CR>
inoreabbr -time- <C-r>=strftime('%H:%M')<CR>
inoreabbr -full- <C-r>=strftime('%Y-%m-%dT%H:%M')<CR>
inoreabbr /full/ <C-r>=strftime('%Y/%m/%dT%H:%M')<CR>

##
augroup vimrc_local_autocmd
  autocmd VimEnter * Root
augroup END

##
nnoremap <silent> <C-p>f     :PopupFiles<CR>
nnoremap <silent> <C-p>F     :PopupFiles %:h<CR>
nnoremap <silent> <C-p>h     :PopupMru<CR>
nnoremap <silent> <C-p>b     :PopupBuffers<CR>
nnoremap <silent> <C-p>w     :PopupWindows<CR>
nnoremap <silent> <C-p>l     :PopupLines<CR>
nnoremap <silent> <C-p>g     :PopupGlob<CR>
nnoremap <silent> <C-p>G     :PopupGlob %:h<CR>
nnoremap <silent> <C-p><C-g> :PopupGlob!<CR>

##
nnoremap          <Leader>wa :WordHLAdd 
nnoremap <silent> <Leader>ww :WordHLAdd expand('<cword>')<CR>
xnoremap <silent> <Leader>w  :WordHLVisualAdd<CR>

##
nnoremap <Leader>s :VSCodeSnippetInsert 
inoremap <Leader>s <C-o>:VSCodeSnippetInsert 
xnoremap <Leader>s :VSCodeSnippetReplace 

##
xnoremap <Leader>eaa :EncloseText -a 
xnoremap <Leader>edd :EncloseText -d 
xnoremap <Leader>err :EncloseText -r 

xnoremap <Leader>eac :EncloseText -a -c<CR>
xnoremap <Leader>edc :EncloseText -d -c<CR>

xnoremap <silent> <Leader>ea( :EncloseText -a -t (     )<CR>
xnoremap <silent> <Leader>ea) :EncloseText -a -t (\  \ )<CR>
xnoremap <silent> <Leader>ea[ :EncloseText -a -t [     ]<CR>
xnoremap <silent> <Leader>ea] :EncloseText -a -t [\  \ ]<CR>
xnoremap <silent> <Leader>ea{ :EncloseText -a -t {     }<CR>
xnoremap <silent> <Leader>ea} :EncloseText -a -t {\  \ }<CR>
xnoremap <silent> <Leader>ea< :EncloseText -a -t <     ><CR>
xnoremap <silent> <Leader>ea> :EncloseText -a -t <\  \ ><CR>
xnoremap <silent> <Leader>ea" :EncloseText -a    " "<CR>
xnoremap <silent> <Leader>ea' :EncloseText -a    ' '<CR>
xnoremap <silent> <Leader>ea` :EncloseText -a    ` `<CR>

xnoremap <silent> <Leader>ed( :EncloseText -d -t ( )<CR>
xnoremap <silent> <Leader>ed[ :EncloseText -d -t [ ]<CR>
xnoremap <silent> <Leader>ed{ :EncloseText -d -t { }<CR>
xnoremap <silent> <Leader>ed< :EncloseText -d -t < ><CR>
xnoremap <silent> <Leader>ed" :EncloseText -d -t " "<CR>
xnoremap <silent> <Leader>ed' :EncloseText -d -t ' '<CR>
xnoremap <silent> <Leader>ed` :EncloseText -d -t ` `<CR>

