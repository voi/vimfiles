" ***********************************************
if has('win32')
  set columns=120
  set lines=50
  set linespace=1
  set guifont=Cica:h11,Consolas:h11
  set guifontwide=Cica:h11,HSGothicM:h11
  set rop=type:directx,renmode:5,taamode:1,contrast:3
  " winpos 372 55
endif

" colorscheme delek 
" colorscheme desert
colorscheme fruchtig

""
augroup _vimrc_local_autocmd
  autocmd BufRead,BufNewFile *.cas setf casl2
  autocmd BufRead,BufNewFile *.changelog setf changelog

  autocmd FileType casl2 setl sw=10 ts=10 sts=10
  autocmd FileType changelog setl textwidth=0
augroup END


" *****************************************************************************
"
augroup vimrc_local_cpp_include_guard 
  autocmd FileType c,cpp  command! -buffer IncGuard 
      \ let fn = toupper( expand( '%:r' )) | 
      \ call append( line('.'), [ 
      \     '#ifndef INC_' . fn . '_H_', 
      \     '#define INC_' . fn . '_H_', 
      \     '', 
      \     '', 
      \     '#endif // INC_' . fn . '_H_',
      \     ''
      \ ])
augroup END 


""
let g:changelog_spacing_errors = 0
let g:changelog_dateformat = '%Y-%m-%d'
let g:changelog_username = '<localhost>'


""
nnoremap <Leader>x :TodoToggle<CR>
xnoremap <Leader>x :TodoToggle<CR>

xnoremap syy :EncloseText -a 
xnoremap sdd :EncloseText -d 
xnoremap srr :EncloseText -r 

nnoremap sn  :Snippet 

nnoremap <silent> s. :LLs<CR>


""
nnoremap <silent> <F2>   :browse e<CR>
nnoremap <silent> <C-F2> :browse tabe<CR>
nnoremap <silent> <C-F4> :bwipeout<CR>
nnoremap <silent> <C-s>  :update<CR>

nnoremap <silent> <F9>   :lnext<CR>zz
nnoremap <silent> <S-F9> :lprevious<CR>zz

nnoremap <silent> <F10>   :cnext<CR>zz
nnoremap <silent> <S-F10> :cprevious<CR>zz

nnoremap <silent> <F11> :Outline %<CR>

nnoremap <silent> <F12>   :LGTag <C-r><C-w><CR>

