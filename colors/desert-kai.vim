" vim:ft=vim
set background=dark
hi clear | syntax reset
let g:colors_name="desert-kai"



" -------------------------------------------------------------
""""
hi      Comment       term=bold guifg=#A0A0A0
hi      Constant      term=bold guifg=#CD3278
hi      String        term=bold guifg=#ffa0a0
hi link Character     String
hi      Number        term=bold guifg=#EE82EE
hi      Boolean       term=bold guifg=#FF3E96
hi link Float         Number

""""
hi      Identifier    term=bold cterm=bold guifg=#98FB98
hi link Function      Identifier

""""
hi      Statement     term=bold gui=bold guifg=#F0E68C
hi link Conditional   Statement
hi link Repeat        Statement
hi link Label         Statement
hi      Operator      term=bold gui=bold guifg=#FFFF00
hi link Keyword       Statement
hi link Exception     Statement

""""
hi      PreProc       term=bold guifg=#CD5C5C
hi link Include       PreProc
hi link Define        PreProc
hi link Macro         PreProc
hi link PreCondit     PreProc

""""
hi      Type           term=bold cterm=bold guifg=#87CEFA
hi      StorageClass   term=bold cterm=bold guifg=#63B8FF
hi link Structure      StorageClass
hi link Typedef        Type

""""
hi      Special        term=bold guifg=#FFDEAD
hi link SpecialChar    Special
hi      Tag            term=bold guifg=#FFA54F
hi      Delimiter      term=bold guifg=#CD853F
hi link SpecialComment Special
hi link Debug          Special

""""
hi Underlined     term=underline cterm=underline gui=underline guifg=#80a0ff

""""
hi Ignore         cterm=bold guifg=#444444

""""
hi Error          term=reverse cterm=bold guifg=#FFFFFF guibg=#FF0000

""""
hi Todo           term=standout guifg=#FF4500 guibg=#EEEE00


" -------------------------------------------------------------
hi ColorColumn    term=reverse guibg=#666666
hi Conceal        guifg=#AAAAAA
hi Cursor         guifg=#708090 guibg=#FFD700
hi CursorIM       guifg=#FFFFFF guibg=#8000ff
hi CursorColumn   term=reverse guibg=#666666
hi CursorLine     term=underline cterm=underline guibg=#666666
hi Directory      term=bold guifg=#00FFFF
hi Bold           gui=bold
hi CursorLineNr   term=bold cterm=bold gui=bold guibg=#D0D66C guifg=#333333
hi DiffAdd        term=bold guibg=#00008B
hi DiffChange     term=bold guibg=#8B008B
hi DiffDelete     term=bold cterm=bold gui=bold guifg=#0000FF
hi DiffText       term=reverse cterm=bold gui=bold guibg=#FF0000
hi link EndOfBuffer    NonText
hi ErrorMsg       term=standout cterm=bold guifg=#FFFFFF guibg=#FF0000
hi FoldColumn     term=standout guifg=#D2B48C guibg=#4D4D4D
hi Folded         term=standout guifg=#FFD700 guibg=#4D4D4D
hi IncSearch      term=reverse gui=reverse guifg=#708090 guibg=#F0E68C
hi LineNr         term=bold guifg=#A0A0A0 guibg=#222222
" hi LineNrAbove    cleared
" hi LineNrBelow    cleared
hi MatchParen     term=reverse guibg=#008B8B
hi ModeMsg        term=bold gui=bold guifg=#DAA520
hi MoreMsg        term=bold gui=bold guifg=#2E8B57
hi NonText        term=bold cterm=bold gui=bold guifg=#ADD8E6 guibg=#4D4D4D
hi Normal         guifg=#FFFFFF guibg=#333333
hi NormalNC       guifg=#808080 guibg=#606060
hi Pmenu          guibg=#7A378B
hi PmenuSbar      guibg=#AB82FF
hi PmenuSel       guibg=#E066FF
hi PmenuThumb     guibg=#FFFFFF
hi Question       term=standout gui=bold guifg=#00FF7F
hi link QuickFixLine   Search
hi Search         term=reverse guifg=#F5DEB3 guibg=#CD853F
hi SignColumn     term=standout guifg=#00FFFF guibg=#BEBEBE
hi SpecialKey     term=bold guifg=#808080
hi SpellBad       term=reverse gui=undercurl guisp=#FF0000
hi SpellCap       term=reverse gui=undercurl guisp=#0000FF
hi SpellLocal     term=underline gui=undercurl guisp=#00FFFF
hi SpellRare      term=reverse gui=undercurl guisp=#FF00FF
hi StatusLine     term=bold,reverse cterm=bold,reverse guifg=#000000 guibg=#c2bfa5
hi TabLine        term=bold cterm=bold gui=underline guibg=#A9A9A9
hi TabLineFill    term=reverse cterm=reverse gui=reverse
hi TabLineSel     term=bold cterm=bold gui=bold
hi Title          term=bold gui=bold guifg=#CD5C5C
hi ToolbarButton  cterm=bold gui=bold guifg=#000000 guibg=#D3D3D3
hi ToolbarLine    term=bold guibg=#7F7F7F
hi link TrailingSpace  NonText
hi VertSplit      term=reverse cterm=reverse guifg=#7F7F7F guibg=#c2bfa5
hi Visual         term=reverse cterm=reverse guifg=#F0E68C guibg=#6B8E23
hi VisualNOS      term=bold,underline cterm=bold,underline gui=bold,underline
hi WarningMsg     term=standout guifg=#FA8072
hi WildMenu       term=standout guifg=#000000 guibg=#FFFF00
hi lCursor        guifg=bg guibg=fg
