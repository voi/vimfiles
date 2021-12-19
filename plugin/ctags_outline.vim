" *****************************************************************************
let s:force_langs = #{
    \ cpp: 'C++',
    \ cs: 'C#'
    \ }

"
function! s:ctags_outline_tag2item(tagline) "{{{
  let taginfo = split(substitute(a:tagline, '[\n\r]$', '', ''), '\t')
  let name = get(taginfo, 0, '')
  let item = #{
      \   text: name,
      \   lnum: str2nr(substitute(get(taginfo, 2, ''), ';"', '', '')),
      \   map_key: name,
      \   map_path: []
      \ }
  let signature = ''
  let kind = ''

  for field in taginfo[3:]
    if field =~# '^kind:'
      let kind = ' : ' . substitute(field, '^\w\+:', '', '')
    elseif field =~# '^signature:'
      let signature = substitute(field, '^\w\+:', '', '')
    elseif field =~# '^\w\+:'
      let item.map_path = split(substitute(field, '^\w\+:', '', ''), '::\|\.')
    endif
  endfor

  let item.text .= signature . kind
  let item.map_key .= signature

  return item
endfunction "}}}

function! s:ctags_outline_append_node(root, item) "{{{
  "
  if empty(a:item.map_path)
    "
    let key = remove(a:item, 'map_key')
    let a:item.nodes = get(get(a:root, key, {}), 'nodes', {})
    let a:root[key] = a:item

    call remove(a:item, 'map_path')
  else
    "
    let key = remove(a:item.map_path, 0)
    let node = get(a:root, key, { 'text': key })
    let node.lnum = min([ get(node, 'lnum', a:item.lnum), a:item.lnum ])
    let node.nodes = get(node, 'nodes', {})

    let a:root[key] = node

    call s:ctags_outline_append_node(node.nodes, a:item)
  endif
endfunction "}}}

function! s:ctags_outline_parse_tags(msg, fenc, root) "{{{
  "
  let out = &encoding != a:fenc ? iconv(a:msg, a:fenc, &encoding) : a:msg

  for item in map(split(out, '\n'), { idx, val -> s:ctags_outline_tag2item(val) })
    " 
    call s:ctags_outline_append_node(a:root, item)
  endfor
endfunction "}}}

function! s:ctags_outline_flatton_node(root, depth, indent, list) "{{{
  "
  for node in sort(values(a:root), { obj1, obj2 -> obj1.lnum - obj2.lnum })
    "
    let node.text = repeat(a:indent, a:depth) . node.text

    call add(a:list, node)

    if has_key(node, 'nodes')
      call s:ctags_outline_flatton_node(remove(node, 'nodes'), a:depth + 1, a:indent, a:list)
    endif
  endfor

  return a:list
endfunction "}}}

""
function! s:ctags_outline_qfinfo(bufnr, fname, candidate) "{{{
  return {
      \ 'bufnr': a:bufnr,
      \ 'filename': a:fname,
      \ 'lnum': a:candidate.lnum,
      \ 'text': a:candidate.text
      \ }
endfunction "}}}

""
function! s:ctags_outline_job_close_cb(tmp_source, bufnr, fname, root) "{{{
  call delete(a:tmp_source)
  "
  let candidates = []

  call s:ctags_outline_flatton_node(a:root, 0, '..', candidates)
  call setloclist(0, [], 'a', {
      \ 'items': map(candidates, { idx, val -> s:ctags_outline_qfinfo(a:bufnr, a:fname, val) }),
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
function! s:ctags_outline_make_command(bufexpr) "{{{
  let tmp_source = tempname() . '.' . expand('%:e')

  call writefile(getbufline(a:bufexpr, 1, '$'), tmp_source)

  let ft = &filetype
  let force = printf('--language-force=%s', 
      \ has_key(s:force_langs, ft) ? s:force_langs[&filetype] : ft)

  return [ tmp_source, printf('%s -n -f - %s %s',
      \ get(g:, 'vimrc_ctags_command', 'ctags'), force, tmp_source) ]
endfunction "}}}

""
function! s:ctags_outline_show() "{{{
  let bufnr = bufnr('%')
  let fname = expand('%')
  let fenc = &fileencoding
  let root = {}
  let [ tmp_source, cmd ] = s:ctags_outline_make_command(bufnr)

  call setloclist(0, [])
  call job_start(
      \ cmd, {
        \   'out_cb': { ch, msg -> s:ctags_outline_parse_tags(msg, fenc, root) },
        \   'close_cb': { ch -> s:ctags_outline_job_close_cb(tmp_source, bufnr, fname, root) }
        \ })
endfunction "}}}

""
command! Outline call <SID>ctags_outline_show()


" *****************************************************************************
let g:stall_sources = get(g:, 'stall_sources', {})
let g:stall_sources.ctags = {}

""
function! g:stall_sources.ctags._collection(context, item, flags) dict "{{{
  "
  let root = {}
  let [ tmp_source, cmd ] = s:ctags_outline_make_command('%')

  call s:ctags_outline_parse_tags(system(cmd), &fileencoding, root)
  call delete(tmp_source)
  "
  let candidates = []

  return s:ctags_outline_flatton_node(root, 0, '  ', candidates)
endfunction "}}}

""
function! g:stall_sources.ctags._on_ready(context, item, flags) dict "{{{
  nnoremap <buffer> <silent> <CR> :call Stall_handle_key('jump')<CR>

  call matchadd('SpecialKey', '(.*)\ze\%( : \w\+\)$')
  call matchadd('Define', ' : \w\+$')
  call matchadd('SpecialKey', '__anon\w\+')
endfunction "}}}

""
function! g:stall_sources.ctags.jump(context, item, flags) dict "{{{
  if bufexists(a:context._bufnr)
    wincmd p
    " call win_gotoid(a:context._winid)
    execute printf('b %d | %d', a:context._bufnr, get(a:item, 'lnum', line('.')))
  else
    echomsg 'stall ctags: original buffer is not exist.'
  endif
endfunction "}}}


