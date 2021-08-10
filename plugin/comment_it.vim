" *****************************************************************************
function! s:comment_toggle(first_line, last_line) abort "{{{
  let [cbegin, cend] = split(escape(&commentstring, '/?'), '\s*%s\s*', 1)
  let pattern = printf('^\(\s*\)\V%s\m\s\?\(.*\)\s\?\V%s', cbegin, cend)

  for ln in range(a:first_line, a:last_line)
    let line = getline(ln)
    if line =~# pattern
      execute printf('%ds/%s/\1\2/', ln, pattern)
    elseif line !=# ''
      execute printf('%ds/\v^(\s*)(\S.*)/\1%s%s\2%s%s/',
          \ ln, cbegin, (empty(cbegin) ? '' : ' '), (empty(cend) ? '' : ' '), cend)
    endif
  endfor
endfunction "}}}

command! -range -nargs=0 CommentIt call <SID>comment_toggle(<line1>, <line2>) 


