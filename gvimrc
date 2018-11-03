" vim: set filetype=vim foldmethod=marker
" vim: set et ts=2 sts=2 sw=2
scriptencoding utf-8

" ----
so $VIMRUNTIME/gvimrc_example.vim


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
runtime! _local_*.vim

