" *****************************************************************************
""
function! s:buflist_show() "{{{
  call setloclist(0, [], ' ', {
    \ 'lines': map(filter(range(1, bufnr('$')),
    \   { idx, val -> bufexists(val) && buflisted(val) && bufloaded(val) }),
    \   { idx, val -> bufname(val) }),
    \ 'efm': '%f', 'title': 'buffers'
    \ })

  topleft lopen

  call matchadd('Conceal', '||\s$')

  setl concealcursor=n
  setl conceallevel=3
endfunction "}}}

""
command! -nargs=0 BufList call <SID>buflist_show()

