" ****************************************************************
function! Stall_command_complete(argLead, cmdLine, cursorPos) "{{{
  return filter(keys(get(g:, 'stall_sources', {})), { idx, val -> val =~# a:argLead })
endfunction "}}}


" ********************************
command! -nargs=+ -complete=customlist,Stall_command_complete Stall 
    \ call stall#command_open('<mods>', [ <f-args> ])

command! -nargs=+ -complete=file StallBookmarkAdd call stall#command_bookmark_add([ <f-args> ])

" ********
augroup stall_source_history_augroup
  autocmd!
  autocmd BufReadPost,BufWritePost * call stall#event_record_opened_file()
augroup END
