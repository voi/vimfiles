vim9script

def EncloseText_parse(arguments: list<string>): any
  var command = '-a'
  var Escape = (val) => '\V' .. escape(val, '\')
  var triming = ''
  var tokens = []

  for arg in arguments
    if     arg =~# '^-[adr]$' | command = arg
    elseif arg ==# '-t'       | triming = '\v\s*'
    elseif arg ==# '-c'
      tokens = split(&commentstring, '%s', 1)
        ->map((i, v) => v->substitute('^\s\+$', '', ''))
    else                      | call add(tokens, arg)
    endif
  endfor

  tokens += [ '', '', '', '' ]

  if command ==# '-a'
    return ({
      fo: '^' .. triming,
      fc: triming .. '$',
      to: tokens[0],
      tc: tokens[1],
    })
  elseif command ==# '-d'
    return ({
      fo: '^' .. Escape(tokens[0]) .. triming,
      fc: triming .. Escape(tokens[1]) .. '\v$',
      to: '',
      tc: '',
    })
  elseif command ==# '-r'
    return ({
      fo: '^' .. Escape(tokens[0]) .. triming,
      fc: triming .. Escape(tokens[1]) .. '\v$',
      to: tokens[2],
      tc: tokens[3],
    })
  endif

  return {}
enddef

def EncloseText_edit(source: string, pattern: any, is_head: bool, is_tail: bool): string
  var text = source

  if is_head && !(empty(pattern.fo) && empty(pattern.to))
    text = substitute(text, pattern.fo, pattern.to, '')
  endif

  if is_tail && !(empty(pattern.fc) && empty(pattern.tc))
    text = substitute(text, pattern.fc, pattern.tc, '')
  endif

  return text
enddef

var enclose_text_context = {}

def EncloseText_apply(arguments: list<string>)
  enclose_text_context = EncloseText_parse(arguments)

  if visualmode() ==# 'v' && getpos("'<")[1] != getpos("'>")[1]
    keepjumps execute ":'<s/\\%V.*/\\=EncloseText_edit(submatch(0), enclose_text_context, true, false)/e"
    keepjumps execute ":'>s/.*\\%V.\\?/\\=EncloseText_edit(submatch(0), enclose_text_context, false, true)/e"
  else
    keepjumps execute ":'<,'>s/\\%V.*\\%V.\\?/\\=EncloseText_edit(submatch(0), enclose_text_context, true, true)/e"
  endif

  normal `<
enddef

def EncloseText_complete(argload: string, cmdline: string, cursorpos: number): any
  return get(g:, 'enclose_text_pattern_list', [
    '-a ( )',
    '-a (\  \ )',
    '-d ( )',
    '-d -t ( )'
  ])->filter((i, v) => v =~ argload)

enddef

command! -range -nargs=* -complete=customlist,EncloseText_complete EncloseText 
      \ call EncloseText_apply([ <f-args> ])

