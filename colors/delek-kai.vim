" vim:ft=vim
set background=light
hi clear | syntax reset
let g:colors_name="delek-kai"


" -------------------------------------------------------------
""""
hi      Comment        term=bold ctermfg=4 guifg=#AAAAAA
hi      Constant       term=bold ctermfg=2 guifg=#00533E
hi      String         term=bold ctermfg=2 guifg=#007F00
hi link Character      String
hi      Number         term=bold ctermfg=2 guifg=#EB8400
hi      Boolean        term=bold ctermfg=2 guifg=#FFA400
hi link Float          Number

""""
hi Identifier     term=bold ctermfg=3 guifg=#00BCBC
hi Function       term=bold ctermfg=3 gui=bold guifg=#008B8B

""""
hi      Statement      term=bold cterm=bold ctermfg=9 guifg=#0000B2
hi link Conditional    Statement
hi link Repeat         Statement
hi link Label          Statement
hi      Operator       term=bold cterm=bold ctermfg=9 guifg=#0000FF
hi      Keyword        term=bold cterm=bold ctermfg=9 guifg=#6666FF
hi link Exception      Statement

""""
hi      PreProc        term=bold ctermfg=5 guifg=#CD00CD
hi link Include        PreProc
hi link Define         PreProc
hi link Macro          PreProc
hi link PreCondit      PreProc

""""
hi Type           term=bold ctermfg=9 gui=bold guifg=#FF7070
hi StorageClass   ctermfg=9 guifg=#BA0000
hi Structure      ctermfg=9 guifg=#DE4747
hi Typedef        ctermfg=9 guifg=#EE0000

""""
hi      Special        term=bold ctermfg=12 guifg=#FF7AC1
hi link SpecialChar    Special
hi      Tag            term=bold ctermfg=12 guifg=#FF1493
hi      Delimiter      term=bold ctermfg=12 guifg=#BF0F70
hi link SpecialComment Special
hi link Debug          Special

""""
hi Underlined     term=underline cterm=underline ctermfg=5 gui=underline guifg=#6A5ACD

""""
hi Ignore         ctermfg=15 guifg=bg

""""
hi Error          term=reverse ctermfg=15 ctermbg=12 gui=bold guifg=#FFFF00 guibg=#FF0000

""""
hi Todo           term=standout ctermfg=0 ctermbg=14 gui=bold guifg=#0000FF guibg=#FFFF00

""""
hi ColorColumn    term=reverse ctermbg=12 guibg=#FF0101
hi Conceal        ctermfg=7 ctermbg=8 guifg=#AAAAAA
hi Cursor         guifg=bg guibg=fg
hi CursorIM       ctermfg=15 ctermbg=12 guifg=#FFFFFF guibg=#8000ff
hi CursorColumn   term=reverse ctermbg=7 guibg=#E5E5E5
hi CursorLine     term=underline cterm=underline guibg=#E5E5E5
hi Directory      term=bold ctermfg=1 guifg=#0000FF
hi Bold           term=bold gui=bold
hi CursorLineNr   term=bold cterm=bold ctermfg=6 gui=bold guifg=#A52A2A
hi DiffAdd        term=bold ctermbg=9 guibg=#ADD8E6
hi DiffChange     term=bold ctermbg=13 guibg=#FF1E9B
hi DiffDelete     term=bold ctermfg=9 ctermbg=11 gui=bold guifg=#0000FF guibg=#E0FFFF
hi DiffText       term=reverse cterm=bold ctermbg=12 gui=bold guibg=#FF0000
hi link EndOfBuffer    NonText
hi ErrorMsg       term=standout ctermfg=15 ctermbg=4 guifg=#FFFFFF guibg=#FF0000
hi FoldColumn     term=standout ctermfg=1 ctermbg=7 guifg=#00008B guibg=#BEBEBE
hi Folded         term=standout ctermfg=1 ctermbg=7 guifg=#00008B guibg=#D3D3D3
hi IncSearch      term=reverse cterm=reverse gui=reverse
hi LineNr         term=bold ctermfg=6 guifg=#E08989 guibg=#FAF4F0
" hi LineNrAbove    cleared
" hi LineNrBelow    cleared
hi MatchParen     term=reverse ctermbg=11 guibg=#00FFFF
hi ModeMsg        term=bold cterm=bold gui=bold
hi MoreMsg        term=bold ctermfg=2 gui=bold guifg=#2E8B57
hi NonText        term=bold ctermfg=9 gui=bold guifg=#BEBEBE
hi Normal         guifg=#000000 guibg=#FAFAFA
hi NormalNC       guifg=#cccccc guibg=#dddddd
hi Pmenu          ctermfg=0 ctermbg=13 guibg=#ADD8E6
hi PmenuSbar      ctermbg=7 guibg=#BEBEBE
hi PmenuSel       ctermfg=15 ctermbg=1 guifg=#FFFFFF guibg=#00008B
hi PmenuThumb     ctermbg=0 guibg=#000000
hi Question       term=standout ctermfg=2 gui=bold guifg=#2E8B57
hi link QuickFixLine   Search
hi Search         term=reverse ctermbg=14 guibg=#FFFF00
hi SignColumn     term=standout ctermfg=1 ctermbg=7 guifg=#00008B guibg=#BEBEBE
hi SpecialKey     term=bold ctermfg=7 guifg=#cccccc
hi SpellBad       term=reverse ctermbg=12 gui=undercurl guisp=#FF0000
hi SpellCap       term=reverse ctermbg=9 gui=undercurl guisp=#0000FF
hi SpellLocal     term=underline ctermbg=11 gui=undercurl guisp=#008B8B
hi SpellRare      term=reverse ctermbg=13 gui=undercurl guisp=#FF00FF
hi StatusLine     term=bold,reverse cterm=bold ctermfg=14 ctermbg=9 gui=bold,reverse guifg=#0000FF guibg=#FFD700
hi TabLine        term=bold cterm=bold ctermfg=0 ctermbg=7 gui=underline guibg=#D3D3D3
hi TabLineFill    term=reverse cterm=reverse gui=reverse
hi TabLineSel     term=bold cterm=bold gui=bold
hi Title          term=bold ctermfg=5 gui=bold guifg=#FF00FF
hi ToolbarButton  cterm=bold ctermfg=15 ctermbg=8 gui=bold guifg=#FFFFFF guibg=#666666
hi ToolbarLine    term=bold ctermbg=7 guibg=#D3D3D3
hi link TrailingSpace  NonText
hi VertSplit      term=reverse cterm=reverse gui=reverse
hi Visual         term=reverse cterm=reverse gui=reverse guifg=#FFFD99 guibg=fg
hi VisualNOS      term=bold,underline cterm=bold,underline gui=bold,underline
hi WarningMsg     term=standout ctermfg=4 guifg=#FF0000
hi WildMenu       term=standout ctermfg=0 ctermbg=14 guifg=#000000 guibg=#FFFF00
hi lCursor        guibg=#00FFFF

