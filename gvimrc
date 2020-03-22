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
function! s:SetSimpleIndentGuide() abort "{{{
  if !&expandtab
    return
  endif

  setlocal conceallevel=2 concealcursor=iv

  for l:i in range(1, 16)
    call matchadd('Conceal', printf('\%%(^ \{%d}\)\zs ', i * &softtabstop), 0, -1, {'conceal': '¦'})
  endfor
endfunction "}}}

function! s:InitSimpleIndentGuide() abort "{{{
  highlight Conceal gui=NONE guifg=#AAAAAA guibg=NONE
endfunction "}}}

augroup plugin-vim-simple-indent-guide
  autocmd!
  autocmd FileType * call <SID>SetSimpleIndentGuide()
  autocmd GUIEnter,ColorScheme * call <SID>InitSimpleIndentGuide()
augroup END


" ***********************************************
if has('win32')
  set columns=100
  set lines=45
  set linespace=1
  " set guifont=NasuM:h11
  " set guifont=CamingoCode:h11
  set guifont=Hack:h11
  " set guifont=Cica:h12,Consolas:h11
  set guifontwide=Cica:h11,HGGothicM:h11
  " set guifontwide=UD_デジタル_教科書体_N-R:h11
  " set guifontwide=BIZ_UDゴシック:h11
  set rop=type:directx,renmode:5,taamode:1,contrast:3
  " winpos 372 55
endif

" colorscheme delek
" colorscheme desert
colorscheme suika


" ***********************************************
runtime! _local_*.vim

