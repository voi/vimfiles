vim9script

import 'fuzzy_choice.vim'
type FuzzyChoice = fuzzy_choice.FuzzyChoice


# ###############################
# fuzzy choice lines # {{{1
def FuzzyChoiceLines_Do()
  var bnr = bufnr('%')

  if bnr > 0
    var items = getbufline(bnr, 1, '$')
      ->map((i, v) => ({ text: v, bufnr: bnr, linenr: (i + 1) }) )
      ->filter((i, v) => v.text !~# '^\s*$')

    var actions = {
      "\<CR>": ((winid, ctx, item) => {
        call popup_close(winid)
        call setpos('.', [item->get('bufnr', ''), item->get('linenr', ''), 1, 0])

        return 0
      })
    }

    call FuzzyChoice.Do('Lines', items, actions)
  endif
enddef

command! -nargs=0 FuzzyChoiceLines call FuzzyChoiceLines_Do()
# }}}

