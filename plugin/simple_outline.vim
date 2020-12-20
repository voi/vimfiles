" *****************************************************************************
if executable('ctags')
  ""
  function! s:outline_tag2line(bufnr, fname, taginfo) "{{{
    let prefix = ''
    let saffix = ''

    for field in a:taginfo[3:]
      if field =~# '^kind:'
        let saffix = ' : ' . substitute(field, '^\w\+:', '', '')
      elseif field =~# '^signature:'
        let saffix = substitute(field, '^\w\+:', '', '')
      elseif field =~# '^\w\+:'
        let prefix = substitute(field, '^\w\+:', '', '') . '.'
      endif
    endfor

    return printf('%s\t%s\t%s', a:fname, get(a:taginfo, 2, '1'), prefix . get(a:taginfo, 0, '') . saffix)
  endfunction "}}}

  ""
  function! s:outline_job_close_cb(tmp_source) "{{{
    call delete(a:tmp_source)

    topleft lwindow

    call matchadd('Conceal', '^.\+|\d\+\%(\s*col\s*\d\+\)\?|')
    call matchadd('SpecialKey', '(.*)$')
    call matchadd('SpecialKey', ' : \w\+$')
    call matchadd('SpecialKey', ' \.\.\+')
    call matchadd('SpecialKey', '__anon\w\+\(\.\|::\)')

    setl concealcursor=n
    setl conceallevel=3
  endfunction "}}}

  ""
  function! s:outline_job_out_cb(msg, bufnr, fname) "{{{
    call setloclist(0, [], 'a', {
        \ 'lines': split(a:msg, '\n')->map({ idx, val -> s:outline_tag2line(a:bufnr, a:fname, val) }),
        \ 'efm': '%f\t%l\t%m', 'title': 'ctags ' . a:fname })
  endfunction "}}}

  ""
  function! s:outline_show() "{{{
    let tmp_source = tempname() . '.' . expand('%:e')

    call writefile(getbufline('%', 1, '$'), tmp_source)

    let force = '' " ' --jcode=utf8 '

    if &filetype ==# 'cpp' | let force .= '--language-force=c++' | endif
    if &filetype ==# 'vim' | let force .= '--language-force=vim' | endif
    if &filetype ==# 'markdown' | let force .= '--language-force=markdown' | endif

    let bufnr = bufnr('%')
    let fname = expand('%')

    call setloclist(0, [])

    call job_start(
        \ printf('ctags -n -f - %s %s', force, tmp_source), {
        \   'out_cb': { ch, msg -> s:outline_job_out_cb(msg, fname) },
        \   'close_cb': { ch -> s:outline_job_close_cb(tmp_source) }
        \ })
  endfunction "}}}

  command! Outline call <SID>outline_show()

else
  command! Outline echo 'ctags is not installed.'

endif

