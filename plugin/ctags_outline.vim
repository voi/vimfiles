" *****************************************************************************
if executable('ctags')
  "
  function! s:outline_tag2item(tagline) "{{{
    let taginfo = split(substitute(a:tagline, '[\n\r]$', '', ''), '\t')
    let name = get(taginfo, 0, '')
    let item = {
        \   'text': name,
        \   'lnum': str2nr(substitute(get(taginfo, 2, ''), ';"', '', '')),
        \   'name': name,
        \   'path': []
        \ }
    let signature = ''
    let kind = ''

    for field in taginfo[3:]
      if field =~# '^kind:'
        let kind = ' : ' . substitute(field, '^\w\+:', '', '')
      elseif field =~# '^signature:'
        let signature = substitute(field, '^\w\+:', '', '')
      elseif field =~# '^\w\+:'
        let item.path = split(substitute(field, '^\w\+:', '', ''), '::\|\.')
      endif
    endfor

    let item.text .= signature . kind
    let item.name .= signature

    return item
  endfunction "}}}

  function! s:outline_append_node(root, item) "{{{
    "
    if empty(a:item.path)
      "
      let name = remove(a:item, 'name')

      let a:item.nodes = get(get(a:root, name, {}), 'nodes', {})
      let a:root[name] = a:item

      call remove(a:item, 'path')
    else
      "
      let name = remove(a:item.path, 0)
      let node = get(a:root, name, { 'text': name })
      let node.lnum = min([ get(node, 'lnum', a:item.lnum), a:item.lnum ])
      let node.nodes = get(node, 'nodes', {})

      let a:root[name] = node

      call s:outline_append_node(node.nodes, a:item)
    endif
  endfunction "}}}

  function! s:outline_flatton_node(root, depth, list) "{{{
    "
    for node in sort(values(a:root), { obj1, obj2 -> obj1.lnum - obj2.lnum })
      "
      let node.text = repeat('..', a:depth) . node.text

      call add(a:list, node)

      if has_key(node, 'nodes')
        call s:outline_flatton_node(remove(node, 'nodes'), a:depth + 1, a:list)
      endif
    endfor

    return a:list
  endfunction "}}}

  ""
  function! s:outline_qfinfo(bufnr, fname, candidate) "{{{
    return {
        \ 'bufnr': a:bufnr,
        \ 'filename': a:fname,
        \ 'lnum': a:candidate.lnum,
        \ 'text': a:candidate.text
        \ }
  endfunction "}}}

  ""
  function! s:outline_job_close_cb(tmp_source, bufnr, fname, root) "{{{
    call delete(a:tmp_source)

    "
    let candidates = []

    call s:outline_flatton_node(a:root, 0, candidates)

    call setloclist(0, [], 'a', {
        \ 'items': map(candidates, { idx, val -> s:outline_qfinfo(a:bufnr, a:fname, val) }),
        \ 'title': 'ctags ' . a:fname })

    topleft lwindow

    call matchadd('Conceal', '^.\+|\d\+\%(\s*col\s*\d\+\)\?|')
    call matchadd('Ignore', '\.\.')
    call matchadd('SpecialKey', '(.*)\ze\%( : \w\+\)$')
    call matchadd('Define', ' : \w\+$')
    call matchadd('SpecialKey', '__anon\w\+')

    setl concealcursor=n
    setl conceallevel=3
  endfunction "}}}

  ""
  function! s:outline_job_out_cb(msg, fenc, root) "{{{
    if &encoding != a:fenc
      let out = iconv(a:msg, a:fenc, &encoding)
    else
      let out = a:msg
    endif

    "
    for item in map(split(out, '\n'), { idx, val -> s:outline_tag2item(val) })
      " 
      call s:outline_append_node(a:root, item)
    endfor
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
    let fenc = &fileencoding
    let root = {}

    call setloclist(0, [])

    call job_start(
        \ printf('ctags -n -f - %s %s', force, tmp_source), {
        \   'out_cb': { ch, msg -> s:outline_job_out_cb(msg, fenc, root) },
        \   'close_cb': { ch -> s:outline_job_close_cb(tmp_source, bufnr, fname, root) }
        \ })
  endfunction "}}}

  command! Outline call <SID>outline_show()

else
  command! Outline echo 'ctags is not installed.'

endif

