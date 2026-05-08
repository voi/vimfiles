vim9script

var icons = { file: '📝', dir: '📁', empty: '🈳' }

var pattern_type_dir = '\v^(dir|linkd)$'
var pattern_type_file = '\v^(file|link)$'
var pattern_ignore_dir = '\v^\.%(git|jj|svn|hg|bzr)$'
var pattern_ignore_file = '\v^_FOSSIL_$'


# ###############################
#
def Popup_win_resize(winid: number, items: list<any>)
  var height = ([items->len(), [&lines, winheight(0)]->max() * 8 / 10]->min())
  var width = ([&columns, winwidth(0)]->max() * 9 / 10)

  call popup_move(winid, { minheight: height, maxheight: height, maxwidth: width })
enddef


#
def Popup_win_update(winid: number, ctx: any)
  call popup_setoptions(winid, {
    title: printf(' %s (%d) %s%s %s%s ', ctx._name, ctx._active->len(),
      (ctx._pattern->empty() ? '' : '< '), ctx._pattern,
      (ctx._filter->empty() ? '' : '< '), ctx._filter)
  })
  call popup_settext(winid, ctx._active)
  call Popup_win_resize(winid, ctx._active)
enddef


# ###############################
#
def FuzzyChoice_action_fuzzy(winid: number, ctx: any)
  var chars = input('fuzzy: ')

  if empty(chars) | return | endif

  ctx._filter = chars
  ctx._active = ctx._active->matchfuzzy(chars, { key: 'text' })

  call Popup_win_update(winid, ctx)
enddef


#
def FuzzyChoice_action_match(winid: number, ctx: any)
  var text = input('include: ')

  if empty(text) | return | endif

  ctx._pattern = text
  ctx._active = ctx._active->filter(((i, v) => v->get('text', '') =~? text))

  call Popup_win_update(winid, ctx)
enddef


#
def FuzzyChoice_action_reset(winid: number, ctx: any)
  ctx._filter = ''
  ctx._pattern = ''
  ctx._active = ctx._source->copy()

  call Popup_win_update(winid, ctx)
enddef


#
def FuzzyChoice_action_fuzzy_incremental(winid: number, key: string, ctx: any)
  ctx._filter ..= key
  ctx._active = ctx._active->matchfuzzy(ctx._filter, { key: 'text' })

  call Popup_win_update(winid, ctx)
enddef


#
def FuzzyChoice_action_fuzzy_back(winid: number, ctx: any)
  ctx._filter = ctx._filter->slice(0, -1)

  if ctx._filter->len() > 0
    ctx._active = ctx._source->matchfuzzy(ctx._filter, { key: 'text' })
  elseif ctx._pattern->len() > 0
    ctx._active = ctx._source->copy()->filter(((i, v) => v->get('text', '') =~? ctx._pattern))
  else
    ctx._active = ctx._source->copy()
  endif

  call Popup_win_update(winid, ctx)
enddef


#
def FuzzyChoice_action(winid: number, key: string, ctx: any): bool
  var handlers = get(ctx, '_handlers', {})
  var item = ctx._active->get(line('.', winid) - 1, '')

  if     key ==# "\<C-f>" | call FuzzyChoice_action_fuzzy(winid, ctx)
  elseif key ==# "\<C-i>" | call FuzzyChoice_action_match(winid, ctx)
  elseif key ==# "\<C-u>" | call FuzzyChoice_action_reset(winid, ctx)
  #
  elseif key ==# "\<C-h>" || key ==# "\<BS>"
    call FuzzyChoice_action_fuzzy_back(winid, ctx)
  #
  elseif key =~# '^[0-9A-Za-z_.@\-]$'
    call FuzzyChoice_action_fuzzy_incremental(winid, key, ctx)
  #
  elseif handlers->has_key(key)
    var Handler = get(handlers,
      (key ==# "\<CR>" && handlers->has_key('ENTER') ? 'ENTER' : key), ((w, c, i) => 1))

    call Handler(winid, ctx, item)

  else
    return popup_filter_menu(winid, key)
  endif

  return true
enddef


# ###############################
#
def FuzzyChoice_filer_new_source(root: string): list<any>
  return readdirex(root)
    ->filter((i, v) => {
      return (
        ((v.type =~# pattern_type_dir)  && (v.name !~# pattern_ignore_dir)) ||
        ((v.type =~# pattern_type_file) && (v.name !~# pattern_ignore_file)))
    })
    ->map((i, v) => ({
      text: printf('%s %s (%s)',
        ((v.type =~# pattern_type_dir) ? icons.dir : icons.file), v.name, root->fnamemodify(':~')),
      path: root->expand()->fnamemodify(':p') .. v.name
    }))
enddef


#
def FuzzyChoice_action_filer_up(winid: number, ctx: any, item: any)
  var path = item->get('path', '')
  var root = (path->isdirectory() ?
    (path->fnamemodify(':p') .. '../..')->fnamemodify(':p') :
    path->fnamemodify(':p:h:h'))


  ctx._source = FuzzyChoice_filer_new_source(root)
  ctx._active = ctx._source->copy()
  ctx._filter = ''
  ctx._pattern = ''

  call Popup_win_update(winid, ctx)
enddef


#
def FuzzyChoice_action_filer_enter( Handler: func, winid: number, ctx: any, item: any)
  var path = item->get('path', '')

  if path->isdirectory()
    var children = FuzzyChoice_filer_new_source(path->fnamemodify(':p'))

    if empty(children)
      echomsg icons.empty .. ' No files in ' ..  path->fnamemodify(':t') .. '/'

    else
      ctx._source = children
      ctx._active = children->copy()
      ctx._filter = ''
      ctx._pattern = ''

      call Popup_win_update(winid, ctx)
    endif

  elseif !path->empty()
    call Handler(winid, ctx, item)
  endif
enddef


# ###############################
#
def FuzzyChoice_action_open_path(command_format: string, winid: number, ctx: any, item: any)
  var path = item->get('path', '')

  call popup_close(winid)

  if !path->empty() | execute printf(command_format, path) | endif
enddef


# ###############################
#
var fuzzy_choice_handlers_path = {
  "\<CR>": function(FuzzyChoice_action_open_path, ['edit %s']),
  "\<C-v>": function(FuzzyChoice_action_open_path, ['vsplit %s']),
  "\<C-s>": function(FuzzyChoice_action_open_path, ['split %s']),
  "\<C-t>": function(FuzzyChoice_action_open_path, ['tabedit %s'])
}


#
def FuzzyChoice_open(caption: string, items: list<any>, user_handlers: dict<func>)
  var ctx = {
    _source: items, _active: items->copy(), _handlers: user_handlers,
    _name: caption, _filter: '', _pattern: ''
  }
  var winid = popup_menu(items, {
    title: printf(" %s (%d) ", caption, items->len()),
    filter: (winid, key) => FuzzyChoice_action(winid, key, ctx),
    borderchars: get(g:, 'fuzzy_choice_borderchars', [])
  })
  call Popup_win_resize(winid, items)
enddef


# ###############################
def FuzzyChoice_update_variables()
  icons.file  = get(g:, 'fuzzy_choice_icon_file',  icons.file)
  icons.dir   = get(g:, 'fuzzy_choice_icon_dir',   icons.dir)
  icons.empty = get(g:, 'fuzzy_choice_icon_empty', icons.empty)

  pattern_ignore_dir = get(g:, 'fuzzy_choice_glob_regex_ignore_dir', pattern_ignore_dir)
  pattern_ignore_file = get(g:, 'fuzzy_choice_glob_regex_ignore_file', pattern_ignore_file)
enddef


#
var fuzzy_choice_handlers_filer = {
  '^': function(FuzzyChoice_action_filer_up),
  "\<CR>": function(FuzzyChoice_action_filer_enter, [fuzzy_choice_handlers_path["\<CR>"]]),
  "\<C-v>": function(FuzzyChoice_action_filer_enter, [fuzzy_choice_handlers_path["\<C-v>"]]),
  "\<C-s>": function(FuzzyChoice_action_filer_enter, [fuzzy_choice_handlers_path["\<C-s>"]]),
  "\<C-t>": function(FuzzyChoice_action_filer_enter, [fuzzy_choice_handlers_path["\<C-t>"]])
}


# ###############################
#
var fuzzy_choice_last_cache_buffer = tempname()


export def GetCache(root_dir: string, need_cache: bool, Cacher: func): list<any>
  var root = (root_dir->empty() ? getcwd() : root_dir)->expand()->fnamemodify(':p')
  var bnr = bufadd(fuzzy_choice_last_cache_buffer)

  call bnr->bufload()

  if need_cache
    call setbufvar(bnr, '&buftype', 'nofile')
    call setbufvar(bnr, '&bufhidden', 'hide')
    call setbufvar(bnr, '&swapfile', 0)
    call setbufvar(bnr, 'path', root)

    call Cacher(bnr, root)
  endif

  return [bnr, root]
enddef


# ###############################
#
export def Do(caption: string, items: list<any>, user_handlers: dict<func>)
  call FuzzyChoice_open(caption, items, user_handlers)
enddef


#
export def DoAsFilesEx(caption: string, items: list<any>, user_handlers: dict<func> = {})
  var handlers = {}
    ->extend(fuzzy_choice_handlers_path)
    ->extend(user_handlers)

  call FuzzyChoice_open(caption, items, handlers)
enddef


#
export def DoAsFiles(caption: string, pathes: list<string>, user_handlers: dict<func> = {})
  call FuzzyChoice_update_variables()

  var items = pathes->copy()->map((i, v) => ({
    text: printf('%s %s (%s)', icons.file, v->fnamemodify(':t'), v->fnamemodify(':h:~')),
    path: v
  }))

  call DoAsFilesEx(caption, items, user_handlers)
enddef


#
export def Filer(caption: string, root_dir: string, user_handlers: dict<func> = {})
  call FuzzyChoice_update_variables()

  var items = FuzzyChoice_filer_new_source((root_dir->empty() ? getcwd() : root_dir))
  var handlers = {}
    ->extend(fuzzy_choice_handlers_filer)
    ->extend(user_handlers)

  call FuzzyChoice_open(caption, items, handlers)
enddef

