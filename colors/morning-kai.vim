" vim:ft=vim
set background=light
hi clear | syntax reset
let g:colors_name="morning-kai"


" -------------------------------------------------------------
""""
hi      Comment   term=bold ctermfg=1 guifg=#AAAAAA
hi      Constant  term=bold ctermfg=4 guifg=#ff6699
hi      String    term=bold ctermfg=4 guifg=#FF9E8C
hi link Character Constant
hi      Number    term=bold ctermfg=4 guifg=#3333ff
hi      Boolean   term=bold ctermfg=4 guifg=#000066
hi link Float     Number

""""
hi Identifier  term=bold ctermfg=3 guifg=#008B8B
hi Function    term=bold ctermfg=3 gui=bold guifg=#00AFAF

""""
hi      Statement      term=bold cterm=bold ctermfg=6 guifg=#A52A2A
hi link Conditional    Statement
hi link Repeat         Statement
hi link Label          Statement
hi      Operator       term=bold cterm=bold ctermfg=6 gui=bold guifg=#B90B50
hi      Keyword        term=bold cterm=bold ctermfg=6 guifg=#F0435A
hi link Exception      Statement

""""
hi      PreProc        term=underline ctermfg=5 guifg=#6a0dad
hi link Include        PreProc
hi link Define         PreProc
hi link Macro          PreProc
hi link PreCondit      PreProc

""""
hi Type           term=bold ctermfg=2 gui=bold guifg=#2E8B57
hi StorageClass   term=bold ctermfg=2 gui=bold guifg=#064B28
hi Structure      term=bold ctermfg=2 guifg=#00A37E
hi Typedef        term=bold ctermfg=2 guifg=#33cc33

""""
hi      Special        term=bold ctermfg=5 guifg=#C573B2
hi link SpecialChar    Special
hi      Tag            term=bold ctermfg=5 gui=bold guifg=#990066
hi      Delimiter      term=bold ctermfg=5 gui=bold guifg=#7C4B8D
hi link SpecialComment Special
hi link Debug          Special

""""
hi Underlined     term=underline cterm=underline ctermfg=5 gui=underline guifg=#6A5ACD

""""
hi Ignore         ctermfg=7 guifg=#E5E5E5

""""
hi Error          term=reverse ctermfg=15 ctermbg=12 guifg=#FFFFFF guibg=#FF0000

""""
hi Todo           term=standout ctermfg=0 ctermbg=14 guifg=#0000FF guibg=#FFFF00

""""
hi ColorColumn    term=reverse ctermbg=12 guibg=#FF0101
hi Conceal        ctermfg=7 ctermbg=8 guifg=#AAAAAA
hi Cursor         guibg=#00FF00
hi CursorIM       ctermfg=15 ctermbg=12 guifg=#FFFFFF guibg=#8000ff
hi CursorColumn   term=reverse ctermbg=7 guibg=#CCCCCC
hi CursorLine     term=underline cterm=underline guibg=#CCCCCC
hi Directory      term=bold ctermfg=1 guifg=#0000FF
hi Bold           gui=bold
hi CursorLineNr   term=bold cterm=underline ctermfg=6 gui=bold guifg=#CA5137
hi DiffAdd        term=bold ctermbg=9 guibg=#ADD8E6
hi DiffChange     term=bold ctermbg=13 guibg=#FF1E9B
hi DiffDelete     term=bold ctermfg=9 ctermbg=11 gui=bold guifg=#0000FF guibg=#E0FFFF
hi DiffText       term=reverse cterm=bold ctermbg=12 gui=bold guibg=#FF0000
hi link EndOfBuffer    NonText
hi ErrorMsg       term=standout ctermfg=15 ctermbg=4 guifg=#FFFFFF guibg=#FF0000
hi FoldColumn     term=standout ctermfg=1 ctermbg=7 guifg=#00008B guibg=#BEBEBE
hi Folded         term=standout ctermfg=1 ctermbg=7 guifg=#00008B guibg=#D3D3D3
hi IncSearch      term=reverse cterm=reverse gui=reverse
hi LineNr         term=underline ctermfg=6 guifg=#D38967 guibg=#DCEFEF
" hi LineNrAbove    cleared
" hi LineNrBelow    cleared
hi MatchParen     term=reverse ctermbg=11 guibg=#00FFFF
hi ModeMsg        term=bold cterm=bold gui=bold
hi MoreMsg        term=bold ctermfg=2 gui=bold guifg=#2E8B57
hi NonText        term=bold ctermfg=9 gui=bold guifg=#0000FF guibg=#CCCCCC
hi Normal         ctermfg=0 ctermbg=7 guifg=#000000 guibg=#F5F5F5
hi NormalNC       guifg=#cccccc guibg=#dddddd
hi Pmenu          ctermfg=0 ctermbg=13 guibg=#FF1E9B
hi PmenuSbar      ctermbg=7 guibg=#BEBEBE
hi PmenuSel       ctermfg=0 ctermbg=7 guibg=#BEBEBE
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
hi StatusLine     term=bold,reverse cterm=bold,reverse gui=bold,reverse
hi TabLine        term=underline cterm=underline ctermfg=0 ctermbg=7 gui=underline guibg=#D3D3D3
hi TabLineFill    term=reverse cterm=reverse gui=reverse
hi TabLineSel     term=bold cterm=bold gui=bold
hi Title          term=bold ctermfg=5 gui=bold guifg=#FF00FF
hi ToolbarButton  cterm=bold ctermfg=15 ctermbg=8 gui=bold guifg=#FFFFFF guibg=#666666
hi ToolbarLine    term=underline ctermbg=7 guibg=#D3D3D3
hi link TrailingSpace  NonText
hi VertSplit      term=reverse cterm=reverse gui=reverse
hi Visual         term=reverse ctermbg=7 guibg=#FFFD99
hi VisualNOS      term=bold,underline cterm=bold,underline gui=bold,underline
hi WarningMsg     term=standout ctermfg=4 guifg=#FF0000
hi WildMenu       term=standout ctermfg=0 ctermbg=14 guifg=#000000 guibg=#FFFF00
hi lCursor        guibg=#00FFFF

