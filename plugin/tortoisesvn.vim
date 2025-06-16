vim9script

if has('win32') && executable('TortoiseProc.exe')

  def TSvn_command_do(command: string, arguments: string)
    var path = arguments

    if path->empty()
      path = finddir('.svn', getcwd() .. ';')

      if !path->empty()
        path = path->fnamemodify(':h')->fnamemodify(':p')
      endif
    endif

    if path->empty() | echomsg 'outside workcopy.' | return | endif

    #
    var cmdline = printf('TortoiseProc.exe /command:%s /path:"%s"', command, path)

    if has('iconv') && (&termencoding != &encoding)
      cmdline = iconv(cmdline, &encoding, &termencoding)
    endif

    call job_start(cmdline, { 'in_io': 'null', 'out_io': 'null', 'err_io': 'null' })
  enddef

  #
  command! -nargs=? -complete=file TSvnLog    call TSvn_command_do('log', <q-args>)
  command! -nargs=? -complete=file TSvnDiff   call TSvn_command_do('diff', <q-args>)
  command! -nargs=? -complete=file TSvnBlame  call TSvn_command_do('blame', <q-args>)
  command! -nargs=? -complete=file TSvnAdd    call TSvn_command_do('add', <q-args>)
  command! -nargs=? -complete=file TSvnStatus call TSvn_command_do('repostatus', <q-args>)
  command! -nargs=? -complete=file TSvnUpdate call TSvn_command_do('update', <q-args>)

  command! -nargs=?                TSvnCommit call TSvn_command_do('commit', <q-args>)
endif

