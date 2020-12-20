" *****************************************************************************
function! s:align_calc_padding_tabs(token, align_width) abort "{{{
  let l:ts = &tabstop
  let l:align_width = (a:align_width % l:ts == 0) ? a:align_width :
      \ ((a:align_width + l:ts) / l:ts) * l:ts
  let l:mergin = l:align_width - strdisplaywidth(a:token)

  return repeat("\t", ((l:mergin + (l:mergin % l:ts ? l:ts : 0)) / l:ts))
endfunction "}}}

function! s:align_calc_padding_space(token, align_width) abort "{{{
  return repeat(' ', a:align_width - strdisplaywidth(a:token))
endfunction "}}}

function! s:align_get_token(tokens, align_width, ctx) abort "{{{
  if len(a:tokens) > 1
    let l:token = substitute(remove(a:tokens, 0), '\s*$', '', '')

    let a:tokens[0] = l:token
        \ . a:ctx.filler(l:token, a:align_width)
        \ . a:tokens[0]
  endif

  return a:tokens
endfunction "}}}

function! s:Align_parse(arguments) abort "{{{
  let l:ctx = {
      \ 'pattern': '',
      \ 'global': '',
      \ 'filler': function('<SID>align_calc_padding_space'),
      \ 'sub': '\n&',
      \ 'delim': '\n'
      \ }
  let l:use_regexp = 0
  let l:case = ''

  for l:opt in a:arguments
    if     l:opt ==# '-g' | let l:ctx.global = 'g'
    elseif l:opt ==# '-t' | let l:ctx.filler = function('<SID>align_calc_padding_tabs')
    elseif l:opt ==# '-a' | let l:ctx.sub = '&\n' | let l:ctx.delim = '\n\s*'
    elseif l:opt ==# '-r' | let l:use_regexp = 1
    elseif l:opt ==# '-c' | let l:case = '\C'
    else                  | let l:ctx.pattern = l:opt
    endif
  endfor

  if l:use_regexp
    let l:ctx.pattern = l:case . l:ctx.pattern
  else
    let l:ctx.pattern = '\V' . l:case . escape(l:ctx.pattern, '\')
  endif

  return l:ctx
endfunction "}}}

function! s:align_apply(startl, endl, arguments) abort "{{{
  if empty(a:arguments)
    return
  endif

  let l:ctx = s:Align_parse(a:arguments)
  let l:line_tokens = map(getline(a:startl, a:endl),
      \ { key, val -> split(substitute(val, l:ctx.pattern, l:ctx.sub, l:ctx.global), l:ctx.delim, 1) })
  let l:width = 0

  while max(map(copy(l:line_tokens), { key, val -> (len(val) > 1) }))
    " 
    let l:width = max(map(filter(copy(l:line_tokens),
        \   { idx, val -> (len(val) > 1) }),
        \ { key, val -> strdisplaywidth(val[0]) }))
    " 
    let l:line_tokens = map(l:line_tokens,
        \ { key, val -> s:align_get_token(val, l:width, l:ctx) })
  endwhile

  if l:width > 0
    call setline(a:startl, map(l:line_tokens, 'v:val[0]'))
  endif
endfunction "}}}

function! s:align_complete_arguments(ArgLead, CmdLine, CursorPos) abort "{{{
  return [ '-g', '-t', '-a', '-r', '-c' ]
endfunction "}}}

command! -range -nargs=+ -complete=customlist,<SID>align_complete_arguments Align
    \ call <SID>align_apply(<line1>, <line2>, [<f-args>])

