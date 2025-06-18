vim9script

def VcsCmd_get_cmdline(arguments: list<string>): string
  if has('win32') | arguments[0] ..= '.exe' | endif

  return arguments->join(' ')
enddef

def VcsCmd_exec_to_out(arguments: list<string>, ftype: string)
  var bnr = bufadd(arguments->join(' ')->escape('/\*?[]<>'))

  call bufload(bnr)
  call setbufvar(bnr, '&buftype', 'nofile')
  call setbufvar(bnr, '&bufhidden', 'hide')
  call setbufvar(bnr, '&swapfile', 0)

  execute 'silent botright :16split'
  execute 'silent buffer ' .. bnr

  redraw

  execute ':%!' .. VcsCmd_get_cmdline(arguments)
  execute 'setf ' .. ftype
  execute 'setl path+=' .. getcwd()

  silent setl buftype=nofile bufhidden=hide noswapfile nowrap
  silent setl nomodifiable readonly
enddef

def VcsCmd_execute(arguments: list<string>)
  #
  var cmdline = VcsCmd_get_cmdline(arguments)

  if &enc !=# &tenc | cmdline = cmdline->iconv(&enc, &tenc) | endif

  #
  var msg = system(cmdline)

  if &enc !=# &tenc | msg = msg->iconv(&tenc, &enc) | endif

  echomsg msg
enddef

def VcsCmd_addCommand()
  if executable('svn')
    # svn ls --search [glob pattern]
    command! -nargs=* -complete=dir SvnLs     call VcsCmd_exec_to_out(["svn", "ls", <q-args>], "svn")
    command! -nargs=* -complete=dir SvnStatus call VcsCmd_exec_to_out(["svn", "status", <q-args>], "svn")
    command! -nargs=* -complete=dir SvnUpdate call VcsCmd_exec_to_out(["svn", "update", <q-args>], "svn")

    command! -nargs=* -complete=file SvnLog   call VcsCmd_exec_to_out(["svn", "log", <q-args>], "svn")
    command! -nargs=* -complete=file SvnDiff  call VcsCmd_exec_to_out(["svn", "diff", <q-args>], "diff")
    command! -nargs=+ -complete=file SvnBlame call VcsCmd_exec_to_out(["svn", "blame", "--force", <q-args>], "svn")

    command! -nargs=+ -complete=file SvnAdd      call VcsCmd_execute(["svn", "add", <q-args>])
    command! -nargs=+ -complete=file SvnRevert   call VcsCmd_execute(["svn", "revert", <q-args>])
    command! -nargs=+ -complete=file SvnResolved call VcsCmd_execute(["svn", "resolved", <q-args>])

    command! -nargs=*                SvnHelp  call VcsCmd_exec_to_out(["svn", "help", <q-args>], "man")
  endif

  if executable('git')
    command! -nargs=* -complete=dir  GitLs     call VcsCmd_exec_to_out(["git", "ls-files", <q-args>], "git")
    command! -nargs=* -complete=dir  GitStatus call VcsCmd_exec_to_out(["git", "status", "-s", <q-args>], "git")
    command! -nargs=* -complete=dir  GitGrep   call VcsCmd_exec_to_out(["git", "grep", <q-args>], "tags")

    command! -nargs=* -complete=file GitLog    call VcsCmd_exec_to_out(["git", "log", <q-args>], "git")
    command! -nargs=* -complete=file GitDiff   call VcsCmd_exec_to_out(["git", "diff", <q-args>], "diff")
    command! -nargs=+ -complete=file GitBlame  call VcsCmd_exec_to_out(["git", "blame", <q-args>], "git")

    command! -nargs=+ -complete=file GitAdd    call VcsCmd_execute(["git", "add", <q-args>])
    command! -nargs=+ -complete=file GitRevert call VcsCmd_execute(["git", "revert", <q-args>])

    command! -nargs=*                GitHelp  call VcsCmd_exec_to_out(["git", "help", "-g", <q-args>], "man")
  endif

  if executable('fossil')
    command! -nargs=* -complete=dir  FossilLs     call VcsCmd_exec_to_out(["fossil", "ls", <q-args>], "git")
    command! -nargs=* -complete=dir  FossilStatus call VcsCmd_exec_to_out(["fossil", "status", <q-args>], "git")
    command! -nargs=* -complete=dir  FossilChange call VcsCmd_exec_to_out(["fossil", "change", <q-args>], "git")
    command! -nargs=* -complete=dir  FossilGrep   call VcsCmd_exec_to_out(["fossil", "grep", <q-args>], "tags")

    command! -nargs=* -complete=file FossilDiff   call VcsCmd_exec_to_out(["fossil", "diff", <q-args>], "diff")
    command! -nargs=+ -complete=file FossilBlame  call VcsCmd_exec_to_out(["fossil", "blame", <q-args>], "git")

    command! -nargs=+ -complete=file FossilAdd    call VcsCmd_execute(["fossil", "add", <q-args>])
    command! -nargs=+ -complete=file FossilRevert call VcsCmd_execute(["fossil", "revert", <q-args>])

    command! -nargs=*                FossilLog   call VcsCmd_exec_to_out(["fossil", "timeline -v -n 0", <q-args>], "git")
    command! -nargs=*                FossilHelp  call VcsCmd_exec_to_out(["fossil", "help", <q-args>], "man")
  endif
enddef

augroup _plugin_vcs_command_
  autocmd!
  autocmd VimEnter * call VcsCmd_addCommand()
augroup END

