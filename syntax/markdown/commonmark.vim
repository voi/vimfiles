" vim:ft=vim
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

"" basic markdown syntax
syntax spell toplevel
syntax case ignore
syntax sync linebreaks=1

syntax cluster markdownHeader contains=markdownH1,markdownH2,markdownH3,markdownH4,markdownH5,markdownH6
syntax cluster markdownBlock  contains=@markdownHeader,markdownBlockquote,markdownListMarker,markdownRule,markdownCode,markdownFencedCode
syntax cluster markdownInline contains=markdownEmphasis,markdownStrong,markdownStrongEmphasis,markdownCodeSpan,markdownEscape

syntax match markdownLineStart /^\%(\s*\S\)\@=/ nextgroup=@markdownBlock skipwhite display

"" 4.6 HTML blocks
"" 6.8 Raw HTML
let b:base_syntax = get(g:, 'vim_markdown_base_syntax', '')

if b:base_syntax ==# 'html'
  if version < 600
    so <sfile>:p:h/html.vim
  else
    runtime! syntax/html.vim
  endif

  syntax clear htmlString
  syntax region htmlString contained start=/"/ skip=/\\"/ end=/"/ contains=htmlSpecialChar,javaScriptExpression,@htmlPreproc
  syntax region htmlString contained start=/'/ skip=/\\'/ end=/'/ contains=htmlSpecialChar,javaScriptExpression,@htmlPreproc

  hi def link rawHtmlTag htmlTag

elseif b:base_syntax ==# 'xml'
  if version < 600
    so <sfile>:p:h/xml.vim
  else
    runtime! syntax/xml.vim
  endif

  syntax clear xmlString
  syntax region xmlString contained start=/"/ skip=/\\"/ end=/"/ contains=xmlEntity,@Spell display
  syntax region xmlString contained start=/'/ skip=/\\'/ end=/'/ contains=xmlEntity,@Spell display

  hi def link htmlTag       Function
  hi def link htmlStatement Statement
  hi def link htmlTagName   htmlStatement
  hi def link htmlH1        Title
  hi def link htmlH2        htmlH1
  hi def link htmlH3        htmlH2
  hi def link htmlH4        htmlH3
  hi def link htmlH5        htmlH4
  hi def link htmlH6        htmlH5
  hi def link htmlLink      Underlined

  hi def link rawHtmlTag    xmlTag

  hi def htmlBold       term=bold cterm=bold gui=bold
  hi def htmlBoldItalic term=bold,italic cterm=bold,italic gui=bold,italic
  hi def htmlItalic     term=italic cterm=italic gui=italic
endif

""" 4 Leaf blocks
"" 4.1 Horizontal rules
syntax match markdownRule /\%(\*\+ *\)\{3,}$/ contained
syntax match markdownRule /\%(_\+ *\)\{3,}$/  contained
syntax match markdownRule /\%(-\+ *\)\{3,}$/  contained

"" 4.2 ATX headers
syntax match markdownH1 /#\%(\s.*\)\?$/      contained contains=@markdownInline
syntax match markdownH2 /##\%(\s.*\)\?$/     contained contains=@markdownInline
syntax match markdownH3 /###\%(\s.*\)\?$/    contained contains=@markdownInline
syntax match markdownH4 /####\%(\s.*\)\?$/   contained contains=@markdownInline
syntax match markdownH5 /#####\%(\s.*\)\?$/  contained contains=@markdownInline
syntax match markdownH6 /######\%(\s.*\)\?$/ contained contains=@markdownInline

"" 4.3 Setext headers
syntax match markdownH1 /^\s\{,3}[^[:space:]\->+*].\+\n\s\{,3}=\+\s*$/
syntax match markdownH2 /^\s\{,3}[^[:space:]\->+*].\+\n\s\{,3}-\+\s*$/

"" 4.4 Indented code blocks
" No syntax

"" 4.5 Fenced code blocks
syntax region markdownCodeHtml matchgroup=rawHtmlTag start=/<pre[^>]*>/  end=/<\/pre>/  contains=markdownBlockquoteNest,markdownCodeHtml
syntax region markdownCodeHtml matchgroup=rawHtmlTag start=/<code[^>]*>/ end=/<\/code>/ contains=markdownBlockquoteNest,markdownCodeHtml

syntax region markdownFencedCode start=/\z(`\{3,}\)\%(\s*[^`]\+$\)\?/  end=/\z1`*\s*$/  keepend
syntax region markdownFencedCode start=/\z(\~\{3,}\)\%(\s*[^~]\+$\)\?/ end=/\z1\~*\s*$/ keepend

"" 4.7 Link reference definitions
"" 6.5 Links
"" 6.6 Images
syntax region markdownLinkLabel start=/\%( \{,3}!\?\)\@<=\[/ skip=/\\[\[\]]/ end=/\]/ nextgroup=markdownLinkColon,markdownLink,markdownLinkText contains=markdownLinkLabel

syntax match markdownLinkColon  /:/ nextgroup=markdownLinkUrl skipnl skipwhite contained

syntax match markdownLinkUrl /<[^>]\+>/        nextgroup=markdownLinkTitle skipnl skipwhite contained
syntax match markdownLinkUrl /[^<[:space:]]\+/ nextgroup=markdownLinkTitle skipnl skipwhite contained

syntax region markdownLinkTitle start=/"/ skip=/\\"/ end=/"/ contained
syntax region markdownLinkTitle start=/'/ skip=/\\'/ end=/'/ contained
syntax region markdownLinkTitle start=/(/ skip=/\\)/ end=/)/ contained

syntax region markdownLinkText matchgroup=markdownLinkLabel start=/\[/ skip=/\\[\[\]]/ end=/\]/ contained
syntax region markdownLink     matchgroup=markdownLinkLabel start=/(/  skip=/\\[()]/   end=/)/  contained contains=markdownLinkUrl keepend oneline

"" 4.8 Paragraphs

"" 4.9 Blank lines

""" 5 Container blocks
"" 5.1 Block quotes
syntax match markdownBlockquote     />\ze\s*/ contained nextgroup=@markdownBlock,markdownRule,@markdownInline skipwhite
syntax match markdownBlockquoteNest /\_^\s*\zs>\ze\s*/ nextgroup=markdownBlockquoteLead skipwhite contained
syntax match markdownBlockquoteLead />\ze\s*/ contained

"" 5.2 List items
syntax cluster markdownListNext contains=@markdownHeader,markdownCode,markdownFencedCode,markdownBlockquote,markdownRule

syntax match markdownListMarker /\d\{1,9}[.)]\s*$/ contained
syntax match markdownListMarker /\d\{1,9}[.)]\%(\s\+\)\@=/ contained nextgroup=@markdownListNext,@markdownInline skipwhite

syntax match markdownListMarker /[-+*]\s*$/ contained
syntax match markdownListMarker /\([-+*]\)\s\+\%(\1\|[[:space:]]\)\@!/ contained nextgroup=@markdownListNext,@markdownInline skipwhite

""" 6 Inlines
"" 6.1 Backslash escapes
syntax match markdownEscape /\\[\]\[\\`*_{}()#+.!\-]/

"" 6.2 Entities

"" 6.3 Code spans
syntax region markdownCodeSpan start=/\%(\_^\|[^\\`]\)\@<=`\%([^`]\|\_$\)/  skip=/`\{2,}/ end=/`/ 
syntax region markdownCodeSpan start=/\%(\_^\|[^\\`]\)\@<=``\%([^`]\|\_$\)/ skip=/`\{3,}/ end=/``/

"" 6.4 Emphasis and strong emphasis
function! s:EmphasisAndStrongStar(name, count) "{{{
  execute 'syntax region markdown'. a:name .
        \ ' start=/\%(\_^\|[^[:punct:]]\)\@<=\*\{' . a:count . '}\%([^[:space:][:punct:]]\)\@=/' .
        \ ' end=/[^[:space:][:punct:]]\@<=\*\{' . a:count . '}\%($\|[^[:punct:]]\)\@=/' .
        \ ' keepend oneline'
endfunction "}}}

function! s:EmphasisAndStrongUnderline(name, count) "{{{
  execute 'syntax region markdown'. a:name .
        \ ' start=/\%(\_^\|[^[:punct:]]\)\@<=_\{' . a:count . '}\%([^[:space:][:punct:]]\)\@=/' .
        \ ' end=/[^[:space:][:punct:]]\@<=_\{' . a:count . '}\%($\|[^[:punct:]]\)\@=/' .
        \ ' keepend oneline'
endfunction "}}}

call s:EmphasisAndStrongStar('Emphasis', 1)
call s:EmphasisAndStrongStar('Strong', 2)
call s:EmphasisAndStrongStar('StrongEmphasis', 3)

call s:EmphasisAndStrongUnderline('Emphasis', 1)
call s:EmphasisAndStrongUnderline('Strong', 2)
call s:EmphasisAndStrongUnderline('StrongEmphasis', 3)

"" 6.7 Autolinks
syntax region markdownAutomaticLink matchgroup=markdownLinkLabel start=/<\%(\w\+:\|[[:alnum:]_+-]\+@\)\@=/ end=/>/ oneline

"" 6.9 Hard line breaks
syntax match mkdLineBreak /  $/ containedin=ALL

"" 6.10 Soft line breaks

"" 6.11 Textual content

"
hi def link markdownRule           PreProc

hi def link markdownH1             htmlH1
hi def link markdownH2             htmlH2
hi def link markdownH3             htmlH3
hi def link markdownH4             htmlH4
hi def link markdownH5             htmlH5
hi def link markdownH6             htmlH6

hi def link markdownCode           String
hi def link markdownCodeHtml       markdownCode
hi def link markdownCodeSpan       markdownCode
hi def link markdownFencedCode     markdownCode

hi def link markdownLinkLabel      Typedef
hi def link markdownLinkColon      markdownLinkLabel
hi def link markdownLink           markdownLinkLabel
hi def link markdownLinkUrl        htmlLink
hi def link markdownLinkTitle      String
hi def link markdownLinkText       htmlLink

hi def link markdownEscape         Special

hi def link markdownBlockquote     Comment
hi def link markdownBlockquoteLead Comment
hi def link markdownBlockquoteNest Comment

hi def link markdownListMarker     htmlTagName

hi def link markdownEmphasis       htmlItalic
hi def link markdownStrong         htmlBold
hi def link markdownStrongEmphasis htmlBoldItalic

hi def link markdownAutomaticLink  markdownLinkUrl

highlight markdownLinkUrl         gui=underline


"
let b:current_syntax = "markdown"
