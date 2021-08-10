" *****************************************************************************
"
" command! -bang -nargs=1 GTag  call <SID>quickfix_command(
"     \ <bang>0, [ '(', 'global -qax', <q-args>, '&', 'global -qax -s -r', <q-args>, ')' ],
"     \ '%*\S%*\s%l%\s%f%\s%m')
" 
"" 
if executable('global.exe') || executable('global')
  ""
  function! s:gtags_job_out_cb(msg) "{{{
    if has('iconv') && &termencoding != &encoding
      let out = iconv(a:msg, &termencoding, &encoding)
    else
      let out = a:msg
    endif

    call setloclist(0, [], 'a', { 'efm': "%f\t%l\t%m", 'lines': split(out, '\n') })
  endfunction "}}}

  ""
  function! s:gtags_job_start(args) abort "{{{
    let ctx = {
        \ 'out_cb': { ch, msg -> s:gtags_job_out_cb(msg) },
        \ 'close_cb': { ch -> execute('topleft lwindow') }
        \ }

    call setloclist(0, [])

    call job_start('global -qa   --result=ctags-mod ' . a:args, ctx)
    call job_start('global -qasr --result=ctags-mod ' . a:args, ctx)
  endfunction "}}}

  ""
  command! -nargs=1 GTag call s:gtags_job_start(<q-args>)

endif
