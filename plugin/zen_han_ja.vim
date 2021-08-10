scriptencoding utf-8

let s:kana_dakuten = {
      \ 'saffix': 'ﾞ',
      \ 'han': 'ｳｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾊﾋﾌﾍﾎ',
      \ 'zen': 'ヴガギグゲゴザジズゼゾダヂヅデドバビブベボ'
      \ }
let s:kana_handakuten = {
      \ 'saffix': 'ﾟ',
      \ 'han': 'ﾊﾋﾌﾍﾎ',
      \ 'zen': 'パピプペポ'
      \ }
let s:kana = {
      \ 'saffix': '',
      \ 'han': 'ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ',
      \ 'zen': 'ヲァィゥェォャュョッーアイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワン'
      \ }
let s:alpha = {
      \ 'saffix': '',
      \ 'han': 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz',
      \ 'zen': 'ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ'
      \ }
let s:number = {
      \ 'saffix': '',
      \ 'han': '0123456789',
      \ 'zen': '０１２３４５６７８９'
      \ }
let s:symbol = {
      \ 'saffix': '',
      \ 'han': '!"#$%&' . "'" . '()*+,-./:;<=>?@[\]^_`{|}~',
      \ 'zen': '！”＃＄％＆’（）＊＋，－．／：；＜＝＞？＠［￥］＾＿‘｛｜｝～'
      \ }

function! s:char_map(str, rule) "{{{
  return a:rule.to[index(a:rule.from, a:str)] . a:rule.saffix
endfunction "}}}

function! s:convert(text, rules) "{{{
  let l:text = a:text

  for l:rule in a:rules
    let l:text = substitute(l:text, l:rule.match, '\=s:char_map(submatch(1), l:rule)', 'g')
  endfor

  return l:text
endfunction "}}}

function! s:get_rule_to_han(context) "{{{
  return { 
        \ 'saffix': a:context.saffix,
        \ 'match': '\m\([' . a:context.zen . ']\)',
        \ 'from': split(a:context.zen, '\zs'),
        \ 'to': split(a:context.han, '\zs')
        \ }
endfunction "}}}

function! s:get_rule_to_zen(context) "{{{
  return { 
        \ 'saffix': '',
        \ 'match': '\m\([' . escape(a:context.han, '[]\-^$*.') . ']\)' . a:context.saffix,
        \ 'from': split(a:context.han, '\zs'),
        \ 'to': split(a:context.zen, '\zs')
        \ }
endfunction "}}}

function! s:get_rules(types, rule_maker) "{{{
  let l:rules = []

  if a:types =~# 'K'
    let l:rules += [
          \ a:rule_maker(s:kana_dakuten),
          \ a:rule_maker(s:kana_handakuten),
          \ a:rule_maker(s:kana)
          \ ]
  endif

  if a:types =~# 'A'
    call add(l:rules, a:rule_maker(s:alpha))
  endif

  if a:types =~# 'N'
    call add(l:rules, a:rule_maker(s:number))
  endif

  if a:types =~# 'S'
    call add(l:rules, a:rule_maker(s:symbol))
  endif

  return l:rules
endfunction "}}}

function! s:apply_rules(line_begin, line_end, rules) "{{{
  if empty(a:rules)
    return
  endif

  for l:lnum in range(a:line_begin, a:line_end)
    call setline(l:lnum, s:convert(getline(l:lnum), a:rules))
  endfor
endfunction "}}}

function! s:to_Hankaku(line_begin, line_end, types) "{{{
  let l:rules = s:get_rules(toupper(a:types), function('s:get_rule_to_han'))

  call s:apply_rules(a:line_begin, a:line_end, l:rules)
endfunction "}}}

function! s:to_Zenkaku(line_begin, line_end, types) "{{{
  let l:rules = s:get_rules(toupper(a:types), function('s:get_rule_to_zen'))

  call s:apply_rules(a:line_begin, a:line_end, l:rules)
endfunction "}}}

function! ZenHanJaComplete(ArgLead, CmdLine, CursorPos) "{{{
  return [ 'K', 'A', 'N', 'S' ]
endfunction "}}}

command! -range -nargs=0 Hankaku  call s:to_Hankaku(<line1>, <line2>, 'KANS')
command! -range -nargs=0 HankakuK call s:to_Hankaku(<line1>, <line2>, 'K')
command! -range -nargs=0 HankakuA call s:to_Hankaku(<line1>, <line2>, 'AN')
command! -range -nargs=0 HankakuS call s:to_Hankaku(<line1>, <line2>, 'S')
command! -range -nargs=* -complete=customlist,ZenHanJaComplete HankakuX call s:to_Hankaku(<line1>, <line2>, '<args>')

command! -range -nargs=0 Zenkaku  call s:to_Zenkaku(<line1>, <line2>, 'KANS')
command! -range -nargs=0 ZenkakuK call s:to_Zenkaku(<line1>, <line2>, 'K')
command! -range -nargs=0 ZenkakuA call s:to_Zenkaku(<line1>, <line2>, 'AN')
command! -range -nargs=0 ZenkakuS call s:to_Zenkaku(<line1>, <line2>, 'S')
command! -range -nargs=* -complete=customlist,ZenHanJaComplete ZenkakuX call s:to_Zenkaku(<line1>, <line2>, '<args>')

