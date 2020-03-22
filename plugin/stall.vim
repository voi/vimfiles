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
    let result = []
  endif

  if type(result) != v:t_list
    return []
  endif

  return result
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
      \ '_bufname': fnamemodify(bufname('%'), ':p'),
      \ '_filetype': &filetype,
      \ '_winid': win_getid(),
      \ '_args': source_args,
      \ '_do_filtering': funcref('s:stall_apply_filter'),
      \ '_get_view_items': funcref('s:stall_get_view_items'),
      \ '_get_target_item': funcref('s:stall_get_target_item'),
      \ '_converter': { val -> val },
      \ '_no_quit': 0
      \ }, sources[source_name])

  "
  call s:stall_call_handler(context, '_on_init', {})

  "
  let context._items = s:stall_call_handler(context, '_collection', {})
  "
  let winsize = ''
  let fitsize = 0

  for opt in filter(copy(a:args), { idx, val -> val =~# '^-' })
    if opt =~# '^-no-quit$' 
      let context._no_quit = 1
    elseif opt =~# '^-winsize=\d\+%\?$'
      let winsize = matchstr(opt, '\d\+%\?$')
    elseif opt =~# '^-fitsize$'
      let fitsize = 1
    endif
  endfor

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
  nnoremap <buffer> <silent> i :call Stall_handle_key('_do_filtering')<CR>

  call s:stall_call_handler(context, '_on_ready', {})
  call s:stall_update_view(context)
  call s:stall_set_context(context)

  if fitsize
    execute printf("%dwincmd _", len(context._get_view_items()))
  endif
endfunction "}}}

function! s:stall_update_view(context)
  ""
  setl noreadonly modifiable

  ""
  let pattern = get(a:context, '_filter', '')
  let a:context._view_items = filter(copy(get(a:context, '_items', [])),
      \ { idx, val -> s:stall_item2line(val[1]) =~ pattern })
  let cur_pos = line('.')
  let item_count = len(a:context._view_items)

  if item_count < line('$')
    execute printf('silent! %d,$delete_', item_count + 1)

    let cur_pos = item_count
  endif

  call setline(1, map(copy(a:context._view_items),
      \ { idx, val -> a:context._converter(s:stall_item2line(val)) }))
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

function! s:stall_apply_filter(context, flags) "{{{
  let a:flags._no_quit = 1
  let a:context._filter = input('> ', get(a:context, '_filter', ''))

  call s:stall_update_view(a:context)
endfunction "}}}

function! s:stall_get_view_items() dict "{{{
  return copy(get(self, '_view_items', []))
endfunction "}}}

function! s:stall_get_target_item() dict "{{{
  return get(self._get_view_items(),
      \ get(self, '_cursor_index', -1), v:null)
endfunction "}}}


" ****************************************************************
let g:stall_sources = {}

function! Stall_handle_key(name) "{{{
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


" ****************************************************************
function! Stall_command_complete(argLead, cmdLine, cursorPos) "{{{
  let l:pattern = '^' . a:argLead

  if a:argLead =~# '^-'
    return filter([ '-winsize=', '-fitsize', '-no-quit' ], 'v:val =~# l:pattern')
  else
    return filter(keys(get(g:, 'stall_sources', {})), 'v:val =~# l:pattern')
  endif
endfunction "}}}

command! -nargs=+ -complete=customlist,Stall_command_complete Stall call s:stall_open('<mods>', [ <f-args> ])


" ****************************************************************
let g:stall_sources.registers = {
    \ '_collection': 'registers'
    \ }

function! g:stall_sources.registers._on_ready(context, flags) dict "{{{
  nnoremap <buffer> <silent> <CR> :call Stall_handle_key('paste')<CR>
endfunction "}}}

function! g:stall_sources.registers.paste(context, flags) dict "{{{
  let item = a:context._get_target_item()

  if !empty(item)
    call win_gotoid(a:context._winid)

    execute printf('normal %sp', matchstr(item, '"\S'))
  endif
endfunction "}}}


" ****************************************************************
function! s:stall_sources_buffer_open(cmd, close, context, flags) "{{{
  let a:flags._update = !a:close
  let item = a:context._get_target_item()

  if !empty(item)
    call win_gotoid(a:context._winid)

    execute printf('%s %s', a:cmd, matchstr(item, '\%(^\s*\)\zs\d\+\ze\s'))
  endif
endfunction "}}}

let g:stall_sources.buffer = {
    \ '_collection': 'ls',
    \ 'open': function('s:stall_sources_buffer_open', [ 'b', 1 ]),
    \ 'tabopen': function('s:stall_sources_buffer_open', [ 'tab new | b', 1 ]),
    \ 'vsplit': function('s:stall_sources_buffer_open', [ 'vs | b', 1 ]),
    \ 'split': function('s:stall_sources_buffer_open', [ 'sp | b', 1 ]),
    \ 'wipe': function('s:stall_sources_buffer_open', [ 'bw', 0 ])
    \ }

function! g:stall_sources.buffer._on_ready(context, flags) dict "{{{
  nnoremap <buffer> <silent> <CR> :call Stall_handle_key('open')<CR>
  nnoremap <buffer> <silent> t    :call Stall_handle_key('tabopen')<CR>
  nnoremap <buffer> <silent> v    :call Stall_handle_key('vsplit')<CR>
  nnoremap <buffer> <silent> s    :call Stall_handle_key('split')<CR>
  nnoremap <buffer> <silent> d    :call Stall_handle_key('wipe')<CR>
endfunction "}}}


" ****************************************************************
function! s:stall_sources_mru_open(cmd, context, flags) "{{{
  let item = a:context._get_target_item()

  if !empty(item)
    call win_gotoid(a:context._winid)

    execute printf('%s %s', a:cmd, substitute(item, '^\d\+:\s*', '', ''))
  endif
endfunction "}}}

let g:stall_sources.mru = {
    \ '_collection': 'oldfiles',
    \ '_converter': { val -> substitute(val, '^\(\d\+:\s*\)\(.*\)[\\/]\([^\\/]\+[\\/]\?\)$', '\3  :(\2)', '') },
    \ 'open': function('s:stall_sources_mru_open', [ 'e' ]),
    \ 'tabopen': function('s:stall_sources_mru_open', [ 'tabe' ]),
    \ 'vsplit': function('s:stall_sources_mru_open', [ 'vsp' ]),
    \ 'split':function('s:stall_sources_mru_open', [ 'sp' ]) 
    \ }

function! g:stall_sources.mru._on_ready(context, flags) dict "{{{
  nnoremap <buffer> <silent> <CR> :call Stall_handle_key('open')<CR>
  nnoremap <buffer> <silent> t    :call Stall_handle_key('tabopen')<CR>
  nnoremap <buffer> <silent> v    :call Stall_handle_key('vsplit')<CR>
  nnoremap <buffer> <silent> s    :call Stall_handle_key('split')<CR>

  call matchadd('Comment', ':(.*)$')
endfunction "}}}


" ****************************************************************
function! s:stall_sources_files_open(cmd, context, flags) "{{{
  let item = a:context._get_target_item()

  if !empty(item) && !isdirectory(item)
    call win_gotoid(a:context._winid)

    execute printf('%s %s', a:cmd, val)
  endif
endfunction "}}}

let g:stall_sources.files = {
    \ '_converter': { val -> substitute(val, '^\(.*\)[\\/]\([^\\/]\+[\\/]\?\)$', '\2  :(\1)', '') },
    \ 'tabopen': function('s:stall_sources_files_open', [ 'tabe' ]),
    \ 'vsplit': function('s:stall_sources_files_open', [ 'vsp' ]),
    \ 'split': function('s:stall_sources_files_open', [ 'sp' ])
    \ }

function! g:stall_sources.files._on_init(context, flags) dict "{{{
  let a:context.root = fnamemodify(get(a:context._args, 0, a:context._cwd), ':p')
endfunction "}}}

function! g:stall_sources.files._collection(context, flags) dict "{{{
  return map(globpath(a:context.root, '*', 0, 1), 
      \ { idx, val -> fnamemodify(val, ':p') })
endfunction "}}}

function! g:stall_sources.files._on_ready(context, flags) dict "{{{
  nnoremap <buffer> <silent> <CR> :call Stall_handle_key('enter')<CR>
  nnoremap <buffer> <silent> t    :call Stall_handle_key('tabopen')<CR>
  nnoremap <buffer> <silent> v    :call Stall_handle_key('vsplit')<CR>
  nnoremap <buffer> <silent> s    :call Stall_handle_key('split')<CR>
  nnoremap <buffer> <silent> u    :call Stall_handle_key('up')<CR>

  call matchadd('Comment', ':(.*)$')
  call matchadd('Statement', '[\\/]\ze ')
endfunction "}}}

function! g:stall_sources.files.enter(context, flags) dict "{{{
  let item = a:context._get_target_item()

  if empty(item)
    return
  elseif isdirectory(item)
    let a:context.root = item
    let a:flags._update = 1
  else
    call a:context.fopen('e', a:context, a:flags)
  endif
endfunction "}}}

function! g:stall_sources.files.up(context, flags) dict "{{{
  let root = fnamemodify(a:context.root . '..', ':p')

  if !empty(root) 
    let a:context.root = root
    let a:flags._update = 1
  endif
endfunction "}}}

command! -nargs=? -complete=dir StallFiles Stall files <args>


" ****************************************************************
let g:stall_sources.ctags = {
    \ 'type_option': {
    \  'cpp': '--language-force=c++',
    \  'vim': '--language-force=vim',
    \  'markdown': '--language-force=markdown'
    \   }
    \ }

function! g:stall_sources.ctags._collection(context, flags) dict "{{{
  let tmp_source = tempname() . '.' . expand('%:e')

  call writefile(getbufline('%', 1, '$'), tmp_source)

  let force = ''

  if has_key(a:context.type_option, a:context._filetype)
    let force = a:context.type_option[a:context._filetype]
  endif

  let tags = map(
      \ map(systemlist(printf('ctags -n -f - %s %s', force, tmp_source)),
      \   { idx, val -> split(substitute(val, '[\n\r]$', '', ''), '\t') }),
      \   { idx, val -> s:stall_source_ctags_tag2item(val) })

  call delete(tmp_source)

  return tags
endfunction "}}}

function! g:stall_sources.ctags._on_ready(context, flags) dict "{{{
  nnoremap <buffer> <silent> <CR> :call Stall_handle_key('jump')<CR>

  call matchadd('SpecialKey', '(.*)$')
  call matchadd('SpecialKey', ' : \w\+$')
  call matchadd('SpecialKey', ' \.\.\+')
  call matchadd('SpecialKey', '__anon\w\+\(\.\|::\)')
endfunction "}}}

function! s:stall_source_ctags_jump(context, flags) dict "{{{
  let item = a:context._get_target_item()

  if !empty(item)
    call win_gotoid(a:context._winid)

    execute 'b ' . a:context._bufnr
    execute '' . get(item, 'lnum', line('.'))
  endif
endfunction "}}}

function! g:stall_sources.ctags.tag2item(taginfo) "{{{
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


" ****************************************************************
if has('gui_win32')
  let g:stall_sources.remote = {}

  function! g:stall_sources.remote._on_ready(context, flags) dict "{{{
    nnoremap <buffer> <silent> c  :call Stall_handle_key('copy')<CR>
    nnoremap <buffer> <silent> m  :call Stall_handle_key('move')<CR>
  endfunction "}}}

  function! g:stall_sources.remote._collection(context, flags) dict "{{{
    return split(serverlist(), '\n')
  endfunction "}}}

  function! g:stall_sources.remote.copy(context, flags) dict "{{{
    let item = a:context._get_target_item()

    if !empty(item)
      call remote_send(item, '<ESC>:edit ' . a:context._bufname . '<CR>')
    endif
  endfunction "}}}

  function! g:stall_sources.remote.move(context, flags) dict "{{{
    call g:stall_sources.remote.copy(a:context, a:flags)

    execute 'bw ' . a:context._bufnr
  endfunction "}}}
endif

