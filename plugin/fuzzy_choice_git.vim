vim9script

# ###############################
import 'fuzzy_choice.vim'


# ###############################
#
def Local_fuzzy_git_status_do(command_format: string, winid: number, ctx: any, item: any)
  call popup_close(winid)
  call system(command_format, item->get('item', '-h'))
enddef


#
var local_fuzzy_git_handlers = {
  "\<C-a>": function(Local_fuzzy_git_status_do, ['git add %s']),
  "\<C-c>": function(Local_fuzzy_git_status_do, ['git checkout -- %s']),
  "\<C-r>": function(Local_fuzzy_git_status_do, ['git reset %s'])
}


#
def Local_fuzzy_git_status(option: string)
  var items = printf('git status -s %s', option)->system()
    ->iconv(&termencoding, &encoding)
    ->split('\n')
    ->map((i, v) => ({ text: v, path: v->slice(4)->fnamemodify(':p'), item: v->slice(4) }))

  fuzzy_choice.DoAsFilesEx('git status', items, local_fuzzy_git_handlers)
enddef

command! -nargs=* FuzzyGitStatus call Local_fuzzy_git_status([<q-args>]->join(' '))


# ###############################
def Local_fuzzy_git_ls(option: string)
  var items = printf('git ls-files %s', option)->system()
    ->iconv(&termencoding, &encoding)
    ->split('\n')
    ->map((i, v) => v->fnamemodify(':p'))
    ->filter((i, v) => !v->isdirectory())

  call fuzzy_choice.DoAsFiles('git ls', items)
enddef

command! -nargs=* FuzzyGitLs call Local_fuzzy_git_ls([<q-args>]->join(' '))


