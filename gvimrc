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
  " inoremap <silent> <C-j> <C-^>

  set iminsert=0 imsearch=0
endif

" ***********************************************
if has('win32')
  function! s:set_guifont(font_name) "{{{
    let first_font = a:font_name
    let height=11

    if empty(a:font_name)
      let name= ''
    else
      let name= printf('%s:h%d,', a:font_name)
    endif

    let &guifont=printf('%sCascadia_Mono:h%d,Consolas:h%d', name, height, height)
    let &guifontwide=printf('%sBIZ_UDゴシック:h%d', name, height)
  endfunction "}}}

  set columns=110
  set lines=45
  set linespace=1
  set rop=type:directx,renmode:5,taamode:1,contrast:3
  " set rop=type:directx,renmode:3,taamode:1,contrast:1

  " call s:set_guifont('UD_デジタル_教科書体_N-R')
  " call s:set_guifont('BIZ_UDゴシック')
  " ----
  " call s:set_guifont('Cica')
  " call s:set_guifont('HackGen')
  " call s:set_guifont('PlemolJP')
  call s:set_guifont('')
endif

" colorscheme desert-kai
colorscheme delek-kai


" ***********************************************
runtime! _local_*.vim

