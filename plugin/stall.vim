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
  let result = []
  let Handler = get(a:context, a:name, 0)

  if type(Handler) == v:t_func
    let result = call(Handler, [a:context, a:flags], a:context) 
  elseif type(Handler) == v:t_string 
    let result = split(execute(Handler), '\n') 
  endif

  if type(result) != v:t_list
    return []
  endif

  return result
endfunction "}}}

function! s:stall_open(mods, args) "{{{
  let sources = get(g:, 'stall_sources', {})
  let source_args = a:args->copy()->filter({ idx, val -> val !~# '^-' })

  if empty(source_args) | return | endif

  let source_name = remove(source_args, 0)

  if !has_key(sources, source_name) | return | endif
  if type(sources[source_name]) != v:t_dict | return | endif

  "
  let context = extend({
      \ '_cwd': getcwd(),
      \ '_bufnr': bufnr('%'),
      \ '_bufname': fnamemodify(bufname('%'), ':p'),
      \ '_filetype': &filetype,
      \ '_winid': win_getid(),
      \ '_args': source_args,
      \ '_do_toggle_mark': funcref('s:stall_toggle_mark'),
      \ '_do_filtering': funcref('s:stall_apply_filter'),
      \ '_converter': { val -> val },
      \ '_sorter': { items -> items },
      \ '_no_quit': 0
      \ }, sources[source_name])

  function! context.get_items() dict "{{{
    return get(self, '_items', [])
        \ ->copy()->map({ idx, val -> val[1] })
  endfunction "}}}

  function! context.get_view_items() dict "{{{
    return get(self, '_view_items', [])
        \ ->copy()->map({ idx, val -> val[1] })
  endfunction "}}}

  function! context.get_target_items() dict "{{{
    let targets = get(self, '_view_items', [])
        \ ->copy()
        \ ->filter({ idx, val -> val[0] })
        \ ->map({ idx, val -> val[1] })

    if !empty(targets)
      return targets
    endif

    let targets = self.get_view_items()
    let idx = get(self, '_cursor_index', -1)

    if idx < 0 || len(targets) <= idx
      return []
    else
      return [ targets[idx] ]
    endif
  endfunction "}}}

  "
  call s:stall_call_handler(context, '_on_init', {})

  "
  let context._items = s:stall_call_handler(context, '_collection', {})
      \ ->map({ idx, val -> [ 0, val ] })

  "
  let winsize = ''
  let bounds = []
  let is_popup = 0

  for opt in a:args->copy()->filter({ idx, val -> val =~# '^-' })
    if opt =~# '^-no-quit$' 
      let context._no_quit = 1
    elseif opt =~# '^-winsize=\d\+%\?$'
      let winsize = substitute(opt, '^-winsize=', '', '')
    elseif opt =~# '^-fix-height=\d\+,\d\+$'
      let bounds = split(substitute(opt, '^-fix-height=', '', ''), ',')->map({ idx, val -> str2nr(val) })
    endif
  endfor

  if is_popup
    "
    let a:context._view_items = get(a:context, '_items', [])
        \ ->copy()
    let view_lines = a:context._sorter(a:context._view_items
        \ ->copy()
        \ ->map({ idx, val -> a:context._converter(s:stall_item2line(val[1])) })))
    call popup_menu(view_lines, {})

  else
    "
    if winsize =~ '%$'
      if a:mods =~ '\<vert\%(ical\)\?\>'
        let winsize = printf('%d', (winwidth(0) * str2nr(winsize)) / 100)
      else
        let winsize = printf('%d', (winheight(0) * str2nr(winsize)) / 100)
      endif
    endif

    " open buffer
    call execute(printf('%s noautocmd silent! %snew %s %s',
        \ a:mods, winsize, source_name, join(source_args, ' ')))

    " buffer option
    setlocal filetype=stall buftype=nofile bufhidden=hide
    setlocal noswapfile nowrap nonumber
    setlocal nolist nobuflisted
    setlocal winfixwidth winfixheight

    " buffer autocmd
    doautocmd BufEnter,BufWinEnter

    " default keys
    nnoremap <buffer> <silent> q :bw!<CR>
    nnoremap <buffer> <silent> <Space> :call Stall_handle_key('_do_toggle_mark')<CR>
    nnoremap <buffer> <silent> i :call Stall_handle_key('_do_filtering')<CR>

    call s:stall_call_handler(context, '_on_ready', {})
    call s:stall_update_view(context)
    call s:stall_set_context(context)

    if !empty(bounds)
      execute printf("%dwincmd _", max([min([line('$'), bounds[1]]), bounds[0]]))
    endif
  endif
endfunction "}}}

function! s:stall_update_view(context)
  ""
  setl noreadonly modifiable

  ""
  let pattern = get(a:context, '_filter', '')
  let a:context._view_items = get(a:context, '_items', [])
      \ ->copy()
      \ ->filter({ idx, val -> s:stall_item2line(val[1]) =~ pattern })
  let cur_pos = line('.')
  let item_count = a:context._view_items->len()

  if item_count < line('$')
    execute printf('silent! %d,$delete_', item_count + 1)

    let cur_pos = item_count
  endif

  let marked = get(a:context, '_marked_char', '*')
  let unmark = get(a:context, '_unmark_char', ' ')

  call setline(1, a:context._sorter(a:context._view_items
      \ ->copy()
      \ ->map({ idx, val -> (val[0] ? marked : unmark ) . ' ' . a:context._converter(s:stall_item2line(val[1])) })))
  call setpos('.', cur_pos)

  ""
  setl readonly nomodifiable
endfunction

function! s:stall_item2line(item) "{{{
  if type(a:item) == v:t_string | return a:item | endif
  if type(a:item) == v:t_list | return get(a:item, 0, '') | endif
  if type(a:item) == v:t_dict | return get(a:item, 'text', string(a:item)) | endif

  return string(a:item)
endfunction "}}}

function! s:stall_toggle_mark(context, flags) "{{{
  let a:flags._no_quit = 1
  let idx = line('.') - 1
  let view_items = get(a:context, '_view_items', [])

  if idx < len(view_items)
    let view_items[idx][0] = !view_items[idx][0]
    let a:context._view_items = view_items

    call s:stall_update_view(a:context)
  endif
endfunction "}}}

function! s:stall_apply_filter(context, flags) "{{{
  let a:flags._no_quit = 1
  let a:context._filter = input('> ', get(a:context, '_filter', ''))

  call s:stall_update_view(a:context)
endfunction "}}}


" ****************************************************************
let g:stall_sources = {}

function! Stall_add_source(name, object) "{{{
  let sources = get(g:, 'stall_sources', {})
  let sources[a:name] = extend(get(sources, a:name, {}), a:object)
  let g:stall_sources = sources
endfunction "}}}

function! Stall_handle_key(name) "{{{
  let context = s:stall_get_context()
  let context._cursor_index = line('.') - 1
  let bufnr = bufnr('%')
  let flags = {}

  call s:stall_call_handler(context, a:name, flags)

  if get(flags, '_update', 0)
    let context._items = s:stall_call_handler(context, '_collection', {})
        \ ->map({ idx, val -> [ 0, val ] })
  endif

  if get(flags, '_update', 0) ||
      \ get(flags, '_redraw', 0)
    call s:stall_update_view(context)
  endif

  call s:stall_set_context(context)

  if get(context, '_no_quit', 0) ||
      \ get(flags, '_no_quit', 0) ||
      \ get(flags, '_update', 0) ||
      \ get(flags, '_redraw', 0)
    return
  else
    execute 'bw ' . bufnr
  endif
endfunction "}}}

function! Stall_set_source_property(source_name, prop_name, val) "{{{
  let sources = get(g:, 'stall_sources', {})

  if !has_key(sources, a:source_name)
    return
  endif

  if (a:prop_name =~# '^_') && (a:prop_name !=# '_converter') && (a:prop_name !=# '_sorter')
    return
  endif

  let sources[a:source_name][a:prop_name] = a:val
  let g:stall_sources = sources
endfunction "}}}


" ****************************************************************
function! Stall_command_complete(argLead, cmdLine, cursorPos) "{{{
  let l:pattern = '^' . a:argLead

  if a:argLead =~# '^-'
    return filter([ '-winsize=' ], 'v:val =~# l:pattern')
  else
    return filter(keys(get(g:, 'stall_sources', {})), 'v:val =~# l:pattern')
  endif
endfunction "}}}

command! -nargs=+ -complete=customlist,Stall_command_complete Stall call s:stall_open('<mods>', [ <f-args> ])


" ****************************************************************
let g:stall_source_registers = {
    \ '_collection': 'registers',
    \ 'paste_before': { context, flags -> context.paste('P', context, flags) },
    \ 'paste_after':  { context, flags -> context.paste('p', context, flags) }
    \ }

function! g:stall_source_registers._on_ready(context, flags) "{{{
  nnoremap <buffer> <silent> P :call Stall_handle_key('paste_before')<CR>
  nnoremap <buffer> <silent> p :call Stall_handle_key('paste_after')<CR>
endfunction "}}}

function! g:stall_source_registers.paste(key, context, flags) "{{{
  execute win_id2win(get(a:context, '_winid', 0)) . 'wincmd w'
  execute printf('normal %s%s',
      \ matchstr(get(a:context.get_target_items(), 0, ''), '^"\S'),
      \ a:key)
endfunction "}}}

call Stall_add_source('registers', g:stall_source_registers)


" ****************************************************************
let g:stall_source_buffer = {
    \ '_collection': 'ls',
    \ 'extract': { val -> matchstr(val, '\%(^\s*\)\zs\d\+\ze\s') },
    \ 'open':   { context, flags -> context.bopen( '      ', context, flags) },
    \ 'tabopen':{ context, flags -> context.bopen( 'tabe |', context, flags) },
    \ 'vsplit': { context, flags -> context.bopen( 'vsp  |', context, flags) },
    \ 'split':  { context, flags -> context.bopen( 'sp   |', context, flags) },
    \ }

function! g:stall_source_buffer._on_ready(context, flags) "{{{
  nnoremap <buffer> <silent> <CR> :call Stall_handle_key('open')<CR>
  nnoremap <buffer> <silent> t    :call Stall_handle_key('tabopen')<CR>
  nnoremap <buffer> <silent> v    :call Stall_handle_key('vsplit')<CR>
  nnoremap <buffer> <silent> s    :call Stall_handle_key('split')<CR>
  nnoremap <buffer> <silent> d    :call Stall_handle_key('wipe')<CR>
endfunction "}}}

function! g:stall_source_buffer.bopen(cmd, context, flags) "{{{
  execute win_id2win(get(a:context, '_winid', 0)) . 'wincmd w'

  let items = a:context.get_target_items()

  for cmd in items->map({ idx, val -> printf('%s b %s', a:cmd, a:context.extract(val)) })
    execute cmd
  endfor
endfunction "}}}

function! g:stall_source_buffer.wipe(context, flags) "{{{
  let a:flags._update = 1
  let items = a:context.get_target_items()

  for cmd in items->map({ idx, val -> printf('bw %s', a:context.extract(val)) })
    execute cmd
  endfor
endfunction "}}}

call Stall_add_source('buffer', g:stall_source_buffer)


" ****************************************************************
let g:stall_source_mru = {
    \ '_collection': 'oldfiles',
    \ '_converter': { val -> substitute(val, '^\(\d\+:\s*\)\(.*\)[\\/]\([^\\/]\+[\\/]\?\)$', '\3  :(\2)', '') },
    \ 'extract': { val -> substitute(val, '^\d\+:\s*', '', '') },
    \ 'open':   { context, flags -> context.fopen( 'e   ', context, flags) },
    \ 'tabopen':{ context, flags -> context.fopen( 'tabe', context, flags) },
    \ 'vsplit': { context, flags -> context.fopen( 'vsp ', context, flags) },
    \ 'split':  { context, flags -> context.fopen( 'sp  ', context, flags) }
    \ }

function! g:stall_source_mru._on_ready(context, flags) "{{{
  nnoremap <buffer> <silent> <CR> :call Stall_handle_key('open')<CR>
  nnoremap <buffer> <silent> t    :call Stall_handle_key('tabopen')<CR>
  nnoremap <buffer> <silent> v    :call Stall_handle_key('vsplit')<CR>
  nnoremap <buffer> <silent> s    :call Stall_handle_key('split')<CR>

  call matchadd('Comment', ':(.*)$')
endfunction "}}}

function! g:stall_source_mru.fopen(cmd, context, flags) "{{{
  execute win_id2win(get(a:context, '_winid', 0)) . 'wincmd w'

  let items = a:context.get_target_items()

  for cmd in items->map({ idx, val -> printf('%s %s', a:cmd, a:context.extract(val)) })
    execute cmd
  endfor
endfunction "}}}

call Stall_add_source('mru', g:stall_source_mru)


" ****************************************************************
let g:stall_source_files = {
    \ '_converter': { val -> substitute(val, '^\(.*\)[\\/]\([^\\/]\+[\\/]\?\)$', '\2  :(\1)', '') },
    \ 'tabopen':{ context, flags -> context.fopen('tabe', context, flags) },
    \ 'vsplit': { context, flags -> context.fopen('vsp ', context, flags) },
    \ 'split':  { context, flags -> context.fopen('sp  ', context, flags) }
    \ }

function! g:stall_source_files._on_init(context, flags) "{{{
  let a:context.root = fnamemodify(get(a:context._args, 0, a:context._cwd), ':p')
endfunction "}}}

function! g:stall_source_files._collection(context, flags) "{{{
  return globpath(a:context.root, '*', 0, 1)
      \ ->map({ idx, val -> fnamemodify(val, ':p') })
endfunction "}}}

function! g:stall_source_files._on_ready(context, flags) "{{{
  nnoremap <buffer> <silent> <CR> :call Stall_handle_key('enter')<CR>
  nnoremap <buffer> <silent> t    :call Stall_handle_key('tabopen')<CR>
  nnoremap <buffer> <silent> v    :call Stall_handle_key('vsplit')<CR>
  nnoremap <buffer> <silent> s    :call Stall_handle_key('split')<CR>
  nnoremap <buffer> <silent> u    :call Stall_handle_key('up')<CR>

  call matchadd('Comment', ':(.*)$')
  call matchadd('Statement', '[\\/]\ze ')
endfunction "}}}

function! g:stall_source_files.enter(context, flags) "{{{
  let item = get(a:context.get_target_items(), 0, '')

  if isdirectory(item)
    let a:context.root = item
    let a:flags._update = 1
  else
    call a:context.fopen('e', a:context, a:flags)
  endif
endfunction "}}}

function! g:stall_source_files.up(context, flags) "{{{
  let root = fnamemodify(a:context.root . '..', ':p')

  if !empty(root) 
    let a:context.root = root
    let a:flags._update = 1
  endif
endfunction "}}}

function! g:stall_source_files.fopen(cmd, context, flags) "{{{
  execute win_id2win(get(a:context, '_winid', 0)) . 'wincmd w'

  let items = a:command.get_target_items()

  for cmd in items->map({ idx, val -> printf('%s %s', a:cmd, val) })
    execute cmd
  endfor
endfunction "}}}

call Stall_add_source('files', g:stall_source_files)

command! -nargs=? -complete=dir StallFiles Stall files <args>


" ****************************************************************
let g:stall_source_ctags = {
    \ 'type_option': {
    \  'cpp': '--language-force=c++',
    \  'vim': '--language-force=vim',
    \  'markdown': '--language-force=markdown'
    \   }
    \ }

function! g:stall_source_ctags._collection(context, flags) "{{{
  let tmp_source = tempname() . '.' . expand('%:e')

  call writefile(getbufline('%', 1, '$'), tmp_source)

  let force = ''

  if has_key(a:context.type_option, a:context._filetype)
    let force = a:context.type_option[a:context._filetype]
  endif

  let tags = printf('ctags -n -f - %s %s', force, tmp_source)
      \ ->systemlist()
      \ ->map({ idx, val -> split(substitute(val, '[\n\r]$', '', ''), '\t') })
      \ ->map({ idx, val -> a:context.tag2item(val) })

  call delete(tmp_source)

  return tags
endfunction "}}}

function! g:stall_source_ctags._on_ready(context, flags) "{{{
  nnoremap <buffer> <silent> <CR> :call Stall_handle_key('jump')<CR>

  call matchadd('SpecialKey', '(.*)$')
  call matchadd('SpecialKey', ' : \w\+$')
  call matchadd('SpecialKey', ' \.\.\+')
  call matchadd('SpecialKey', '__anon\w\+\(\.\|::\)')
endfunction "}}}

function! g:stall_source_ctags.jump(context, flags) "{{{
  execute win_id2win(get(a:context, '_winid', 0)) . 'wincmd w'
  execute 'b ' . a:context._bufnr
  execute '' . get(get(a:context.get_target_items(), 0, {}), 'lnum', line('.'))
endfunction "}}}

function! g:stall_source_ctags.tag2item(taginfo) "{{{
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

  return {
      \   'text': prefix . get(a:taginfo, 0, '') . saffix,
      \   'lnum': str2nr(substitute(get(a:taginfo, 2, ''), ';"', '', '')),
      \ }
endfunction "}}}

call Stall_add_source('ctags', g:stall_source_ctags)


" ****************************************************************
let g:stall_source_remote = {}

function! g:stall_source_remote._on_ready(context, flags) "{{{
  nnoremap <buffer> <silent> c  :call Stall_handle_key('copy')<CR>
  nnoremap <buffer> <silent> m  :call Stall_handle_key('move')<CR>
endfunction "}}}

function! g:stall_source_remote._collection(context, flags) "{{{
  return split(serverlist(), '\n')
endfunction "}}}

function! g:stall_source_remote.copy(context, flags) "{{{
  call remote_send(get(a:context.get_target_items(), 0, ''),
      \ '<ESC>:edit ' . a:context._bufname . '<CR>')
endfunction "}}}

function! g:stall_source_remote.move(context, flags) "{{{
  call remote_send(get(a:context.get_target_items(), 0, ''),
      \ '<ESC>:edit ' . a:context._bufname . '<CR>')

  execute 'bw ' . a:context._bufnr
endfunction "}}}

call Stall_add_source('remote', g:stall_source_remote)

