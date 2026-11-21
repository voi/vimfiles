vim9script

import 'fuzzy_choice.vim'


# ###############################
#
def FuzzyChoice_action_window_enter(winid: number, ctx: any, item: any)
  call popup_close(winid)
  call item->get('winid', 0)->win_gotoid()
enddef


#
def FuzzyChoice_command_windows()
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

  #
  var handlers = { "\<CR>": function(FuzzyChoice_action_window_enter) }

  call fuzzy_choice.Do('Windows', items, handlers)
enddef


#
command! -nargs=0 FuzzyChoiceWindows call FuzzyChoice_command_windows()

