vim9script

import 'fuzzy_choice.vim'
import 'fuzzy_choice_path.vim'
type FuzzyChoice = fuzzy_choice.FuzzyChoice
type FuzzyChoicePath = fuzzy_choice_path.FuzzyChoicePath


# ##############################################################
#
export class FuzzyChoiceFiler
  #
  static def _NewSource(root: string): list<any>
    var icon_dir = get(g:, 'fuzzy_choice_icon_dir', '📁')
    var icon_file = get(g:, 'fuzzy_choice_icon_file', '📝')

    return readdirex(root, (e) => {
        return (
          ((e.type ==# 'dir'  || e.type ==# 'linkd') && (e.name !~# '\v^\.%(git|jj|svn|hg|bzr)$')) ||
          ((e.type ==# 'file' || e.type ==# 'link')  && (e.name !~# '\v^_FOSSIL_$')))
    })->map((i, v) => ({
      text: printf('%s %s (%s)',
        ((v.type =~# '\v^(dir|linkd)$') ? icon_dir : icon_file), v.name, root->fnamemodify(':~')),
      path: root->expand()->fnamemodify(':p') .. v.name
    }))
  enddef


  #
  static def _ActionDirUp(winid: number, ctx: any, item: any): number
    var path = item->get('path', '')
    var root = (path->isdirectory() ?
      (path->fnamemodify(':p') .. '../..')->fnamemodify(':p') : path->fnamemodify(':p:h:h'))

    ctx._source = FuzzyChoiceFiler._NewSource(root)

    call FuzzyChoice.ActionReset(winid, ctx)

    return -1
  enddef


  #
  static def _ActionEnter(cmd: string, winid: number, ctx: any, item: any): number
    var path = item->get('path', '')

    if path->isdirectory()
      var children = FuzzyChoiceFiler._NewSource(path->fnamemodify(':p'))

      if empty(children)
        echomsg '>< No files in ' ..  path->fnamemodify(':t') .. '/'

      else
        ctx._source = children

        return -1
      endif

    elseif !path->empty()
      return FuzzyChoicePath.ActionPath(cmd, winid, ctx, item)

    endif

    return 0
  enddef


  #
  static var _actions = {
    '^': function(FuzzyChoiceFiler._ActionDirUp),
    "\<CR>":  function(FuzzyChoiceFiler._ActionEnter, ['edit']),
    "\<C-v>": function(FuzzyChoiceFiler._ActionEnter, ['vsplit']),
    "\<C-s>": function(FuzzyChoiceFiler._ActionEnter, ['split']),
    "\<C-t>": function(FuzzyChoiceFiler._ActionEnter, ['tabedit'])
  }


  #
  static def Do(arguments: list<string>)
    var root_dir = arguments->get(0, getcwd())

    if root_dir->isdirectory()
      var items = FuzzyChoiceFiler._NewSource(root_dir)

      call FuzzyChoice.Do('Files', items, _actions)
    endif
  enddef

endclass

command! -nargs=? -complete=dir FuzzyChoiceFiles call FuzzyChoiceFiler.Do([<f-args>])

