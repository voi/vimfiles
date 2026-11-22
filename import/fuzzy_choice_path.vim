vim9script

import 'fuzzy_choice.vim'
type FuzzyChoice = fuzzy_choice.FuzzyChoice


# ##############################################################
# fuzzy choice path # {{{1
export class FuzzyChoicePath
  #
  static def ActionPath(cmd: string, winid: number, ctx: any, item: any): number
    call popup_close(winid)

    execute cmd item->get('path', '%')

    return 0
  enddef


  #
  static var _actions = {
    "\<CR>":  function(FuzzyChoicePath.ActionPath, ['edit']),
    "\<C-v>": function(FuzzyChoicePath.ActionPath, ['vsplit']),
    "\<C-s>": function(FuzzyChoicePath.ActionPath, ['split']),
    "\<C-t>": function(FuzzyChoicePath.ActionPath, ['tabedit'])
  }


  #
  static def Do(caption: string, files: list<any>, user_ctx: dict<any> = {})
    var icon_file = get(g:, 'fuzzy_choice_icon_file', '📝')
    var items = files->copy()->map((i, v) => {
      if v->type() == v:t_string
        return {
              \ text: printf('%s %s (%s)', icon_file, v->fnamemodify(':t'), v->fnamemodify(':h:~')), 
              \ path: v
              \ }
      else
        return v
      endif
    })

    call FuzzyChoice.Do(caption, items, _actions, user_ctx)
  enddef
endclass
# }}}

