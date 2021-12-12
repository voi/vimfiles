" ****************************************************************
function! s:stall_get_context() "{{{
  return get(b:, 'stall_view_context', {})
endfunction "}}}

function! s:stall_set_context(context) "{{{
  if type(a:context) == v:t_dict
    let b:stall_view_context = a:context
  endif
endfunction "}}}

function! s:stall_call_handler(context, name, flags) "{{{
  let Handler = get(a:context, a:name, 0)

  if type(Handler) == v:t_func
    let result = call(Handler, [a:context, a:flags], a:context) 
  elseif type(Handler) == v:t_string 
    let result = split(execute(Handler), '\n') 
  else
    return []
  endif

  return type(result) == v:t_list ? result : []
endfunction "}}}

function! s:stall_open(mods, args) "{{{
  let sources = get(g:, 'stall_sources', {})
  let source_args = filter(copy(a:args), { idx, val -> val !~# '^-' })

  if empty(source_args) | return | endif

  let source_name = remove(source_args, 0)

  if !has_key(sources, source_name) | return | endif
  if type(sources[source_name]) != v:t_dict | return | endif

  "
  let is_vert = (a:mods =~ '\<vert\%(ical\)\?\>')
  let context = extend({
      \ '_cwd': getcwd(),
      \ '_bufnr': bufnr('%'),
      \ '_bufname': fnamemodify(bufname('%'), ':p'),
      \ '_filetype': &filetype,
      \ '_winid': win_getid(),
      \ '_args': source_args,
      \ '_do_filtering': funcref('s:stall_apply_filter'),
      \ '_redraw_view': funcref('s:stall_redraw_view'),
      \ '_get_view_items': funcref('s:stall_get_view_items'),
      \ '_get_target_item': funcref('s:stall_get_target_item'),
      \ '_switch_no_quit': funcref('s:stall_switch_no_quit'),
      \ '_converter': { val -> val },
      \ '_no_quit': 0,
      \ '_winsize': is_vert ? 0 : 16
      \ }, sources[source_name])

  "
  call s:stall_call_handler(context, '_on_init', {})

  "
  let context._items = s:stall_call_handler(context, '_collection', {})

  " open buffer
  call execute(printf('%s noautocmd silent! %snew %s %s',
      \ a:mods, (is_vert ? '' : '16'), source_name . context._bufnr, join(source_args, ' ')))

  " buffer option
  setlocal filetype=stall buftype=nofile bufhidden=hide
  setlocal noswapfile nowrap nonumber
  setlocal nolist nobuflisted
  setlocal winfixwidth winfixheight

  " default keys
  nnoremap <buffer> <silent> q :bw!<CR>
  nnoremap <buffer> <silent> r :call Stall_handle_key('_redraw_view')<CR>
  nnoremap <buffer> <silent> i :call Stall_handle_key('_do_filtering')<CR>
  nnoremap <buffer> <silent> Q :call Stall_handle_key('_switch_no_quit')<CR>

  call s:stall_call_handler(context, '_on_ready', {})
  call s:stall_update_view(context)
  call s:stall_set_context(context)
endfunction "}}}

function! s:stall_update_view(context)
  ""
  setl noreadonly modifiable

  ""
  let pattern = get(a:context, '_filter', '')
  let a:context._view_items = filter(copy(get(a:context, '_items', [])),
      \ { idx, val -> s:stall_item2line(val) =~ pattern })
  let cur_pos = line('.')
  let item_count = len(a:context._view_items)

  if item_count < line('$')
    execute printf('silent! %d,$delete_', item_count + 1)

    let cur_pos = item_count
  endif

  call setline(1, map(copy(a:context._view_items),
      \ { idx, val -> a:context._converter(s:stall_item2line(val)) }))
  call setpos('.', cur_pos)

  if a:context._winsize
    execute printf("%dwincmd _", min([a:context._winsize, len(a:context._view_items)]))
  endif

  ""
  setl readonly nomodifiable
endfunction

function! s:stall_item2line(item) "{{{
  if type(a:item) == v:t_string | return a:item | endif
  if type(a:item) == v:t_list | return get(a:item, 0, '') | endif
  if type(a:item) == v:t_dict | return get(a:item, 'text', string(a:item)) | endif

  return string(a:item)
endfunction "}}}

function! s:stall_apply_filter(context, flags) "{{{
  let a:flags._no_quit = 1
  let a:flags._update = 1
  let a:context._filter = input('> ', get(a:context, '_filter', ''))
endfunction "}}}

function! s:stall_switch_no_quit(context, flags) "{{{
  let a:flags._no_quit = 1
  let a:context._no_quit = !a:context._no_quit

  echo printf('stall: %squit', (a:context._no_quit ? 'no-' : ''))
endfunction "}}}

function! s:stall_redraw_view(context, flags) "{{{
  let a:flags._update = 1
endfunction "}}}

function! s:stall_get_view_items() dict "{{{
  return copy(get(self, '_view_items', []))
endfunction "}}}

function! s:stall_get_target_item() dict "{{{
  return get(self._get_view_items(),
      \ get(self, '_cursor_index', -1), v:null)
endfunction "}}}


" ****************************************************************
let g:stall_sources = get(g:, 'stall_sources', {})

function! Stall_handle_key(name) "{{{
  "
  let context = s:stall_get_context()
  let context._cursor_index = line('.') - 1
  let bufnr = bufnr('%')
  let flags = { '_no_quit': get(context, '_no_quit', 0) }

  call s:stall_call_handler(context, a:name, flags)

  if get(flags, '_update', 0)
    let context._items = s:stall_call_handler(context, '_collection', {})

    call s:stall_update_view(context)
  endif

  call s:stall_set_context(context)

  if get(flags, '_no_quit', 0) || get(flags, '_update', 0)
    return
  else
    execute 'bw ' . bufnr
  endif
endfunction "}}}


" ********************************
command! -nargs=+ Stall call s:stall_open('<mods>', [ <f-args> ])


" ****************************************************************
function! s:stall_source_buffer_command(cmd, item) "{{{
  execute printf('%s %s', a:cmd, matchstr(a:item, '\%(^\s*\)\zs\d\+\ze\s'))
endfunction "}}}

function! s:stall_source_buffer_open(cmd, context, flags) "{{{
  let item = a:context._get_target_item()

  if !empty(item)
    call win_gotoid(a:context._winid)
    call s:stall_source_buffer_command(a:cmd, item)
  endif
endfunction "}}}

function! s:stall_source_buffer_wipe(context, flags) "{{{
  let a:flags._update = 1
  let item = a:context._get_target_item()

  if !empty(item)
    call s:stall_source_buffer_command('bw', item)
  endif
endfunction "}}}

" ********
let g:stall_sources.buffer = {
    \ '_collection': 'ls',
    \ 'open': function('s:stall_source_buffer_open', [ 'b' ]),
    \ 'tabopen': function('s:stall_source_buffer_open', [ 'tab sp | b' ]),
    \ 'vsplit': function('s:stall_source_buffer_open', [ 'vs | b' ]),
    \ 'split': function('s:stall_source_buffer_open', [ 'sp | b' ]),
    \ 'wipe': function('s:stall_source_buffer_wipe', [])
    \ }

function! g:stall_sources.buffer._on_ready(context, flags) dict "{{{
  nnoremap <buffer> <silent> <CR> :call Stall_handle_key('open')<CR>
  nnoremap <buffer> <silent> t    :call Stall_handle_key('tabopen')<CR>
  nnoremap <buffer> <silent> v    :call Stall_handle_key('vsplit')<CR>
  nnoremap <buffer> <silent> s    :call Stall_handle_key('split')<CR>
  nnoremap <buffer> <silent> d    :call Stall_handle_key('wipe')<CR>
endfunction "}}}


" ****************************************************************
function! s:stall_source_files_open(cmd, no_quit, context, flags) "{{{
  let item = get(a:context._get_target_item(), 1, '')

  if empty(item)
    return
  elseif isdirectory(item)
    let a:context.root = item
    let a:flags._update = 1
  else
    let a:flags._no_quit = a:no_quit
    call win_gotoid(a:context._winid)

    execute printf('%s %s', a:cmd, item)
  endif
endfunction "}}}

" ********
let g:stall_sources.files = {
    \ 'enter': function('s:stall_source_files_open', [ 'e', 0 ]),
    \ 'tabopen': function('s:stall_source_files_open', [ 'tabe', 1 ]),
    \ 'vsplit': function('s:stall_source_files_open', [ 'vsp', 1 ]),
    \ 'split': function('s:stall_source_files_open', [ 'sp', 1 ]),
    \ 'enter_nq': function('s:stall_source_files_open', [ 'e', 1 ]),
    \ }

function! g:stall_sources.files._on_init(context, flags) dict "{{{
  let a:context.root = fnamemodify(get(a:context._args, 0, a:context._cwd), ':p')
endfunction "}}}

function! g:stall_sources.files._collection(context, flags) dict "{{{
  let l:root = a:context.root

  return sort(map(globpath(a:context.root, '*', 0, 1),
      \ { idx, val -> [
      \   substitute(val, '^\(.\+[/\\]\)\([^/\\]\+\)$', (isdirectory(val) ? '/' : '') . '\2\t(\1)', ''),
      \   fnamemodify(val, ':p') ] }),
      \ { i1, i2 -> i1[0] == i2[0] ? 0 : i1[0] > i2[0] ? 1 : -1 })
endfunction "}}}

function! g:stall_sources.files._on_ready(context, flags) dict "{{{
  nnoremap <buffer> <silent> <CR> :call Stall_handle_key('enter')<CR>
  nnoremap <buffer> <silent> t    :call Stall_handle_key('tabopen')<CR>
  nnoremap <buffer> <silent> v    :call Stall_handle_key('vsplit')<CR>
  nnoremap <buffer> <silent> s    :call Stall_handle_key('split')<CR>
  nnoremap <buffer> <silent> <S-CR> :call Stall_handle_key('enter_nq')<CR>
  nnoremap <buffer> <silent> -    :call Stall_handle_key('up')<CR>

  call matchadd('SpecialKey', '\t(.*)$')
  call matchadd('Statement', '^[\\/][^\\/[:space:]]\+')
endfunction "}}}

function! g:stall_sources.files.up(context, flags) dict "{{{
  let root = fnamemodify(a:context.root . '..', ':p')

  if !empty(root) 
    let a:context.root = root
    let a:flags._update = 1
  endif
endfunction "}}}


" ****************************************************************
function! s:stall_source_ctags_tag2item(tagline) "{{{
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

function! s:stall_source_ctags_append_node(root, item) "{{{
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

    call s:stall_source_ctags_append_node(node.nodes, a:item)
  endif
endfunction "}}}

function! s:stall_source_ctags_flatton_node(root, depth, list) "{{{
  "
  for node in sort(values(a:root), { obj1, obj2 -> obj1.lnum - obj2.lnum })
    "
    let node.text = repeat('  ', a:depth) . node.text

    call add(a:list, node)

    if has_key(node, 'nodes')
      call s:stall_source_ctags_flatton_node(remove(node, 'nodes'), a:depth + 1, a:list)
    endif
  endfor

  return a:list
endfunction "}}}

" ********
let g:stall_sources.ctags = {
    \ 'type_option': {
    \  'cpp': '--language-force=c++',
    \  'vim': '--language-force=vim',
    \  'markdown': '--language-force=markdown'
    \   }
    \ }

function! g:stall_sources.ctags._collection(context, flags) dict "{{{
  "
  let tmp_source = tempname() . '.' . expand('%:e')

  call writefile(getbufline('%', 1, '$'), tmp_source)

  "
  let root = {}
  let ctagsbin = get(g:, 'Vimrc_ctags_command', 'ctags')

  for item in map(
      \ systemlist(printf('%s -n -f - %s %s', ctagsbin,
      \   get(a:context.type_option, a:context._filetype, ''), tmp_source)),
      \ { idx, val -> s:stall_source_ctags_tag2item(val) })
    " 
    call s:stall_source_ctags_append_node(root, item)
  endfor

  "
  call delete(tmp_source)

  "
  let candidates = []

  return s:stall_source_ctags_flatton_node(root, 0, candidates)
endfunction "}}}

function! g:stall_sources.ctags._on_ready(context, flags) dict "{{{
  nnoremap <buffer> <silent> <CR> :call Stall_handle_key('jump')<CR>

  call matchadd('SpecialKey', '(.*)\ze\%( : \w\+\)$')
  call matchadd('Define', ' : \w\+$')
  call matchadd('SpecialKey', '__anon\w\+')
endfunction "}}}

function! g:stall_sources.ctags.jump(context, flags) dict "{{{
  let item = a:context._get_target_item()

  if !empty(item)
    call win_gotoid(a:context._winid)

    execute 'b ' . a:context._bufnr
    execute '' . get(item, 'lnum', line('.'))
  endif
endfunction "}}}


" ****************************************************************
let s:stall_source_bookmark_cache = []

function! s:stall_source_bookmark_filepath() "{{{
  return fnamemodify(expand(get(g:, 'stall_source_bookmark_save_file', '~/.stall.bookmark')), ':p')
endfunction "}}}

function! s:stall_source_bookmark_add(filepathes) "{{{
  call writefile(a:filepathes
      \ ->filter({ idx, val -> 0 > index(s:stall_source_bookmark_cache, val) })
      \ ->map({ idx, val -> fnamemodify(expand(val), ':p') }),
      \ s:stall_source_bookmark_filepath(), 'a')
endfunction "}}}

function! s:stall_source_bookmark_open(cmd, context, flags) "{{{
  let item = a:context._get_target_item()

  if !empty(item)
    call win_gotoid(a:context._winid)

    execute printf('%s %s', a:cmd, item)
  endif
endfunction "}}}

" ********
let g:stall_sources.bookmark = {
    \ '_converter': { val -> substitute(val, '^\(.*\)[\\/]\([^\\/]\+[\\/]\?\)$', '\2\t(\1)', '') },
    \ 'open': function('s:stall_source_bookmark_open', [ 'e' ]),
    \ 'tabopen': function('s:stall_source_bookmark_open', [ 'tabe' ]),
    \ 'vsplit': function('s:stall_source_bookmark_open', [ 'vsp' ]),
    \ 'split':function('s:stall_source_bookmark_open', [ 'sp' ]) 
    \ }

function! g:stall_sources.bookmark._collection(context, flags) dict "{{{
  let filepath = s:stall_source_bookmark_filepath()

  return filereadable(filepath) ? readfile(filepath) : []
endfunction "}}}

function! g:stall_sources.bookmark._on_ready(context, flags) dict "{{{
  nnoremap <buffer> <silent> <CR> :call Stall_handle_key('open')<CR>
  nnoremap <buffer> <silent> t    :call Stall_handle_key('tabopen')<CR>
  nnoremap <buffer> <silent> v    :call Stall_handle_key('vsplit')<CR>
  nnoremap <buffer> <silent> s    :call Stall_handle_key('split')<CR>

  call matchadd('SpecialKey', '\t(.*)$')
endfunction "}}}

" ********
command! -nargs=+ -complete=file StallBookmarkAdd call s:stall_source_bookmark_add([ <f-args> ])


" ****************************************************************
let s:stall_source_history_records = []

function! s:stall_history_record_file() "{{{
  if getbufvar('%', '&buftype') ==# 'nofile'
    return
  endif

  let filepath = fnamemodify(expand(bufname('%')), ':p')

  if isdirectory(filepath) || !filereadable(filepath)
    return
  endif

  if index(s:stall_source_history_records, filepath) >= 0
    call remove(s:stall_source_history_records, filepath)
  endif

  call insert(s:stall_source_history_records, filepath)
endfunction "}}}

" ********
let g:stall_sources.history = {
    \ '_converter': { val -> substitute(val, '^\(.*\)[\\/]\([^\\/]\+[\\/]\?\)$', '\2\t(\1)', '') },
    \ 'open': function('s:stall_source_bookmark_open', [ 'e' ]),
    \ 'tabopen': function('s:stall_source_bookmark_open', [ 'tabe' ]),
    \ 'vsplit': function('s:stall_source_bookmark_open', [ 'vsp' ]),
    \ 'split':function('s:stall_source_bookmark_open', [ 'sp' ]) 
    \ }

function! g:stall_sources.history._collection(context, flags) dict "{{{
  let filepath = s:stall_source_bookmark_filepath()

  return extend((filereadable(filepath) ? readfile(filepath) : []), s:stall_source_history_records)
endfunction "}}}

function! g:stall_sources.history._on_ready(context, flags) dict "{{{
  nnoremap <buffer> <silent> <CR> :call Stall_handle_key('open')<CR>
  nnoremap <buffer> <silent> t    :call Stall_handle_key('tabopen')<CR>
  nnoremap <buffer> <silent> v    :call Stall_handle_key('vsplit')<CR>
  nnoremap <buffer> <silent> s    :call Stall_handle_key('split')<CR>

  call matchadd('SpecialKey', '\t(.*)$')
endfunction "}}}

" ********
augroup stall_source_history_augroup
  autocmd!
  autocmd BufReadPost,BufWritePost * call s:stall_history_record_file()
augroup END

