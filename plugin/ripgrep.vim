vim9script

augroup _plugin_ripgrep_
  autocmd VimEnter * {
    if executable('rg')
      set grepprg=rg\ --vimgrep
      set grepformat=%f:%l:%c:%m
    endif
  }
augroup END

