function s:Vimrc_changelog_new_entry() "{{{
  let header = printf('# %s  ################################', strftime('%Y-%m-%d'))
  let entry = strftime('* <?dt %Y-%m-%dT%H:%M ?> ')

  if line('.') == 1
    let lnum = ( getline('.') =~# '^' . header )
  else
    let lnum = search('^' . header, 'bW', 1)
  endif

  if lnum
    call append(lnum, [ '', entry ])
    call cursor(lnum + 2, 9999)
  else
    call append(0, [ header, '', entry])
    call cursor(3, 9999)
  endif
endfunction "}}}

augroup ftplugin-changelogmd-event
  autocmd BufNewFile,BufReadPost changelog.md nnoremap <buffer> <silent> <Leader>o :<C-u>call <SID>Vimrc_changelog_new_entry()<CR>
  autocmd BufNewFile,BufReadPost changelog.md xnoremap <buffer> <silent> <Leader>o :<C-u>call <SID>Vimrc_changelog_new_entry()<CR>
augroup END

