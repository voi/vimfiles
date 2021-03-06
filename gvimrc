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
  function! s:set_guifont(font_name) "{{{
    let height=11
    let name=a:font_name
    let &guifont=printf('Consolas:h%d,%s:h%d', height, name, height)
    let &guifontwide=printf('%s:h%d,UD_デジタル_教科書体_N-R:h%d', name, height, height)
  endfunction "}}}

  set columns=110
  set lines=45
  set linespace=2
  set rop=type:directx,renmode:5,taamode:1,contrast:3
  " winpos 372 55
  " call s:set_guifont('IPAゴシック')
  " call s:set_guifont('NasuM')
  " call s:set_guifont('MyricaM_M')
  call s:set_guifont('Cica')
  " call s:set_guifont('UD_デジタル_教科書体_N-R')
  " call s:set_guifont('BIZ_UDゴシック')
endif

" colorscheme delek
colorscheme desert
" colorscheme suika
" colorscheme sabaku


" ***********************************************
runtime! _local_*.vim

