vim9script

scriptencoding utf-8

g:skk_jisyo = fnamemodify(globpath(&rtp, '_skk/') .. '.skk-jisyo', ':p')
g:skk_large_jisyo = fnamemodify(globpath(&rtp, '_skk/') .. 'SKK-JISYO.L', ':p')
g:skk_manual_save_jisyo_keys = ''
g:skk_auto_save_jisyo = 1
g:skk_egg_like_newline = 1
g:skk_show_annotation = 1
g:skk_sticky_key = ";"
g:skk_marker_white = '»'
g:skk_marker_black = '▸'
g:skk_user_rom_kana_rules = ""
      \ .. "z0	０\<NL>"
      \ .. "z1	１\<NL>"
      \ .. "z2	２\<NL>"
      \ .. "z3	３\<NL>"
      \ .. "z4	４\<NL>"
      \ .. "z5	５\<NL>"
      \ .. "z6	６\<NL>"
      \ .. "z7	７\<NL>"
      \ .. "z8	８\<NL>"
      \ .. "z9	９\<NL>"
      \ .. "z(	（\<NL>"
      \ .. "z)	）\<NL>"
      \ .. "z{	｛\<NL>"
      \ .. "z}	｝\<NL>"
      \ .. "z[	［	【	「	『\<NL>"
      \ .. "z]	］	】	」	』\<NL>"
      \ .. "z~	＠\<NL>"
      \ .. "z!	！\<NL>"
      \ .. "z#	＃\<NL>"
      \ .. "z$	＄\<NL>"
      \ .. "z%	％\<NL>"
      \ .. "z&	＆\<NL>"
      \ .. "z@	＠\<NL>"
      \ .. "z 	　\<NL>"
      \ .. "j,	，\<NL>"
      \ .. "j.	．\<NL>"
      \ .. "c1	①\<NL>"
      \ .. "c2	②\<NL>"
      \ .. "c3	③\<NL>"
      \ .. "c4	④\<NL>"
      \ .. "c5	⑤\<NL>"
      \ .. "c6	⑥\<NL>"
      \ .. "c7	⑦\<NL>"
      \ .. "c8	⑧\<NL>"
      \ .. "c9	⑨\<NL>"

