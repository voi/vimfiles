vim9script

def GitUtil_launchGui(path: string)
  #
  if finddir('.git', getcwd() .. ';')->empty()
    echomsg 'outside working copy.'
    return
  endif

  #
  call job_start('git gui', { 'in_io': 'null', 'out_io': 'null', 'err_io': 'null' })
enddef


def GitUtil_grep(query: list<string>)
  var current_grep = getbufvar('%', '&grepreg') # 前回の設定値の保存

  setlocal grepprg=git\ grep\ -I\ --line-number
  execute 'silent grep! ' . query->join(' ')

  setbufvar('%', '&grepprg', current_grep)
  redraw!
enddef


def GitGui_addCommand()
  if executable('git')
    command! -nargs=? GitGrep call GitUtil_grep([<f-args>])

    if has('win32')
      command! -nargs=? -complete=dir GitGui call GitUtil_launchGui(<q-args>)
    endif
  endif
enddef


augroup plugin_git_util_autocmd_
  autocmd!
  autocmd VimEnter * call GitGui_addCommand()
augroup END

