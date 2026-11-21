vim9script

def GitGui_addCommand()
  if executable('git') && has('win32')
    command GitGui {
      #
      if finddir('.git', '.;')->empty()
        echomsg 'outside working copy.'
        return
      endif

      #
      call job_start('git gui', { 'in_io': 'null', 'out_io': 'null', 'err_io': 'null' })
    }
  endif
enddef


augroup plugin_git_gui_autocmd
  autocmd!
  autocmd VimEnter * call GitGui_addCommand()
augroup END

