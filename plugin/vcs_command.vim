" *****************************************************************************
""
function! s:vcs_job_out_cb(msg, efm) "{{{
  if has('iconv') && &termencoding != &encoding
    let out = iconv(a:msg, &termencoding, &encoding)
  else
    let out = a:msg
  endif

  call setloclist(0, [], 'a', { 'efm': a:efm, 'lines': split(out, '\n') })
endfunction "}}}

""
function! s:vcs_job_close_cb() "{{{
  topleft lwindow

  call matchadd('Conceal', '||\s$')

  setl concealcursor=n
  setl conceallevel=3
endfunction "}}}
""
function! s:vcs_get_list(arguments, errorformat) "{{{
    call setloclist(0, [])
    call job_start(
        \ a:arguments,
        \ {
        \   'out_cb': { ch, msg -> s:vcs_job_out_cb(msg, a:errorformat) },
        \   'close_cb': { ch -> s:vcs_job_close_cb() }
        \ } )
endfunction "}}}

""
function! s:vcs_get_output(arguments, extension) "{{{
  silent! tab new

  execute('r !' . join(a:arguments, ' '))
  execute('setf ' . a:extension)

  setlocal buftype=nofile bufhidden=hide
  setlocal noswapfile nowrap nonumber
  setlocal nolist nobuflisted
endfunction "}}}

""
function! s:vcs_command(arguments) "{{{
  if has('iconv') && &termencoding !=# &encoding
    return iconv(system(iconv(join(a:arguments, ' '), &encoding, &termencoding)), &termencoding, &encoding)
  else
    return system(join(a:arguments, ' '))
  endif
endfunction "}}}

"" subversion
if executable('svn')
  command! -nargs=? -complete=dir  SvnLs     call <SID>vcs_get_list([ 'svn', 'ls', <q-args> ], '%f')
  command! -nargs=? -complete=dir  SvnStatus call <SID>vcs_get_list([ 'svn', 'status', <q-args> ], '%m\t%f')
  command! -nargs=? -complete=dir  SvnUpdate call <SID>vcs_get_list([ 'svn', 'update', <q-args> ], '%m\t%f')

  command! -nargs=? -complete=file SvnLog    call <SID>vcs_get_output(['svn', 'log', <q-args> ], 'log')
  command! -nargs=? -complete=file SvnDiff   call <SID>vcs_get_output(['svn', 'diff', <q-args> ], 'diff')
  command! -nargs=? -complete=file SvnBlame  call <SID>vcs_get_output(['svn', 'blame', '--force', <q-args> ], 'blame')

  command! -nargs=? -complete=file SvnAdd       call <SID>vcs_command([ 'svn', 'add', <q-args> ])
  command! -nargs=? -complete=file SvnRevert    call <SID>vcs_command([ 'svn', 'revert', <q-args> ])
  command! -nargs=? -complete=file SvnResolved  call <SID>vcs_command([ 'svn', 'resolved', <q-args> ])
endif

" git
if executable('git')
  command! -nargs=? -complete=dir  GitLs     call <SID>vcs_get_list([ 'git', 'ls-files', <q-args> ], '%f')
  command! -nargs=? -complete=dir  GitStatus call <SID>vcs_get_list([ 'git', 'status', '-s', <q-args> ], '%m\t%f')

  command! -nargs=? -complete=file GitLog    call <SID>vcs_get_output(['git', 'log', <q-args> ], 'log')
  command! -nargs=? -complete=file GitDiff   call <SID>vcs_get_output(['git', 'diff', <q-args> ], 'diff')
  command! -nargs=? -complete=file GitBlame  call <SID>vcs_get_output(['git', 'blame', <q-args> ], 'blame')

  command! -nargs=? -complete=file GitAdd       call <SID>vcs_command(['git', 'add', <q-args> ])
  command! -nargs=? -complete=file GitRevert    call <SID>vcs_command(['git', 'revert', <q-args> ])
  command! -nargs=? -complete=file GitResolved  call <SID>vcs_command(['git', 'resolved', <q-args> ])
endif

"" bzr
if executable('bzr')
  "" TODO: 
endif

"" mercurial
if executable('hg')
  "" TODO: 
endif

"" fossil
if executable('fossil')
  "" TODO: 
endif

