" vim:ft=vim
set background=light
hi clear | syntax reset
let g:colors_name="suika"


" -------------------------------------------------------------
""""
hi       Comment      guifg=#646C60 guibg=#E5E7E4 gui=NONE
hi       Constant     guifg=#006199 guibg=#CCECFF gui=NONE
hi! link String       Constant
hi! link Charactor    Constant
hi       Number       guifg=#0086F7 guibg=#CCE8FF gui=NONE
hi! link Boolean      Number
hi! link Float        Number

""""
hi       Identifier   guifg=#FF0086 guibg=#FFCCE7 gui=NONE
" hi     Function

""""
hi       Statement    guifg=#FB660A guibg=#FEE0CD gui=NONE
hi! link Conditional  Statement
hi! link Repeat       Statement
" hi     Label
hi       Operator     guifg=#FB660A guibg=NONE    gui=NONE
" hi     Keyword
hi! link Exception    Statement

""""
hi       PreProc      guifg=#FF0007 guibg=#FFCCCE gui=NONE
" hi     Include
" hi     Define
" hi     Macro
" hi     PreCondit

""""
hi       Type         guifg=#1A8118 guibg=#C0F3BF gui=NONE
" hi     StrageClass
" hi     Structure
" hi     Typedef

""""
hi       Special      guifg=#FD8900 guibg=#FFE7CC gui=NONE
" hi     SpecialChar
" hi     Tag
" hi     Delimiter
" hi     SpecialComment
" hi     Debug

""""
hi       Underline                                gui=Underline

""""
hi! link Ignore       Special

""""
hi       Error        guifg=#FFFFFF guibg=#D40000 gui=NONE

""""
hi! link Todo         Error


" -------------------------------------------------------------
hi       ColorColumn  guifg=NONE    guibg=#FFCC99 gui=NONE
hi! link Conceal      Comment
hi       Cursor       guifg=#FFFFFF guibg=#FF0000 gui=NONE 
hi       CursorIM     guifg=#FFFFFF guibg=#8000ff gui=NONE
hi! link CursorColumn Cursor
hi       CursorLine                 guibg=NONE    gui=Underline 
hi! link Directory    Identifier
hi       DiffAdd      guifg=NONE    guibg=#CCE7FD gui=NONE
hi       DiffChange   guifg=NONE    guibg=#FFCCE7 gui=NONE
hi! link DiffDelete   Comment
hi       DiffText     guifg=#0086F7 guibg=#99D1FF gui=NONE
" hi     EndOfBuffer
hi       ErrorMsg     guifg=#FFFFFF guibg=#FF0007 gui=NONE
hi       VertSplit    guifg=#3687A2 guibg=#3687A2 gui=NONE
hi       Folded       guifg=#3C78A2 guibg=#B5D0E3 gui=NONE
hi! link FoldColumn   Folded
hi       SignColumn   guifg=NONE    guibg=NONE    gui=NONE
hi       IncSearch    guifg=NONE    guibg=NONE    gui=INVERSE
hi       LineNr       guifg=#438EC3 guibg=#FFFFC6 gui=bold
hi       CursorLineNr guifg=#FFFFC6 guibg=#438EC3 gui=bold
hi       MatchParen   guifg=#001217 guibg=#B1FF00 gui=NONE
hi       ModeMsg      guifg=#FFFFFF guibg=#1B5C8A gui=NONE
hi! link MoreMsg      ModeMsg
hi       NonText      guifg=#438EC3 guibg=NONE    gui=NONE
hi       Normal       guifg=#001217 guibg=#FFFFFF gui=NONE
hi       Pmenu        guifg=#001217 guibg=#EFADA9 gui=NONE
hi! link PmenuSel     WildMenu
hi! link PmenuSbar    PmenuSel
hi       PmenuThumb   guifg=NONE    guibg=#0086D2 gui=NONE
hi! link Question     ModeMsg
hi! link Search       WildMenu
hi       SpecialKey   guifg=#B1D0E7 guibg=NONE    gui=NONE
hi       SpecialKey   guifg=#9EC5E0 guibg=NONE    gui=NONE
hi       SpellBad     guifg=#FF0007 guibg=NONE    gui=UNDERCURL, guisp=#FF0007
hi! link SpellCap     SpellBad
hi! link SpellLocal   SpellBad
hi! link SpellRare    SpellBad
hi       StatusLine   guifg=#FFFFFF guibg=#43C464 gui=NONE
hi       StatusLineNC guifg=#9BD4A9 guibg=#51B069 gui=NONE
hi! link TabLine      LineNr
hi! link TabLineFill  LineNr
hi! link TabLineSel   StatusLine
hi! link Title        Normal
hi       Visual       guifg=#FFFFFF guibg=#3399FF gui=NONE
hi! link VisualNOS    Visual
hi! link WarningMsg   ErrorMsg
hi       WildMenu     guifg=#FFFFFF guibg=#FD8900 gui=NONE

