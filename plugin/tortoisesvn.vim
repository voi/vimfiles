"" 
if has('win32') && executable('TortoiseProc.exe')
  "" 
  function! s:tsvn_command_do(command, arguments) abort "{{{
    if a:arguments ==# ''
      let l:path = finddir('.svn', getcwd()->fnamemodify(':p:h') . ';')->fnamemodify(':h')
    else
      let l:path = a:arguments
    endif

    let l:cmdline = 'TortoiseProc.exe /command:' . a:command . ' /path:"' . l:path . '"'

    if has('iconv') && (&termencoding != &encoding)
      let l:cmdline = iconv(l:cmdline, &encoding, &termencoding)
    endif

    call job_start(l:cmdline, { 'in_io': 'null', 'out_io': 'null', 'err_io': 'null' })
  endfunction

  ""
  command! -nargs=? -complete=file TSvnLog    call <SID>tsvn_command_do('log', <q-args>)
  command! -nargs=? -complete=file TSvnDiff   call <SID>tsvn_command_do('diff', <q-args>)
  command! -nargs=? -complete=file TSvnBlame  call <SID>tsvn_command_do('blame', <q-args>)
  command! -nargs=? -complete=file TSvnAdd    call <SID>tsvn_command_do('add', <q-args>)
  command! -nargs=? -complete=file TSvnStatus call <SID>tsvn_command_do('repostatus', <q-args>)
  command! -nargs=? -complete=file TSvnUpdate call <SID>tsvn_command_do('update', <q-args>)

  command! -nargs=0 TSvnCommit call <SID>tsvn_command_do('commit', <q-args>)
endif

