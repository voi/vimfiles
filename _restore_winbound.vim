vim9script

set viminfo+=!

g:RESTORE_WINBOUND_SAVE_VAR = ''

augroup Restore_Last_Window_Position_and_Size
  #
  autocmd! VimEnter * {
    if has('gui_running')
      var cmd = get(g:, 'RESTORE_WINBOUND_SAVE_VAR', '')
      if cmd =~# '^winpos -\?\d\+ -\?\d\+ | set lines=\d\+ columns=\d\+$'
        execute cmd
      endif
    endif
  }


  #
  autocmd! VimLeavePre * {
    if has('gui_running')
      var wp = getwinpos(500)
      g:RESTORE_WINBOUND_SAVE_VAR = printf('winpos %d %d | set lines=%d columns=%d', wp[0], wp[1], &lines, &columns)
    endif
  }
augroup END
