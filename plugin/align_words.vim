vim9script

g:align_words_petterm_list = []

def Align_calc_padding_tabs(token: string, align_width: number): string
  var ts = &tabstop
  var adjust_width = (align_width % ts == 0)
    ? align_width
    : ((align_width + ts) / ts) * ts
  var mergin = adjust_width - strdisplaywidth(token)

  return repeat("\t", ((mergin + (mergin % ts ? ts : 0)) / ts))
enddef

def Align_calc_padding_space(token: string, align_width: number): string
  return repeat(' ', align_width - strdisplaywidth(token))
enddef

def Align_get_token(tokens: list<string>, align_width: number, ctx: dict<any>): list<string>
  if len(tokens) > 1
    var token = substitute(remove(tokens, 0), '\s*$', '', '')

    tokens[0] = token .. ctx.Filler(token, align_width) .. tokens[0]
  endif

  return tokens
enddef

def Align_parse(arguments: list<string>): dict<any>
  var ctx = {
    pattern: '',
    global: '',
    Filler: function(Align_calc_padding_space),
    sub: '\n&',
    delim: '\n'
  }
  var use_regexp = false
  var case = ''

  for opt in arguments
    if     opt ==# '-g' | ctx.global = 'g'
    elseif opt ==# '-t' | ctx.Filler = function(Align_calc_padding_tabs)
    elseif opt ==# '-a' | ctx.sub = '&\n' | ctx.delim = '\n\s*'
    elseif opt ==# '-r' | use_regexp = true
    elseif opt ==# '-c' | case = '\C'
    else                | ctx.pattern = opt
    endif
  endfor

  if use_regexp
    ctx.pattern = case .. ctx.pattern
  else
    ctx.pattern = '\V' .. case .. escape(ctx.pattern, '\')
  endif

  return ctx
enddef

def Align_apply(startl: number, endl: number, arguments: list<string>)
  if empty(arguments) | return | endif

  var ctx = Align_parse(arguments)
  var line_tokens = map(
    getline(startl, endl),
    (key, val) => split(substitute(val, ctx.pattern, ctx.sub, ctx.global), ctx.delim, 1))
  var width = 0

  while 1 < max(
      map(
          copy(line_tokens),
          (key, val) => len(val)))
    # 
    width = max(
      map(
        filter(
          copy(line_tokens),
          (idx, val) => (len(val) > 1)),
        (key, val) => strdisplaywidth(val[0])))
    # 
    line_tokens = map(
      line_tokens,
      (key, val) => Align_get_token(val, width, ctx))
  endwhile

  if width > 0
    call setline(startl, map(line_tokens, (key, val) => val[0]))
  endif
enddef

def Align_complete(ArgLead: string, CmdLine: string, CursorPos: number): any
  return g:align_words_petterm_list
enddef

command! -range -nargs=+ -complete=customlist,Align_complete Align
      \ call <SID>Align_apply(<line1>, <line2>, [<f-args>])

