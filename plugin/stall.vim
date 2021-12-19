" ****************************************************************
function! s:stall_get_context() "{{{
  return get(b:, 'stall_view_context', {})
endfunction "}}}

function! s:stall_set_context(context) "{{{
  if type(a:context) == v:t_dict
    let b:stall_view_context = a:context
  endif
endfunction "}}}

function! s:stall_call_handler(context, name, item = {}, flags = {}) "{{{
  let Handler = get(a:context, a:name, 0)
  let result = type(Handler) == v:t_func ? call(Handler, [a:context, a:item, a:flags], a:context)  : []

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
  let context = extend({
      \ '_cwd': getcwd(),
      \ '_bufnr': bufnr('%'),
      \ '_filetype': &filetype,
      \ '_winid': win_getid(),
      \ '_args': source_args,
      \ '_do_filtering': funcref('s:stall_apply_filter', [ 0 ]),
      \ '_do_filtering_fuzzy': funcref('s:stall_apply_filter', [ 1 ]),
      \ '_switch_no_quit': funcref('s:stall_switch_no_quit'),
      \ '_no_quit': 0,
      \ '_is_vert': (a:mods =~ '\<vert\%(ical\)\?\>')
      \ }, sources[source_name])

  "
  call s:stall_call_handler(context, '_on_init')

  "
  let context._items = s:stall_call_handler(context, '_collection')

  " open buffer
  call execute(printf('%s noautocmd silent! %snew %s %s',
      \ a:mods, (context._is_vert ? '' : '16'), source_name . context._bufnr, join(source_args, ' ')))

  " buffer option
  setlocal filetype=stall buftype=nofile bufhidden=hide
  setlocal noswapfile nowrap nonumber
  setlocal nolist nobuflisted
  setlocal winfixwidth winfixheight

  " default keys
  nnoremap <buffer> <silent> q :bw!<CR>
  nnoremap <buffer> <silent> i :call Stall_handle_key('_do_filtering')<CR>
  nnoremap <buffer> <silent> I :call Stall_handle_key('_do_filtering_fuzzy')<CR>
  nnoremap <buffer> <silent> Q :call Stall_handle_key('_switch_no_quit')<CR>

  call s:stall_call_handler(context, '_on_ready')
  call s:stall_update_view(context)
  call s:stall_set_context(context)
endfunction "}}}

function! s:stall_update_view(context)
  ""
  setl noreadonly modifiable

  ""
  let pattern = get(a:context, '_filter', '')

  if empty(pattern)
    let a:context._view_items = get(a:context, '_items', [])
  else
    let a:context._view_items = filter(copy(get(a:context, '_items', [])),
        \ { idx, val -> has_key(val, 'text') })

    if get(a:context, '_is_fuzzy', 0)
      let a:context._view_items = matchfuzzy(a:context._view_items, pattern, #{ key: 'text' })
    else
      let a:context._view_items = filter(a:context._view_items, { idx, val -> val.text =~ pattern })
    endif
  endif

  let cur_pos = line('.')
  let item_count = len(a:context._view_items)

  if item_count < line('$')
    execute printf('silent! %d,$delete_', item_count + 1)

    let cur_pos = item_count
  endif

  call setline(1, map(copy(a:context._view_items),
      \ { idx, val -> s:stall_item_to_caption(val) }))
  call setpos('.', cur_pos)

  if !a:context._is_vert
    execute printf("%dwincmd _", min([16, len(a:context._view_items)]))
  endif

  ""
  setl readonly nomodifiable
endfunction

function! s:stall_item_to_caption(item) "{{{
  if type(a:item) == v:t_dict
    return get(a:item, 'text', string(a:item))
  else
    return string(a:item)
  endif
endfunction "}}}

function! s:stall_apply_filter(is_fuzzy, context, item, flags) "{{{
  let a:flags._no_quit = 1
  let a:flags._update = 1
  let a:context._is_fuzzy = a:is_fuzzy
  let a:context._filter = input('> ', get(a:context, '_filter', ''))
endfunction "}}}

function! s:stall_switch_no_quit(context, item, flags) "{{{
  let a:flags._no_quit = 1
  let a:context._no_quit = !a:context._no_quit

  echo printf('stall: %squit', (a:context._no_quit ? 'no-' : ''))
endfunction "}}}

function! s:stall_redraw_view(context, item, flags) "{{{
  let a:flags._update = 1
endfunction "}}}


" ****************************************************************
let g:stall_sources = get(g:, 'stall_sources', {})

function! Stall_handle_key(name) "{{{
  "
  let context = s:stall_get_context()
  let bufnr = bufnr('%')
  let flags = { '_no_quit': get(context, '_no_quit', 0) }
  let item = get(copy(get(context, '_view_items', [])), line('.') - 1, v:null)

  call s:stall_call_handler(context, a:name, item, flags)

  if get(flags, '_update', 0)
    let context._items = s:stall_call_handler(context, '_collection')

    call s:stall_update_view(context)
  endif

  call s:stall_set_context(context)

  if get(flags, '_no_quit', 0) || get(flags, '_update', 0)
    return
  else
    execute 'bw ' . bufnr
  endif
endfunction "}}}

" *****************
function! s:stall_action_apply_command(cmd, key, context, item, flags) "{{{
  if has_key(a:item, a:key)
    wincmd p
    " call win_gotoid(a:context._winid)
    execute printf('%s %s', a:cmd, a:item[a:key])
  endif
endfunction "}}}

function! Stall_get_buffer_opener() "{{{
  return {
    \ 'open': function('s:stall_action_apply_command', [ 'b', 'bufnr' ]),
    \ 'tabopen': function('s:stall_action_apply_command', [ 'tab sp | b', 'bufnr' ]),
    \ 'vsplit': function('s:stall_action_apply_command', [ 'vs | b', 'bufnr' ]),
    \ 'split': function('s:stall_action_apply_command', [ 'sp | b', 'bufnr' ])
    \ }
endfunction "}}}

function! Stall_get_file_opener() "{{{
  return {
    \ 'open': function('s:stall_action_apply_command', [ 'e', 'path' ]),
    \ 'tabopen': function('s:stall_action_apply_command', [ 'tabe', 'path' ]),
    \ 'vsplit': function('s:stall_action_apply_command', [ 'vsp', 'path' ]),
    \ 'split': function('s:stall_action_apply_command', [ 'sp', 'path' ])
    \ }
endfunction "}}}


" ****************************************************************
function! Stall_command_complete(argLead, cmdLine, cursorPos) "{{{
  return filter(keys(get(g:, 'stall_sources', {})), { idx, val -> val =~# a:argLead })
endfunction "}}}


" ********************************
command! -nargs=+ -complete=customlist,Stall_command_complete Stall 
    \ call s:stall_open('<mods>', [ <f-args> ])


" ****************************************************************
let g:stall_sources.buffer = extend({}, Stall_get_buffer_opener())

function! g:stall_sources.buffer._collection(context, item, flags) dict "{{{
  return execute('ls')->split('\n')
      \ ->map({ idx, val -> #{ text: matchstr(val, '\%(^\s*\)\zs\d\+\ze\s'), bufnr: val } })
endfunction "}}}

function! g:stall_sources.buffer._on_ready(context, item, flags) dict "{{{
  nnoremap <buffer> <silent> <CR> :call Stall_handle_key('open')<CR>
  nnoremap <buffer> <silent> t    :call Stall_handle_key('tabopen')<CR>
  nnoremap <buffer> <silent> v    :call Stall_handle_key('vsplit')<CR>
  nnoremap <buffer> <silent> s    :call Stall_handle_key('split')<CR>
  nnoremap <buffer> <silent> d    :call Stall_handle_key('wipe')<CR>
endfunction "}}}

function! g:stall_sources.buffer.wipe(context, item, flags) dict "{{{
  let a:flags._update = 1

  if has_key(a:item, 'bufnr')
    execute printf('bw %s', a:item.bufnr)
  endif
endfunction "}}}


" ****************************************************************
function! s:stall_source_files_open(cmd, no_quit, context, item, flags) "{{{
  if has_key(a:item, 'path')
    if isdirectory(a:item.path)
      let a:context.root = a:item.path
      let a:flags._update = 1
    else
      let a:flags._no_quit = a:no_quit

      call s:stall_action_apply_command(a:cmd, 'path', a:context, a:item, a:flags)
    endif
  endif
endfunction "}}}

" ********
let g:stall_sources.files = {
    \ 'enter': function('s:stall_source_files_open', [ 'e', 0 ]),
    \ 'tabopen': function('s:stall_source_files_open', [ 'tabe', 1 ]),
    \ 'vsplit': function('s:stall_source_files_open', [ 'vsp', 1 ]),
    \ 'split': function('s:stall_source_files_open', [ 'sp', 1 ]),
    \ 'enter_no_quit': function('s:stall_source_files_open', [ 'e', 1 ]),
    \ }

function! g:stall_sources.files._on_init(context, item, flags) dict "{{{
  let a:context.root = fnamemodify(get(a:context._args, 0, a:context._cwd), ':p')
endfunction "}}}

function! g:stall_sources.files._collection(context, item, flags) dict "{{{
  return sort(map(globpath(a:context.root, '*', 0, 1),
      \ { idx, val -> #{
      \   text: substitute(val, '^\(.\+[/\\]\)\([^/\\]\+\)$', (isdirectory(val) ? '/' : '') . '\2\t(\1)', ''),
      \   path: fnamemodify(val, ':p') } }),
      \ { i1, i2 -> i1.path ==# i2.path ? 0 : i1.path ># i2.path ? 1 : -1 })
endfunction "}}}

function! g:stall_sources.files._on_ready(context, item, flags) dict "{{{
  nnoremap <buffer> <silent> <CR> :call Stall_handle_key('enter')<CR>
  nnoremap <buffer> <silent> t    :call Stall_handle_key('tabopen')<CR>
  nnoremap <buffer> <silent> v    :call Stall_handle_key('vsplit')<CR>
  nnoremap <buffer> <silent> s    :call Stall_handle_key('split')<CR>
  nnoremap <buffer> <silent> <S-CR> :call Stall_handle_key('enter_with_quit')<CR>
  nnoremap <buffer> <silent> -    :call Stall_handle_key('up')<CR>

  call matchadd('SpecialKey', '\t(.*)$')
  call matchadd('Statement', '^[\\/][^\\/[:space:]]\+')
endfunction "}}}

function! g:stall_sources.files.up(context, item, flags) dict "{{{
  let root = fnamemodify(a:context.root . '..', ':p')

  if !empty(root) 
    let a:context.root = root
    let a:flags._update = 1
  endif
endfunction "}}}


" ****************************************************************
let s:stall_source_history_records = []

function! s:stall_source_bookmark_filepath() "{{{
  return fnamemodify(expand(get(g:, 'stall_source_bookmark_save_file', '~/.stall.bookmark')), ':p')
endfunction "}}}

function! s:stall_source_bookmark_add(filepathes) "{{{
  call writefile(a:filepathes
      \ ->map({ idx, val -> fnamemodify(expand(val), ':p') }),
      \ s:stall_source_bookmark_filepath(), 'a')
endfunction "}}}

function! s:stall_history_record_file() "{{{
  if getbufvar('%', '&buftype') ==# 'nofile'
    return
  endif

  let filepath = fnamemodify(expand(bufname('%')), ':p')

  if isdirectory(filepath) || !filereadable(filepath)
    return
  endif

  if index(s:stall_source_history_records, filepath) < 0
    call insert(s:stall_source_history_records, filepath)
  endif
endfunction "}}}

" ********
let g:stall_sources.history = extend({}, Stall_get_file_opener())

function! g:stall_sources.history._collection(context, item, flags) dict "{{{
  let filepath = s:stall_source_bookmark_filepath()

  return extend((filereadable(filepath) ? readfile(filepath) : []), s:stall_source_history_records)
      \ ->map({ idx, val -> #{
      \   text: substitute(val, '^\(.*\)[\\/]\([^\\/]\+[\\/]\?\)$', '\2\t(\1)', ''),
      \   path: val
      \ } })
endfunction "}}}

function! g:stall_sources.history._on_ready(context, item, flags) dict "{{{
  nnoremap <buffer> <silent> <CR> :call Stall_handle_key('open')<CR>
  nnoremap <buffer> <silent> t    :call Stall_handle_key('tabopen')<CR>
  nnoremap <buffer> <silent> v    :call Stall_handle_key('vsplit')<CR>
  nnoremap <buffer> <silent> s    :call Stall_handle_key('split')<CR>

  call matchadd('SpecialKey', '\t(.*)$')
endfunction "}}}

" ********
command! -nargs=+ -complete=file StallBookmarkAdd call s:stall_source_bookmark_add([ <f-args> ])

" ********
augroup stall_source_history_augroup
  autocmd!
  autocmd BufReadPost,BufWritePost * call s:stall_history_record_file()
augroup END

