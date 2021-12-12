" *****************************************************************************
""
function! s:filelist_show() "{{{
  call setloclist(0, [], ' ', {
    \ 'lines': filter(globpath(fnamemodify(getcwd(), ':p'), '*', 0, 1), { idx, val -> !isdirectory(val) }),
    \ 'efm': '%f', 'title': 'files'
    \ })

  topleft lopen

  call matchadd('Conceal', '||\s$')

  setl concealcursor=n
  setl conceallevel=3
endfunction "}}}

""
command! -nargs=? -complete=dir FileList call <SID>filelist_show()

