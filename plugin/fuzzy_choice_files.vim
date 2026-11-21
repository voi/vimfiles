vim9script

import 'fuzzy_choice.vim' as FuzzyChoice
import 'fuzzy_choice_path.vim' as FuzzyChoicePath


# ###############################
#
var icons = { file: '📝', dir: '📁', empty: '🈳' }

var pattern_type_dir = '\v^(dir|linkd)$'
var pattern_type_file = '\v^(file|link)$'
var pattern_ignore_dir = '\v^\.%(git|jj|svn|hg|bzr)$'
var pattern_ignore_file = '\v^_FOSSIL_$'


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

  call FuzzyChoice.Popup_win_update(winid, ctx)
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

      call FuzzyChoice.Popup_win_update(winid, ctx)
    endif

  elseif !path->empty()
    call Handler(winid, ctx, item)
  endif
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
  "\<CR>": function(FuzzyChoice_action_filer_enter, [FuzzyChoicePath.fuzzy_choice_handlers_path["\<CR>"]]),
  "\<C-v>": function(FuzzyChoice_action_filer_enter, [FuzzyChoicePath.fuzzy_choice_handlers_path["\<C-v>"]]),
  "\<C-s>": function(FuzzyChoice_action_filer_enter, [FuzzyChoicePath.fuzzy_choice_handlers_path["\<C-s>"]]),
  "\<C-t>": function(FuzzyChoice_action_filer_enter, [FuzzyChoicePath.fuzzy_choice_handlers_path["\<C-t>"]])
}


# ###############################
#
command! -nargs=? -complete=dir FuzzyChoiceFiles {
  call FuzzyChoice_update_variables()

  var items = FuzzyChoice_filer_new_source(('<f-args>'->empty() ? getcwd() : root_dir))

  call FuzzyChoice.Do('Files', items, fuzzy_choice_handlers_filer)
}


