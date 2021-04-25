if !has('gui') || !has('gui_running')
  finish
endif

function! s:SetSimpleIndentGuide() abort "{{{
  if !&expandtab
    return
  endif

  setlocal conceallevel=2 concealcursor=iv

  for l:i in range(1, 32)
    call matchadd('Conceal', printf('\%%(^ \{%d}\)\zs ', i * &softtabstop), 0, -1, {'conceal': '¦'})
  endfor
endfunction "}}}

function! s:InitSimpleIndentGuide() abort "{{{
  highlight Conceal gui=NONE guifg=#AAAAAA guibg=NONE
endfunction "}}}

augroup plugin-vim-simple-indent-guide
  autocmd!
  autocmd FileType * call s:SetSimpleIndentGuide()
  autocmd VimEnter,ColorScheme * call s:InitSimpleIndentGuide()
augroup END

