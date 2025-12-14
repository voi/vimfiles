vim9script

# dakuten ( -> voiced mark )
var ZenHanJa_kana_dakuten = {
  saffix: 'ﾞ',
  han: 'ｳｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾊﾋﾌﾍﾎ',
  zen: 'ヴガギグゲゴザジズゼゾダヂヅデドバビブベボ',
  han_list: [],
  zen_list: []
}

ZenHanJa_kana_dakuten.han_list = ZenHanJa_kana_dakuten.han
  ->split('\ze')
  ->map((i, v) => v .. ZenHanJa_kana_dakuten.saffix)

ZenHanJa_kana_dakuten.zen_list = ZenHanJa_kana_dakuten.zen
  ->split('\ze')

# handakuten ( semi-voiced mark )
var ZenHanJa_kana_handakuten = {
  saffix: 'ﾟ',
  han: 'ﾊﾋﾌﾍﾎ',
  zen: 'パピプペポ',
  han_list: [],
  zen_list: []
}

ZenHanJa_kana_handakuten.han_list = ZenHanJa_kana_handakuten.han
  ->split('\ze')
  ->map((i, v) => v .. ZenHanJa_kana_handakuten.saffix)

ZenHanJa_kana_handakuten.zen_list = ZenHanJa_kana_handakuten.zen
  ->split('\ze')

var ZenHanJa_kana = {
  han: 'ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ',
  zen: 'ヲァィゥェォャュョッーアイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワン'
}

var ZenHanJa_alpha = {
  han: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz',
  zen: 'ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ'
}

var ZenHanJa_number = {
  han: '0123456789',
  zen: '０１２３４５６７８９'
}

var ZenHanJa_symbol = {
  han: '!"#$%&' .. "'" .. '()*+,-./:;<=>?@[\]^_`{|}~',
  zen: '！”＃＄％＆’（）＊＋，－．／：；＜＝＞？＠［￥］＾＿‘｛｜｝～'
}

def ZenHanJa_to_hankaku_normal(source: string, map: any): string
  return source->tr(map.zen, map.han)
enddef

def ZenHanJa_to_zenkaku_normal(source: string, map: any): string
  return source->tr(map.han, map.zen)
enddef

def ZenHanJa_to_hankaku_with_voicedmark(source: string, map: any): string
  return source->substitute(
    printf('[%s]', map.zen),
    (m) => map.han_list[map.zen_list->index(m[0])],
    'g')
enddef

def ZenHanJa_to_zenkaku_with_voicedmark(source: string, map: any): string
  return source->substitute(
    printf('[%s]%s', map.han, map.saffix),
    (m) => map.zen_list[map.han_list->index(m[0])],
    'g')
enddef

def ZenHanJa_edit(source: string, types: string, MapForSignle: func, MapForVoicedMark: func): string
  var text = source

  if types =~# 'K'
    text = MapForVoicedMark(text, ZenHanJa_kana_dakuten)
    text = MapForVoicedMark(text, ZenHanJa_kana_handakuten)
    text = MapForSignle(text, ZenHanJa_kana)
  endif

  if types =~# 'A'
    text = MapForSignle(text, ZenHanJa_alpha)
  endif

  if types =~# 'N'
    text = MapForSignle(text, ZenHanJa_number)
  endif

  if types =~# 'S'
    text = MapForSignle(text, ZenHanJa_symbol)
  endif

  return text
enddef

def ZenHanJa_apply(converterName: string, types: string)
  var beginln = getpos("'<")[1]
  var endln = getpos("'>")[1]
  var expr_part = printf("ZenHanJa_edit(submatch(0), '%s', %s_normal, %s_with_voicedmark)",
        types, converterName, converterName)

  if visualmode() ==# 'v' && beginln != endln
    keepjumps execute ":'<s/\\%V.*/\\=" .. expr_part .. "/e"
    keepjumps execute ":'>s/.*\\%V.\\?/\\=" .. expr_part .. "/e"

    if (endln - beginln) > 1
      keepjumps execute ":'<+1,'>-1s/\\%V.*\\%V.\\?/\\=" .. expr_part .. "/e"
    endif
  else
    keepjumps execute ":'<,'>s/\\%V.*\\%V.\\?/\\=" .. expr_part .. "/e"
  endif
enddef

def ZenHanJa_Complete(arglead: string, cmdline: string, cursorpos: number): list<string>
  return [ 'K', 'A', 'N', 'S' ]
enddef

command! -range -nargs=* -complete=customlist,ZenHanJa_Complete Hankaku call ZenHanJa_apply('ZenHanJa_to_hankaku', '<args>')
command! -range -nargs=* -complete=customlist,ZenHanJa_Complete Zenkaku call ZenHanJa_apply('ZenHanJa_to_zenkaku', '<args>')

