" vim: set filetype=vim foldmethod=marker
" vim: set et ts=2 sts=2 sw=2
scriptencoding utf-8

" ***********************************************
set cmdheight=1
set cursorline
set guioptions=gre

" ***********************************************
" japanese message
let $LANG='ja'

if has('multi_byte_ime') || has('xim')
  highlight CursorIM guibg=#9900FF guifg=NONE

  inoremap <silent> <Esc> <ESC>:set iminsert=0<CR>
  inoremap <silent> <C-j> <C-^>

  set iminsert=0 imsearch=0
endif

" ***********************************************
if has('win32')
  set columns=110
  set lines=45
  set linespace=2
  " let userFONT='IPAゴシック'
  " let userFONT='NasuM'
  " let userFONT='MyricaM_M'
  let userFONT='Cica'
  " let userFONT='UD_デジタル_教科書体_N-R'
  " let userFONT='BIZ_UDゴシック'
  let &guifont=userFONT . ':h12,Consolas:h12'
  let &guifontwide=userFONT . ':h12,UD_デジタル_教科書体_N-R:h12'
  set rop=type:directx,renmode:5,taamode:1,contrast:3
  " winpos 372 55
endif

colorscheme delek
" colorscheme desert
" colorscheme suika
" colorscheme sabaku


" ***********************************************
runtime! _local_*.vim

