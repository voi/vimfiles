vim9script

# ###############################
import 'fuzzy_choice.vim'


# ###############################
#
def Local_fuzzy_svn_status_do(command_format: string, winid: number, ctx: any, item: any)
  call popup_close(winid)
  call system(command_format, item->get('path', '-h'))
enddef


#
var local_fuzzy_svn_handlers = {
  "\<C-a>": function(Local_fuzzy_svn_status_do, ['svn add %s']),
  "\<C-r>": function(Local_fuzzy_svn_status_do, ['svn revert %s'])
}


#
def Local_fuzzy_svn_status(option: string)
  var dir = getcwd()
  var items = printf('svn status %s %s', option, dir)->system()
    ->iconv(&termencoding, &encoding)
    ->split('\n')
    ->map((i, v) => ({ text: v->substitute('\V' .. dir->escape('\'), '', ''), path: v->slice(8) }))

  fuzzy_choice.DoAsFilesEx('svn status', items, local_fuzzy_svn_handlers)
enddef

command! -nargs=* FuzzySvnStatus call Local_fuzzy_svn_status([<q-args>]->join(' '))


# ###############################
def Local_fuzzy_svn_ls(option: string)
  var items = printf('svn ls %s %s', option, getcwd())->system()
    ->iconv(&termencoding, &encoding)
    ->split('\n')
    ->filter((i, v) => !v->isdirectory())

  call fuzzy_choice.DoAsFiles('svn ls', items)
enddef

command! -nargs=* FuzzySvnLs call Local_fuzzy_svn_ls([<q-args>]->join(' '))

