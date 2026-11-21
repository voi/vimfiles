vim9script

import 'fuzzy_choice.vim' as FuzzyChoice


# ###############################
#
def FuzzyChoice_action_open_path(command_format: string, winid: number, ctx: any, item: any)
  var path = item->get('path', '')

  call popup_close(winid)

  if !path->empty() | execute printf(command_format, path) | endif
enddef


# ###############################
#
export var fuzzy_choice_handlers_path = {
  "\<CR>": function(FuzzyChoice_action_open_path, ['edit %s']),
  "\<C-v>": function(FuzzyChoice_action_open_path, ['vsplit %s']),
  "\<C-s>": function(FuzzyChoice_action_open_path, ['split %s']),
  "\<C-t>": function(FuzzyChoice_action_open_path, ['tabedit %s'])
}


#
export def DoAsFilesEx(caption: string, items: list<any>, user_handlers: dict<func> = {})
  var handlers = {}
    ->extend(fuzzy_choice_handlers_path)
    ->extend(user_handlers)

  call FuzzyChoice.Do(caption, items, handlers)
enddef


#
export def DoAsFiles(caption: string, pathes: list<string>, user_handlers: dict<func> = {})
  var icon_file  = get(g:, 'fuzzy_choice_icon_file',  '📝')

  var items = pathes->copy()->map((i, v) => ({
    text: printf('%s %s (%s)', icon_file, v->fnamemodify(':t'), v->fnamemodify(':h:~')),
    path: v
  }))

  call DoAsFilesEx(caption, items, user_handlers)
enddef

