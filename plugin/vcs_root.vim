vim9script

def VcsRoot_find_root(dirs: list<string>, files: list<string>): string
  var source = expand('%')->fnamemodify(':p:h') .. ';'

  for dir in dirs
    var target = dir->finddir(source)

    if !target->empty()
      return target->fnamemodify(':p')->substitute(dir .. '[\\/]$', '', '')
    endif
  endfor

  for file in files
    var target = file->findfile(source)

    if !target->empty()
      return target->fnamemodify(':p:h')
    endif
  endfor

  return ''
enddef

def VcsRoot_lcd(bang: string, arguments: list<string>)
  var dirs = arguments
  var files = arguments

  if arguments->empty()
    dirs = get(g:, 'vcs_root_target_dirs', ['.git', '.svn'])
    files = get(g:, 'vcs_root_target_files', ['_FOSSIL_'])
  endif

  var root = VcsRoot_find_root(dirs, files)

  if root->empty()
    echomsg "('_`;) >/" .. getcwd()->fnamemodify(':t') .. '/'
  else
    execute (bang->empty() ? 'tcd ' : 'lcd') .. root
  endif
enddef

command! -bang -nargs=? Root call VcsRoot_lcd('<bang>', [<f-args>])

