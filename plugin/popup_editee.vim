vim9script

var popup_editee_glob_last_cache_buffer = tempname()

var path_slash = has('win32') ? '\' : '/'
var icons = { file: '📝', dir: '📁', empty: '🈳', buf: '📜', win: '📑' }

var pattern_type_dir = '\v^(dir|linkd)$'
var pattern_type_file = '\v^(file|link)$'
var pattern_ignore_dir = '^\%(\.git\|\.svn\)$'
var pattern_ignore_file = '\%(^_FOSSIL_\|\.exe\|\.dll\|\.docx\?\|\.xls[xm]\?\|\.vsdx\?|\.pdf\)$'

def PopupEditee_update_variables()
  icons.file  = get(g:, 'popup_editee_icon_file',  icons.file)
  icons.dir   = get(g:, 'popup_editee_icon_dir',   icons.dir)
  icons.empty = get(g:, 'popup_editee_icon_empty', icons.empty)
  icons.buf   = get(g:, 'popup_editee_icon_buff',  icons.buf)
  icons.win   = get(g:, 'popup_editee_icon_wind',  icons.win)

  pattern_ignore_dir = get(g:, 'popup_editee_glob_regex_ignore_dir', pattern_ignore_dir)
  pattern_ignore_file = get(g:, 'popup_editee_glob_regex_ignore_file', pattern_ignore_file)
enddef

def Popup_win_resize(winid: number, items: list<any>)
  var h_ = ([items->len(), [&lines, winheight(0)]->max() * 8 / 10]->min())
  var w_ = ([&columns, winwidth(0)]->max() * 9 / 10)

  call popup_move(winid, { minheight: h_, maxheight: h_, maxwidth: w_ })
enddef

def PopupEditee_set_list(winid: number, caption: string, items: list<any>)
  if !caption->empty() | call popup_setoptions(winid, { title: caption }) | endif

  call popup_settext(winid, items)
  call Popup_win_resize(winid, items)
enddef

def PopupEditee_path_to_candidate(icon: string, path: string): string
  var chunks = path->substitute('^\(.*\)[\//]\([^\//]\+\)$', '\1\n\2', '')->split('\n')

  return printf('%s %s (%s)', icon, get(chunks, 1, path), get(chunks, 0, '.'))
enddef

def PopupEditee_files_make_list(root: string): list<any>
  return readdirex(root)
    ->filter((i, v) => {
      return (
        ((v.type =~# pattern_type_dir)  && (v.name !~# pattern_ignore_dir)) ||
        ((v.type =~# pattern_type_file) && (v.name !~# pattern_ignore_file)))
    })
    ->map((i, v) => ({
      text: printf('%s %s (%s)', ((v.type =~# pattern_type_dir) ? icons.dir : icons.file), v.name, root),
      path: root .. path_slash .. v.name
    }))
enddef

def PopupEditee_files_action_open(command_format: string, winid: number, ctx: any)
  var path = ctx.active->get(line('.', winid) - 1, '')->get('path', '')

  if path->isdirectory()
    var children = PopupEditee_files_make_list(path->fnamemodify(':p'))

    if empty(children)
      echomsg icons.empty .. ' No files in ' ..  path->fnamemodify(':t') .. '/'

    else
      ctx.source = children
      ctx.active = children

      call PopupEditee_set_list(winid, printf(' Files (%d): %s ', ctx.active->len(), path), ctx.active)
    endif
  else
    call popup_close(winid)

    execute printf(command_format, path)
  endif
enddef

var popup_editee_file_open_handlers = {
  "\<CR>": function(PopupEditee_files_action_open, ['edit %s']),
  't': function(PopupEditee_files_action_open, ['tabedit %s'])
}

def PopupEditee_files_action_up(winid: number, ctx: any)
  #
  var path = ctx.active->get(line('.', winid) - 1, '')->get('path', '')
  var root = (path->isdirectory() ?
    (path->fnamemodify(':p') .. '../..')->fnamemodify(':p') :
    path->fnamemodify(':p:h:h'))


  ctx.source = PopupEditee_files_make_list(root)
  ctx.active = ctx.source

  #
  call PopupEditee_set_list(winid, printf(' Files / %d : %s ', ctx.active->len(), root), ctx.active)
enddef

def PopupEditee_buffers_action_open(command_format: string, winid: number, ctx: any)
  var bnr = ctx.active->get(line('.', winid) - 1, {})->get('bufnr', 0)

  call popup_close(winid)

  execute printf(command_format, bnr)
enddef

def PopupEditee_windows_action_enter(winid: number, ctx: any)
  var item = ctx.active->get(line('.', winid) - 1, '')

  call popup_close(winid)
  call item->get('winid', 0)->win_gotoid()
enddef

def PopupEditee_lines_action_enter(winid: number, ctx: any)
  var item = ctx.active->get(line('.', winid) - 1, '')

  call popup_close(winid)
  call setpos('.', [item->get('bufnr', ''), item->get('linenr', ''), 1, 0])
enddef

def PopupEditee_action_fuzzy(winid: number, ctx: any)
  var chars = input('fuzzy: ')

  if empty(chars) | return | endif

  ctx.active = ctx.active->matchfuzzy(chars, { key: 'text' })

  call PopupEditee_set_list(winid, '', ctx.active)
enddef

def PopupEditee_action_include(winid: number, ctx: any)
  var text = input('include: ')

  if empty(text) | return | endif

  ctx.active = ctx.active->copy()->filter((i, v) => v->get('text', '') =~ text)

  call PopupEditee_set_list(winid, '', ctx.active)
enddef

def PopupEditee_action_reset(winid: number, ctx: any)
  ctx.active = ctx.source

  call PopupEditee_set_list(winid, '', ctx.active)
enddef

def PopupEditee_action(winid: number, key: string, ctx: any): bool
  var handlers = get(ctx, 'handlers', {})

  if     key ==# 'f' | call PopupEditee_action_fuzzy(winid, ctx)
  elseif key ==# 'i' | call PopupEditee_action_include(winid, ctx)
  elseif key ==# 'u' | call PopupEditee_action_reset(winid, ctx)
  elseif handlers->has_key(key)
    var Handler = get(handlers, key, ((w, c) => 1))

    call Handler(winid, ctx)
  else
    return popup_filter_menu(winid, key)
  endif

  return true
enddef

def PopupEditee_open(caption: string, items: list<any>, handler_s: dict<func>)
  var ctx = { source: items, active: items, handlers: handler_s }
  var winid = popup_menu(items, {
    title: caption,
    filter: (winid, key) => PopupEditee_action(winid, key, ctx),
    borderchars: []
  })

  call Popup_win_resize(winid, items)
enddef

def PopupEditee_do_files(root_dir: string)
  call PopupEditee_update_variables()

  var root = root_dir->empty() ? getcwd() : root_dir
  var items = PopupEditee_files_make_list(root)
  var handlers = { '^': function(PopupEditee_files_action_up) }
  ->extend(popup_editee_file_open_handlers)

  call PopupEditee_open(
    printf(' Files / %d : %s ', items->len(), root), items, handlers)
enddef

def PopupEditee_do_mru()
  call PopupEditee_update_variables()

  var path = get(g:, 'vimrc_plugin_popup_mru_pinned', '~/.vim_mru_pinned.txt')
    ->expand()
    ->fnamemodify(':p')
  var items = (filereadable(path) ? readfile(path) : [])
    ->extend(v:oldfiles->copy())
    ->map((i, v) => ({
        text: PopupEditee_path_to_candidate((v->isdirectory() ? icons.dir : icons.file), v),
        path: v
    }))

  call PopupEditee_open(' Mru ', items, popup_editee_file_open_handlers)
enddef

def PopupEditee_do_buffers()
  call PopupEditee_update_variables()

  var items = range(1, bufnr('$'))
    ->filter((i, v) => buflisted(v) && bufexists(v))
    ->map((i, v) => {
      var bn_ = bufname(v)

      if getbufvar(v, '&buftype', '')->empty()
        bn_ = printf('%s (%s)', bn_->fnamemodify(':t'), bn_->fnamemodify(':p:h'))
      endif

      return { text: printf('%4d %s %s', v, icons.buf, bn_), bufnr: v }
    } )
  var handlers = {
    "\<CR>": function(PopupEditee_buffers_action_open, ['buffer %d']),
    "t": function(PopupEditee_buffers_action_open, ['split | buffer %d | wincmd T']),
    "d": function(PopupEditee_buffers_action_open, ['bw %d'])
  }

  call PopupEditee_open(' Buffers ', items, handlers)
enddef

def PopupEditee_do_windows()
  call PopupEditee_update_variables()

  var items = []      # [ { text:, bufnr:, winid: }, ... ]
  var winid2buf = {}  # { winid: bufname }

  for tab_no in range(1, tabpagenr('$'))
    for bufnr in tab_no->tabpagebuflist()
      for winid in bufnr->win_findbuf()
        var bname = bufnr->bufname()

        if filereadable(bname)
          winid2buf[winid] = printf('%s (%s)', bname->fnamemodify(':t'), bname->fnamemodify(':p:h'))
        else
          winid2buf[winid] = bname
        endif
      endfor
    endfor

    for winnr in range(1, tab_no->tabpagewinnr('$'))
      var winid = win_getid(winnr, tab_no)

      if winid2buf->has_key(winid)
        call items->add({
          'text': printf("%3d %s %s", tab_no, icons.win, winid2buf[winid]),
          'tabnr': tab_no,
          'winid': winid
        })
      endif
    endfor
  endfor

  call items->sort((e1, e2) => 
    (e1['tabnr'] != e2['tabnr']) ? (e1['tabnr'] - e2['tabnr']) : (e1['winid'] - e2['winid']))

  #
  var handlers = { "\<CR>": function(PopupEditee_windows_action_enter) }

  call PopupEditee_open(' Windows ', items, handlers)
enddef

def PopupEditee_do_lines()
  var bnr = bufnr('%')

  if bnr > 0
    var lines = getbufline(bnr, 1, '$')
      ->map((i, v) => ({ text: v, bufnr: bnr, linenr: (i + 1) }) )
      ->filter((i, v) => v.text !~# '^\s*$')
    var ctx = {
      source: lines,
      active: lines,
      handlers: { "\<CR>": function(PopupEditee_lines_action_enter) }
    }
    var winid = popup_menu(ctx.active, {
      title: printf(' Lines / %d ', lines->len()),
      filter: (winid, key) => PopupEditee_action(winid, key, ctx)
    })

    call Popup_win_resize(winid, lines)
  endif
enddef

def PopupEditee_get_glob_cache(bang: string, root_dir: string): list<any>
  var root = (root_dir->empty() ? getcwd() : root_dir)
  var bnr = bufadd(popup_editee_glob_last_cache_buffer)

  call bnr->bufload()

  if bang->empty()
    call setbufvar(bnr, '&buftype', 'nofile')
    call setbufvar(bnr, '&bufhidden', 'hide')
    call setbufvar(bnr, '&swapfile', 0)
    call setbufvar(bnr, 'path', root)

    #
    call deletebufline(bnr, 1, '$')
    call setbufline(bnr, 1, '      0')

    execute 'silent botright :1split'
    execute 'silent buffer ' .. bnr
    redraw

    #
    var ln = 1
    var dirs = [root]
    var max_candidates = get(g:, 'popup_editee_glob_max_candidates', 10000)
    var start_time = reltime()

    while !dirs->empty()
      var dir = dirs->remove(0)

      for entry in readdirex(dir)
        var fullname = dir .. path_slash .. entry.name

        if (entry.type =~# pattern_type_dir) && (entry.name !~# pattern_ignore_dir)
          call dirs->add(fullname)

        elseif (entry.type =~# pattern_type_file) && (entry.name !~# pattern_ignore_file)
          call appendbufline(bnr, ln, fullname)

          ln += 1
        endif

        if ln > max_candidates | dirs = [] | endif
      endfor

      if ln > 1000
        call setbufline(bnr, 1, printf('>> %d : %s', ln, dir))
        redraw
      endif
    endwhile

    call deletebufline(bnr, 1)

    execute 'silent close'

    echomsg printf('glob / %d : %f : %s', ln, reltimefloat(reltime(start_time)), root)
  endif

  return [bnr, root]
enddef

def PopupEditee_do_glob(bang: string, root_dir: string)
  call PopupEditee_update_variables()

  var [bnr, root] = PopupEditee_get_glob_cache(bang, root_dir)
  var items = getbufline(bnr, 1, '$')
    ->map((i, v) => ({
      text: PopupEditee_path_to_candidate(icons.file, v),
      path: v
    }))

  call PopupEditee_open(printf(' Glob / %d : %s', items->len(), root),
    items, popup_editee_file_open_handlers)
enddef

def PopupEditee_open_glob_cache(bang: string, root_dir: string)
  var [bnr, root] = PopupEditee_get_glob_cache(bang, root_dir)

  execute 'silent botright :16split'
  execute 'silent buffer ' .. bnr
enddef

command! -nargs=? -complete=dir       PopupFiles      call PopupEditee_do_files(<q-args>)
command! -nargs=0                     PopupMru        call PopupEditee_do_mru()
command! -nargs=0                     PopupBuffers    call PopupEditee_do_buffers()
command! -nargs=0                     PopupWindows    call PopupEditee_do_windows()
command! -nargs=0                     PopupLines      call PopupEditee_do_lines()
command! -nargs=? -complete=dir -bang PopupGlob       call PopupEditee_do_glob('<bang>', <q-args>)
command! -nargs=? -complete=dir -bang PopupGlobCache  call PopupEditee_open_glob_cache('<bang>', <q-args>)

