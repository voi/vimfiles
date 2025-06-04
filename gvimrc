vim9script

scriptencoding utf-8

# options
$LANG = 'ja'
# set cmdheight=1
set cursorline
set guioptions=gr
set columns=100
set lines=40
set linespace=1

# font rendering
if has('win32')
  set rop=type:directx,renmode:5,taamode:1,contrast:1
  set guifont=Cascadia_Code:h10.5,BIZ_UDゴシック:h10.5,Consolas:h10.5
  set guifontwide=BIZ_UDゴシック:h10.5

  set background=light
  colorscheme retrobox

  # colorscheme desert
endif

# ime
if has('multi_byte_ime') || has('xim')
  inoremap <silent> <Esc> <C-o>:set iminsert=0<CR><ESC>

  set iminsert=0 imsearch=0
endif

# indent guide
def GVimrc_indent_guide()
  if &expandtab
    setlocal conceallevel=2 concealcursor=iv

    for i in range(1, 32)
      call matchadd('Conceal', printf('\%%(^ \{%d}\)\zs ', i * &softtabstop), 0, -1, {'conceal': '¦'})
    endfor
  endif
enddef

augroup gvimrc_autocmd_indent_guide
  autocmd!
  autocmd FileType * call GVimrc_indent_guide()
  autocmd VimEnter,ColorScheme * highlight Conceal gui=NONE guifg=#AAAAAA guibg=NONE
augroup END

