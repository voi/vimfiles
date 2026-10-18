vim9script

augroup _plugin_ripgrep_
  autocmd VimEnter * {
    if executable('rg')
      set grepprg=rg\ --follow\ --text\ --hidden\ --vimgrep\ --no-heading\ --line-number\ --color\ never
      set grepformat=%f:%l:%c:%m
    endif
  }
augroup END

