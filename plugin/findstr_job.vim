"" 
if has('win32')
  ""
  function! s:findstr_job_start(args) abort "{{{
    call setloclist(0, [])

    call job_start(
        \ ['findstr', '/NRS'] + a:args,
        \ {
        \   'out_cb': { ch, msg -> setloclist(0, [], 'a', { 'lines': split(msg, '\n'), 'title': 'findstr ' . join(a:args, ' ') }) },
        \   'close_cb': { ch -> execute('topleft lwindow') }
        \ } )
  endfunction "}}}

  ""
  command! -nargs=+ -complete=dir Findstr call s:findstr_job_start([<f-args>])

endif

