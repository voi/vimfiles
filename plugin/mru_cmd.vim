" *****************************************************************************
""
function! s:mru_show() "{{{
  call setloclist(0, [], ' ', {
      \ 'lines': map(copy(v:oldfiles), { idx, val -> fnamemodify(val, ':p') }),
      \ 'efm': '%f', 'title': 'oldfiles:' })

  topleft lwindow

  call matchadd('Conceal', '||\s$')

  setl concealcursor=n
  setl conceallevel=3
endfunction "}}}

""
command! -nargs=0 Mru call <SID>mru_show()


