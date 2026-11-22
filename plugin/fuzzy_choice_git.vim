vim9script


import 'fuzzy_choice_path.vim'
type FuzzyChoicePath = fuzzy_choice_path.FuzzyChoicePath


# ###############################
#
def FuzzyChoiceGit_status_do(command_format: string, winid: number, ctx: any, item: any)
  call popup_close(winid)

  echomsg printf(command_format, item->get('item', '-h'))->system()
enddef


#
var local_fuzzy_git_handlers = {
  "\<C-a>": function(FuzzyChoiceGit_status_do, ['git add %s']),
  "\<C-c>": function(FuzzyChoiceGit_status_do, ['git checkout -- %s']),
  "\<C-r>": function(FuzzyChoiceGit_status_do, ['git reset %s'])
}


#
def FuzzyChoiceGit_status(option: string)
  var items = printf('git status -s %s', option)->system()
    ->iconv(&termencoding, &encoding)
    ->split('\n')
    ->map((i, v) => ({ text: v, path: v->slice(3)->fnamemodify(':p'), item: v->slice(3) }))

  FuzzyChoicePath.Do('git status', items, local_fuzzy_git_handlers)
enddef

command! -nargs=* FuzzyGitStatus call FuzzyChoiceGit_status([<q-args>]->join(' '))


# ###############################
def FuzzyChoiceGit_ls(option: string)
  var items = printf('git ls-files %s', option)->system()
    ->iconv(&termencoding, &encoding)
    ->split('\n')
    ->map((i, v) => v->fnamemodify(':p'))
    ->filter((i, v) => !v->isdirectory())

  call FuzzyChoicePath.Do('git ls', items)
enddef

command! -nargs=* FuzzyGitLs call FuzzyChoiceGit_ls([<q-args>]->join(' '))


