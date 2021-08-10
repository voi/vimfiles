" vim:ft=vim
set background=dark
hi clear | syntax reset
let g:colors_name="darkblue-kai"



" -------------------------------------------------------------
""""
hi      Comment       term=bold ctermfg=4 guifg=#5970B3
hi      Constant      term=bold ctermfg=13 guifg=#FF5454
hi      String        term=bold ctermfg=4 guifg=#ffa0a0
hi link Character     String
hi      Number        term=bold ctermfg=4 guifg=#FF6B6B
hi      Boolean       term=bold ctermfg=4 guifg=#D10000
hi link Float         Number

""""
hi Identifier         term=bold ctermfg=11 guifg=#61DFDF
hi Function           term=bold ctermfg=11 guifg=#28CCCC

""""
hi      Statement     term=bold ctermfg=14 guifg=#60ff60
hi link Conditional   Statement
hi link Repeat        Statement
hi link Label         Statement
hi      Operator      term=bold ctermfg=14 gui=bold guifg=#93FF93
hi      Keyword       term=bold ctermfg=14 guifg=#00FF00
hi link Exception     Keyword

""""
hi      PreProc       term=underline ctermfg=13 guifg=#ff80ff
hi link Include       PreProc
hi link Define        PreProc
hi link Macro         PreProc
hi link PreCondit     PreProc

""""
hi      Type          term=bold ctermfg=10 guifg=#ffff60
hi      StorageClass  term=bold ctermfg=10 guifg=#C6C600
hi      Structure     term=bold ctermfg=10 guifg=#F9F900
hi      Typedef       term=bold ctermfg=10 guifg=#939300

""""
hi      Special        term=bold ctermfg=6 guifg=#FFA500
hi link SpecialChar    Special
hi      Tag            term=bold ctermfg=6 guifg=#CC8100
hi      Delimiter      term=bold ctermfg=6 guifg=#FFC965
hi link SpecialComment Special
hi link Debug          Special

""""
hi Underlined    term=underline cterm=underline ctermfg=9 gui=underline guifg=#80a0ff

""""
hi Ignore        ctermfg=0 guifg=bg

""""
hi Error         term=reverse ctermfg=15 ctermbg=12 guifg=#FFFFFF guibg=#FF0000

""""
hi Todo          term=standout ctermfg=12 ctermbg=1 gui=bold guifg=#FF0000 guibg=#FFFF00


" -------------------------------------------------------------
hi ColorColumn   term=reverse ctermbg=4 guibg=#8B0000
hi Conceal       ctermfg=7 ctermbg=8 guifg=#AAAAAA
hi Cursor        ctermfg=0 ctermbg=14 guifg=#000000 guibg=#FFFF00
hi CursorIM      ctermfg=15 ctermbg=12 guifg=#FFFFFF guibg=#8000ff
hi CursorColumn  term=reverse ctermbg=8 guibg=#666666
hi CursorLine    term=underline cterm=underline guibg=#444444
hi Directory     term=bold ctermfg=11 guifg=#00FFFF
hi Bold          gui=bold
hi CursorLineNr  term=bold cterm=underline ctermfg=14 gui=bold guifg=#FFFF00
hi DiffAdd       ctermbg=1 guibg=#00008B
hi DiffChange    term=bold ctermbg=13 guibg=#8B008B
hi DiffDelete    term=bold ctermfg=9 ctermbg=11 gui=bold guifg=#0000FF guibg=#008B8B
hi DiffText      term=reverse cterm=bold ctermbg=12 gui=bold guibg=#FF0000
hi link EndOfBuffer   NonText
hi ErrorMsg      term=standout ctermfg=15 ctermbg=9 guifg=#ffffff guibg=#287eff
hi FoldColumn    term=bold cterm=bold ctermfg=8 ctermbg=0 guifg=#808080 guibg=#000040
hi Folded        term=bold cterm=bold ctermfg=8 ctermbg=0 guifg=#808080 guibg=#000040
hi IncSearch     term=reverse cterm=reverse ctermfg=1 ctermbg=7 gui=reverse guifg=#b0ffff guibg=#2050d0
hi LineNr        term=underline ctermfg=10 guifg=#569013 guibg=#000020
" hi LineNrAbove   cleared
" hi LineNrBelow   cleared
hi MatchParen    term=reverse ctermbg=3 guibg=#008B8B
hi ModeMsg       term=bold cterm=bold ctermfg=9 gui=bold guifg=#22cce2
hi MoreMsg       term=bold ctermfg=2 gui=bold guifg=#2E8B57
hi NonText       term=bold ctermfg=1 gui=bold guifg=#0030ff
hi Normal        ctermfg=7 ctermbg=0 guifg=#FFFFFF guibg=#000040
hi NormalNC      guifg=#808080 guibg=#606060
hi Pmenu         ctermfg=0 ctermbg=13 guifg=#c0c0c0 guibg=#404080
hi PmenuSel      ctermfg=8 ctermbg=0 guifg=#c0c0c0 guibg=#2050d0
hi PmenuSbar     ctermbg=7 guifg=#0000FF guibg=#A9A9A9
hi PmenuThumb    ctermbg=15 guifg=#c0c0c0 guibg=#FFFFFF
hi Question      term=standout ctermfg=10 guifg=#00FF00
hi link QuickFixLine  Search
hi Search        term=underline cterm=underline ctermfg=15 ctermbg=1 guifg=#90fff0 guibg=#2050d0
hi SignColumn    term=standout ctermfg=11 ctermbg=8 guifg=#00FFFF guibg=#BEBEBE
hi SpecialKey    term=bold ctermfg=7 guifg=#808080
hi SpellBad      term=reverse ctermbg=12 gui=undercurl guisp=#FF0000
hi SpellCap      term=reverse ctermbg=9 gui=undercurl guisp=#0000FF
hi SpellRare     term=reverse ctermbg=13 gui=undercurl guisp=#FF00FF
hi SpellLocal    term=underline ctermbg=11 gui=undercurl guisp=#00FFFF
hi StatusLine    ctermfg=9 ctermbg=7 guifg=#0000FF guibg=#A9A9A9
hi StatusLineNC  ctermfg=0 ctermbg=7 guifg=#000000 guibg=#A9A9A9
hi StatusLineTerm term=bold,reverse cterm=bold ctermfg=0 ctermbg=10 gui=bold guifg=bg guibg=#90EE90
hi StatusLineTermNC term=reverse ctermfg=0 ctermbg=10 guifg=bg guibg=#90EE90
hi TabLine       term=underline cterm=underline ctermfg=15 ctermbg=8 gui=underline guibg=#A9A9A9
hi TabLineFill   term=reverse cterm=reverse gui=reverse
hi TabLineSel    term=bold cterm=bold gui=bold
hi Title         term=bold cterm=bold ctermfg=13 guifg=#FF00FF
hi ToolbarButton cterm=bold ctermfg=0 ctermbg=7 gui=bold guifg=#000000 guibg=#D3D3D3
hi ToolbarLine   term=underline ctermbg=8 guibg=#7F7F7F
hi VertSplit     ctermfg=0 ctermbg=7 guifg=#000000 guibg=#A9A9A9
hi Visual        term=reverse cterm=reverse ctermfg=9 ctermbg=7 gui=reverse guifg=#8080ff guibg=fg
hi VisualNOS     term=bold,underline cterm=underline,reverse ctermfg=9 ctermbg=7 gui=underline,reverse guifg=#8080ff guibg=fg
hi WarningMsg    term=standout ctermfg=12 guifg=#FF0000
hi WildMenu      ctermfg=14 ctermbg=0 guifg=#FFFF00 guibg=#000000
hi lCursor       ctermfg=0 ctermbg=15 guifg=#000000 guibg=#FFFFFF

