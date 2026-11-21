vim9script

import 'fuzzy_choice_path.vim' as FuzzyChoicePath


# ###############################
#
command! -nargs=0 FuzzyChoiceMru {
  var bookmark = get(g:, 'fuzzy_choice_vim_mru_bookmark', '~/.vim_fuzzy_choice_mru_bookmark.txt')
    ->expand()
    ->fnamemodify(':p')
  var items = (filereadable(bookmark) ? readfile(bookmark) : [])
    ->extend(v:oldfiles->copy())

  if items->empty()
    echomsg 'FuzzyChoiceMru : no candidates.'
  else
    call FuzzyChoicePath.DoAsFiles('Mru', items)
  endif
}


