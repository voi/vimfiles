vim9script

def GitGui_addCommand()
  if executable('git')
    command -nargs=* GitGrep {
      var current_grep = getbufvar('%', '&grepreg') # 前回の設定値の保存

      setlocal grepprg=git\ grep\ -I\ --line-number
      execute 'silent grep! ' . [<q-args>]->join(' ')

      setbufvar('%', '&grepprg', current_grep)
      redraw!
    }
  endif
enddef


augroup plugin_git_grep_autocmd
  autocmd!
  autocmd VimEnter * call GitGrep_addCommand()
augroup END

