" *****************************************************************************
function! s:enclose_text_parse(arguments) abort "{{{
  let l:command = '-a'
  let l:Escape = { val -> '\V' . escape(val, '\') }
  let l:trim_ptn = ''
  let l:spacing = ''
  let l:tokens = []

  for l:arg in a:arguments
    if     l:arg =~# '^-[adr]$' | let l:command = l:arg
    elseif l:arg ==# '-g'       | let l:Escape = { val -> val }
    elseif l:arg ==# '-s'       | let l:spacing = ' '
    elseif l:arg ==# '-t'       | let l:trim_ptn = '\v\s*'
    else                        | call add(l:tokens, l:arg)
    endif
  endfor

  let l:tokens += [ '', '', '', '' ]

  if     l:command ==# '-a'
    return {
        \ 'fo': '^' . l:trim_ptn,
        \ 'fc': l:trim_ptn . '$',
        \ 'to': l:tokens[0] . l:spacing,
        \ 'tc': l:spacing . l:tokens[1]
        \ }
  elseif l:command ==# '-d'
    return {
        \ 'fo': '^' . l:Escape(l:tokens[0]) . l:trim_ptn,
        \ 'fc': l:trim_ptn . l:Escape(l:tokens[1]) . '\v$',
        \ 'to': '',
        \ 'tc': ''
        \ }
  elseif l:command ==# '-r'
    return {
        \ 'fo': '^' . l:Escape(l:tokens[0]) . l:trim_ptn,
        \ 'fc': l:trim_ptn . l:Escape(l:tokens[1]) . '\v$',
        \ 'to': l:tokens[2] . l:spacing,
        \ 'tc': l:spacing . l:tokens[3]
        \ }
  endif

  return {}
endfunction "}}}

function! s:enclose_text_edit(text, pattern, type) abort "{{{
  let l:edit_text = a:text

  if and(a:type, 0x01)
    let l:edit_text = substitute(l:edit_text, a:pattern.fo, a:pattern.to, '')
  endif

  if and(a:type, 0x02)
    let l:edit_text = substitute(l:edit_text, a:pattern.fc, a:pattern.tc, '')
  endif

  return l:edit_text
endfunction "}}}

function! s:enclose_text_apply(arguments) range abort "{{{
  let l:pattern = s:enclose_text_parse(a:arguments)

  if !empty(l:pattern)
    let l:is_multi_line = (getpos("'<")[1] != getpos("'>")[1])

    if visualmode() ==# 'v' && is_multi_line
      keepjumps execute "'<s/\\%V.*/\\=<SID>enclose_text_edit(submatch(0), l:pattern, 0x01)/e"
      keepjumps execute "'>s/.*\\%V.\\?/\\=<SID>enclose_text_edit(submatch(0), l:pattern, 0x02)/e"
    else
      keepjumps execute "'<,'>s/\\%V.*\\%V./\\=<SID>enclose_text_edit(submatch(0), l:pattern, 0x03)/e"
    endif

    execute "normal `<"
  endif
endfunction "}}}

function! s:enclose_text_complete_arguments(ArgLead, CmdLine, CursorPos) abort "{{{
  return [ '-a', '-d', '-r', '-g', '-s', '-t' ]
endfunction "}}}

"
command! -range -nargs=* -complete=customlist,<SID>enclose_text_complete_arguments
    \ EncloseText call <SID>enclose_text_apply([ <f-args> ])

"
vnoremap syy :EncloseText -a 
vnoremap sdd :EncloseText -d 
vnoremap srr :EncloseText -r 


