" https://arimasou16.com/blog/2017/03/17/00211/
" https://sakura-editor.github.io/help/HLP000109.html
"" 
if has('win32')
  ""
  function! s:sakura_grep_job_start(args) abort "{{{
    "
    call setloclist(0, [])
    call job_start(
        \ [ 'sakura', '-GREPMODE', '-GOPT=SRP1UH', '-GCODE=99',
        \   printf('-GKEY=%s', get(a:args, 0, expand('<cword>'))),
        \   printf('-GFILE=%s', get(a:args, 1, '*' . expand('%:e'))),
        \   printf('-GFOLDER=%s', get(a:args, 2, fnameescape(expand('%:p:h'))))
        \ ],
        \ {
        \   'out_cb': { ch, msg -> setloclist(0, [], 'a', { 'efm': "%f\t%l\t%m", 'lines': split(msg, '\n'), 'title': 'sakura grep ' . join(a:args, ' ') }) },
        \   'close_cb': { ch -> execute('topleft lwindow') }
        \ } )
  endfunction "}}}

  ""
  " SakuraGrep [word] [filter] [folder]
  command! -nargs=* -complete=dir SakuraGrep call s:sakura_grep_job_start([<f-args>])

endif

