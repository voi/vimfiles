vim9script

import 'fuzzy_choice_path.vim'
type FuzzyChoicePath = fuzzy_choice_path.FuzzyChoicePath


# ###############################
# fuzzy choice mru # {{{1
command! -nargs=0 FuzzyChoiceMru {
  var bookmark = get(g:, 'fuzzy_choice_vim_mru_bookmark', '~/.vim-bookmark.txt')
    ->expand()
    ->fnamemodify(':p')
  var items = (filereadable(bookmark) ? readfile(bookmark) : [])
    ->extend(v:oldfiles->copy())

  if items->empty()
    echomsg 'FuzzyChoiceMru : no candidates.'
  else
    call FuzzyChoicePath.Do('Mru', items)
  endif
}
# }}}

