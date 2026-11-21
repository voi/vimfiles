vim9script

import 'fuzzy_choice.vim'


# ###############################
#
def FuzzyChoice_action_lines_enter(winid: number, ctx: any, item: any)
  call popup_close(winid)
  call setpos('.', [item->get('bufnr', ''), item->get('linenr', ''), 1, 0])
enddef


#
command! -nargs=0 FuzzyChoiceLines {
  var bnr = bufnr('%')

  if bnr > 0
    var items = getbufline(bnr, 1, '$')
      ->map((i, v) => ({ text: v, bufnr: bnr, linenr: (i + 1) }) )
      ->filter((i, v) => v.text !~# '^\s*$')
    var handlers = { "\<CR>": function(FuzzyChoice_action_lines_enter) }

    call fuzzy_choice.Do('Lines', items, handlers)
  endif
}

