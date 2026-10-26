vim9script

def VcsRoot_find_root(dirs: list<string>, files: list<string>): string
  var root = ''

  for dir in dirs
    var target = dir->finddir('.;')

    if !target->empty()
      root = target->fnamemodify(':p')->substitute(dir .. '[\\/]$', '', '')
      break
    endif
  endfor

  for file in files
    var target = file->findfile('.;')

    if !target->empty()
      var root2 = target->fnamemodify(':p:h')

      if root2->len() > root->len() | root = root2 | endif

      break
    endif
  endfor

  return root
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
    execute (bang->empty() ? 'tcd ' : 'lcd ') .. root
  endif
enddef


command! -bang -nargs=? Root call VcsRoot_lcd('<bang>', [<f-args>])


augroup vcs_root_autocmd
  autocmd!
  autocmd  BufWinEnter * {
    if get(g:, 'vcs_root_auto_chdir', 0) && &buftype ==# ''
      call VcsRoot_lcd('', [])
    endif
  }
augroup END

