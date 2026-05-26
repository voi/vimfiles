vim9script

def GitGui_run(path: string)
  var cwd = getcwd()
  var root = path

  if root->empty()
    root = finddir('.git', getcwd() .. ';')

    if !root->empty()
      root = root->fnamemodify(':h')->fnamemodify(':p')
    endif
  endif

  if root->empty() | echomsg 'outside working copy.' | return | endif

  #
  execute 'silent lcd' root
  call job_start('git gui', { 'in_io': 'null', 'out_io': 'null', 'err_io': 'null' })
  execute 'silent lcd' cwd
enddef

def GitGui_addCommand()
  if has('win32')
    command! -nargs=? -complete=dir GitGui call GitGui_run(<q-args>)
  endif
enddef

augroup _plugin_win32_git_gui_
  autocmd!
  autocmd VimEnter * call GitGui_addCommand()
augroup END

