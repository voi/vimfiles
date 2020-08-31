" vim:set sw=2:
" Vim syn file
let s:save_cpo = &cpo
set cpo&vim

let s:todotext_done_line_regex = '^[xX]\s+\d\{4}-\d\{2}-\d\{2}'
let s:todotext_track_time_regex = '\%(^\|\s\)\zst:\d\{4}-\d\{2}-\d\{2}T\d\{2}:\d\{2}_\ze\%(\s\|$\)'

""""""""""""""""""""""""""""""""""""""""""""
"" 
nmap <buffer> <Leader>x :call TodoTxt_Toggle_Done()<CR>
nmap <buffer> <Leader>c :call TodoTxt_Toggle_Tracking()<CR>

imap <buffer> + +<C-r>=TodoTxt_Project_Completion()<CR>
imap <buffer> @ @<C-r>=TodoTxt_Context_Completion()<CR>

inoreabbrev <expr> due: { -> 'due:' . strftime('%Y-%m-%d') }()
inoreabbrev <expr> t: { -> 't:' . strftime('%Y-%m-%dT%H:%M_') }()


""
function! TodoTxt_Toggle_Done() "{{{
  let line = getline('.')

  if line =~# s:todotext_done_line_regex
    let line = substitute(line, s:todotext_done_line_regex, '  ', '')
  else
    let line = substitute(line, '^\s*', strftime('x %Y-%m-%d '), '')
  endif

  call setline('.', line)
endfunction "}}}

""
function! TodoTxt_Toggle_Tracking() "{{{
  let line = getline('.')

  if line =~# s:todotext_track_time_regex
    let line = substitute(line, s:todotext_track_time_regex, '&' . strftime('%H:%M'), '')
  else
    let line = line . strftime(' t:%Y-%m-%dT%H:%M_')

    if line !~# '^\s*\d\{4}-\d\{2}-\d\{2}\s'
      let line = strftime('  %Y-%m-%d ') . line
    endif
  endif

  call setline('.', line)
endfunction "}}}

""
function! s:todotxt_get_tags(tag_pattern) "{{{
  let tags = []

  for line in getline(1, '$')
  endfor

  return tags
endfunction "}}}

""
function! TodoTxt_Project_Completion() "{{{
  call complete(col('.'), s:todotxt_get_tags(''))
  return ''
endfunction "}}}

""
function! TodoTxt_Context_Completion() "{{{
  call complete(col('.'), s:todotxt_get_tags(''))
  return ''
endfunction "}}}


""""""""""""""""""""""""""""""""""""""""""""
let &cpo = s:save_cpo
unlet s:save_cpo
