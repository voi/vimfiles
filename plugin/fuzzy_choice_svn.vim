vim9script


import 'fuzzy_choice_path.vim'
type FuzzyChoicePath = fuzzy_choice_path.FuzzyChoicePath


# ###############################
#
def FuzzyChoiceSvn_status_do(command_format: string, winid: number, ctx: any, item: any)
  call popup_close(winid)

  echomsg printf(command_format, item->get('path', '-h'))->system()
enddef


#
var local_fuzzy_svn_handlers = {
  "\<C-a>": function(FuzzyChoiceSvn_status_do, ['svn add %s']),
  "\<C-r>": function(FuzzyChoiceSvn_status_do, ['svn revert %s'])
}


#
def FuzzyChoiceSvn_status(option: string)
  var dir = getcwd()->fnamemodify(':p')
  var items = printf('svn status %s %s', option, dir)->system()
    ->iconv(&termencoding, &encoding)
    ->split('\n')
    ->map((i, v) => ({ text: v->substitute('\V' .. dir->escape('\'), '', ''), path: v->slice(8) }))

  FuzzyChoicePath.Do('svn status', items, local_fuzzy_svn_handlers)
enddef

command! -nargs=* FuzzySvnStatus call FuzzyChoiceSvn_status([<q-args>]->join(' '))


# ###############################
def FuzzyChoiceSvn_ls(option: string)
  var items = printf('svn ls %s %s', option, getcwd())->system()
    ->iconv(&termencoding, &encoding)
    ->split('\n')
    ->filter((i, v) => !v->isdirectory())

  call FuzzyChoicePath.Do('svn ls', items)
enddef

command! -nargs=* FuzzySvnLs call FuzzyChoiceSvn_ls([<q-args>]->join(' '))

