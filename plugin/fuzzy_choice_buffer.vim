vim9script

import 'fuzzy_choice.vim'
type FuzzyChoice = fuzzy_choice.FuzzyChoice


# ###############################
# fuzzy choice buffer # {{{1
class FuzzyChoiceBuffer
  #
  static def GetItems(): list<any>
    var icon = get(g:, 'fuzzy_choice_icon_buff', '📜')

    return range(1, bufnr('$'))
      ->filter((i, v) => buflisted(v) && bufexists(v) && !bufname(v)->empty() && getbufvar(v, '&buftype', '')->empty())
      ->map((i, v) => {
        var bname = v->bufname()

        if v->getbufvar('&buftype', '')->empty()
          bname = printf('%s (%s)', bname->fnamemodify(':t'), bname->fnamemodify(':p:h:~'))
        endif

        return { text: printf('%4d %s %s', v, icon, bname), bufnr: v }
      })
  enddef


  #
  static def _Action(cmd_format: string, winid: number, ctx: any, item: any): number
    #
    call popup_close(winid)

    execute printf(cmd_format, item->get('bufnr', 0))

    return 0
  enddef


  #
  static def _ActionWipeout(winid: number, ctx: any, item: any): number
    #
    execute printf('bw %d', item->get('bufnr', 0))

    ctx._source = FuzzyChoiceBuffer.GetItems()

    return 1
  enddef


  #
  static var actions = {
    "\<CR>":  function(FuzzyChoiceBuffer._Action, ['buffer %d']),
    "\<C-t>": function(FuzzyChoiceBuffer._Action, ['split | buffer %d | wincmd T']),
    "\<C-s>": function(FuzzyChoiceBuffer._Action, ['split | buffer %d']),
    "\<C-v>": function(FuzzyChoiceBuffer._Action, ['vsplit | buffer %d']),
    "\<C-d>": function(FuzzyChoiceBuffer._ActionWipeout)
  }

endclass


#
command! -nargs=0 FuzzyChoiceBuffers {
  var items = FuzzyChoiceBuffer.GetItems()

  call FuzzyChoice.Do('Buffers', items, FuzzyChoiceBuffer.actions)
}
# }}}

