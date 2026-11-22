vim9script

#
import 'fuzzy_choice.vim'
import 'fuzzy_choice_path.vim'

#
type FuzzyChoice = fuzzy_choice.FuzzyChoice
type FuzzyChoicePath = fuzzy_choice_path.FuzzyChoicePath


# ###############################
#
class FuzzyChoiceWindow
  #
  static def NewItems(): list<any>
    var items = []
    var icon = get(g:, 'fuzzy_choice_icon_buff',  '📜')

    for tnr in range(1, tabpagenr('$'))
      for bnr in tnr->tabpagebuflist()->sort()->uniq()
        if !bnr->getbufvar('&buftype', '')->empty()
          continue
        endif

        var bname = bnr->bufname()
        var caption = printf('%s (%s)', bname->fnamemodify(':t'), bname->fnamemodify(':p:h'))
        var winid = bnr->win_findbuf()->filter((i, v) => v->win_id2tabwin()[0] == tnr)->get(0, 0)

        call items->add({ 'text': printf("[%2d]%s %s", tnr, icon, caption), 'winid': winid })
      endfor
    endfor

    return items
  enddef


  #
  static def _Action(winid: number, ctx: any, item: any): number
    call popup_close(winid)
    call item->get('winid', 0)->win_gotoid()

    return 0
  enddef


  #
  static var actions = {
    "\<CR>": function(FuzzyChoiceWindow._Action)
  }

endclass


#
command! -nargs=0 FuzzyChoiceWindows {
  var items = FuzzyChoiceWindow.NewItems()

  call FuzzyChoice.Do('Windows', items, FuzzyChoiceWindow.actions)
}

