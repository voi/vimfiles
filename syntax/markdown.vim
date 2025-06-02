" vim:set sw=2:
" Vim syn file
if exists("b:current_syntax")
  finish
endif


""""""""""""""""""""""""""""""""""""""""""""
" configure
syn sync minlines=20 maxlines=50
syn case ignore


""""""""""""""""""""""""""""""""""""""""""""
"" 4 Leaf blocks
syn cluster maarkdownInline    contains=markdownEscape
syn cluster markdownBlock      contains=@markdownInline

if &expandtab
  syn match markdownBlockStart /^ */  nextgroup=markdownThematicBreak,@markdownBlock display
else
  syn match markdownBlockStart /^\%( \{1,3}\|\t*\)/  nextgroup=markdownThematicBreak,@markdownBlock display
endif


"" 4.1 Thematic breaks
syn match markdownThematicBreak /\*\{3,}\s*$/ contained
syn match markdownThematicBreak /_\{3,}\s*$/  contained
syn match markdownThematicBreak /-\{3,}\s*$/  contained

syn match markdownThematicBreak /\%(\s\+\*\+\)\{3,}$/ contained
syn match markdownThematicBreak /\%(\s\+_\+\)\{3,}$/  contained
syn match markdownThematicBreak /\%(\s\+-\+\)\{3,}$/  contained

"
hi link markdownThematicBreak Operator


"" 4.2 ATX headings
syn region markdownHeader matchgroup=markdownAtx start=/#\{1,6}\s\@=/ end=/#*\s*$/ keepend transparent oneline contained

"
syn cluster markdownBlock add=markdownHeader

"
hi link markdownAtx PreProc


"" 4.3 Setext headings
syn match markdownHeader /^ \{,3}[^\-\*_=>[:space:]].\+\n\s\{,3}\%(-\|=\)\+\s*$/ transparent contains=markdownSetext

"
syn match markdownSetext /[=-]\+/ contained

"
hi link markdownSetext PreProc


"" 4.4 Indented code blocks
if &expandtab
  syn match markdownCodeBlock /\t.*/ contained
else
  syn match markdownCodeBlock /\%(    \).*/ contained
  syn match markdownCodeBlock /^\%(    \).*/
endif

"
syn cluster markdownBlock add=markdownCodeBlock

"
hi link markdownCodeBlock String


"" 4.5 Fenced code blocks
syn region markdownFencedCodeBlock matchgroup=Delimiter start=/\z(`\{3,}\)\%(\.\?\w\+\|\s\?{[^}]\+}\)\?/  end=/\z1`*\s*$/  keepend contained
syn region markdownFencedCodeBlock matchgroup=Delimiter start=/\z(\~\{3,}\)\%(\.\?\w\+\|\s\?{[^}]\+}\)\?/ end=/\z1\~*\s*$/ keepend contained

"
syn cluster markdownBlock add=markdownFencedCodeBlock

"
syn sync match markdownFencedCodeBlockSync grouphere markdownFencedCodeBlock "[`\~]\{3,}" 


"" 4.6 HTML blocks
"" 4.7 Link reference definitions
syn region markdownLinkText matchgroup=markdownLink start=/\[[^\][:space:]]\@=/ skip=/\[\S.{}\]\|\\[\[\]]/ end=/\]/ nextgroup=markdownLinkColon,markdownLinkReference,markdownLinkUrl oneline contains=markdownImageLabel,xmlTag

syn match markdownLinkColon  /:/ nextgroup=markdownLinkDest skipnl skipwhite contained

"
hi link markdownLinkText  Underlined
hi link markdownLinkColon  Typedef


"" 4.8 Paragraphs
"" 4.9 Blank lines
"" 4.10 Tables (extension)
syn match markdownTable /\%(\S.*\s\)|\%(.*\s|\)*\%(.*\)\?/ transparent contains=markdownTableBorder
syn match markdownTableBorder /\%(^\|\s\)\@<=|\ze\%(\s\|$\)/ contained
syn match markdownTableBorder /:\?-\+:\?/ contained

"
syn cluster markdownBlock  add=markdownTable

"
hi link markdownTableBorder  Statement


"" x.x Latex blocks (extension)
syn region markdownLatexBlock matchgroup=Delimiter start=/\z(\$\{2}\)\%(\.\?\w\+\|\s\?{[^}]\+}\)\?/  end=/\z1\s*$/  keepend contained

"
syn cluster markdownBlock add=markdownLatexBlock

"
syn sync match markdownLatexBlockSync grouphere markdownLatexBlock "[`\$]\{2}" 


"" 5 Container blocks
"" 5.1 Block quotes
syn match markdownBlockquote />\%(\%(\t\| \{0,3}\)>\)*/ contained nextgroup=markdownThematicBreak,@markdownBlock

"
syn cluster markdownBlock add=markdownBlockquote

"
hi link markdownBlockquote  Directory


"" 5.2 List items
"" 5.4 Lists
syn match markdownListMarker /\d\{1,9}[.)]\%(\s\)\@=/ contained nextgroup=@markdownBlock,markdownThematicBreak
syn match markdownListMarker /\([-+*]\)\s\1\@!/ contained nextgroup=markdownTaskTodo,markdownTaskDone,@markdownBlock,markdownThematicBreak

"
syn cluster markdownBlock add=markdownListMarker

"
hi link markdownListMarker  Tag


"" 5.3 Task list items (extension)
syn match markdownTaskTodo /\[ \]/    contained nextgroup=@markdownBlock
syn match markdownTaskDone /\[x\] .*/ contained

"
hi link markdownTaskTodo Statement

if has('gui_running')
  hi markdownTaskDone  gui=strikethrough guifg=#999999
else
  hi link markdownTaskDone  SpecialKey
endif


"" 6 Inlines
"" 6.1 Backslash escapes
syn match markdownEscape /\\[\]\[\\`*_{}()#+.!\-]/ contained

"
hi link markdownEscape Warning


"" 6.2 Entity and numeric character references
"" 6.3 Code spans
syn region markdownCodeSpan start=/\%(\_^\|[^\\`]\)\@<=`\%([^`]\|\_$\)/  skip=/`\{2,}/ end=/`/ oneline
syn region markdownCodeSpan start=/\%(\_^\|[^\\`]\)\@<=``\%([^`]\|\_$\)/ skip=/`\{3,}/ end=/``/ oneline

"
hi link markdownCodeSpan  String


"" 6.4 Emphasis and strong emphasis
" [:punct:] - '*' - '_'
let s:markdownStrongEmphasisContains=join([
    \ 'markdownEmphasis', 'markdownStrong', 'markdownStrongEmphasis',
    \ 'markdownCodeSpan', 'markdownStrikeThrough'],
    \ ',')

function! s:EmphasisAndStrong(name, count) "{{{
  let punct = '!"#$%&' . "'" . '()+,-.\/:;<=>?@\[\\\]^`{|}~'
  " asterisk
  let ast = repeat('\*', a:count)
  let beg = join([
      \   printf('^%s[^[:space:]*]\@=', ast),
      \   printf('\%(\\\*\|[^*]\)\@<=%s[^[:space:]\u00A0[:punct:]]\@=', ast),
      \   printf('[[:space:]\u00A0%s_]\@<=%s[%s_]\@=', punct, ast, punct)
      \ ], '\|')
  let end = join([
      \   printf('[%s_]\@<=%s\%($\|[[:space:]\u00A0%s_]\)\@=', punct, ast, punct), 
      \   printf('[^[:space:]\u00A0[:punct:]]\@<=%s\%($\|[^*]\)\@=', ast)
      \ ], '\|')
  execute printf('syn region markdown%s start=/%s/ end=/%s/ keepend contains=%s',
      \ a:name, beg, end, s:markdownStrongEmphasisContains)
  " underscore
  let udl = repeat('_', a:count)
  let beg = join([
      \   printf('^%s[^[:space:]\u00A0_]\@=', udl),
      \   printf('[%s*]\@<=%s[^[:space:]\u00A0[:punct:]_]\@=', punct, udl),
      \   printf('[[:space:]\u00A0%s*]\@<=%s[%s*]\@=', punct, udl, punct)
      \ ], '\|')
  let end = join([
      \   printf('[^[:space:]\u00A0_]\@<=%s$', udl),
      \   printf('[%s*]\@<=%s$', punct, udl),
      \   printf('[^[:space:]\u00A0[:punct:]_]\@<=%s[%s*]\@=', udl, punct),
      \   printf('[%s*]\@<=%s[[:space:]\u00A0%s*]\@=', punct, udl, punct)
      \ ], '\|')
  execute printf('syn region markdown%s start=/%s/ end=/%s/ keepend contains=%s',
      \ a:name, beg, end, s:markdownStrongEmphasisContains)
endfunction "}}}

call s:EmphasisAndStrong('Emphasis', 1)
call s:EmphasisAndStrong('Strong', 2)
call s:EmphasisAndStrong('StrongEmphasis', 3)

"
if has('gui_running')
  hi markdownEmphasis  gui=undercurl
  hi markdownStrong  gui=bold
  hi markdownStrongEmphasis  gui=standout
else
  hi markdownEmphasis  term=underline cterm=underline
  hi markdownStrong  term=bold cterm=bold
  hi markdownStrongEmphasis  term=bold,underline cterm=bold,underline
endif


"" 6.5 Strikethrough (extension)
syn region markdownStrikeThrough start="\%(\_^\|[^\\\~]\)\@<=\~\{2}\%([^\~]\|\_$\)" end="\~\{2}" oneline

"
hi link markdownStrikeThrough markdownTaskDone


"" x.x Latex (extension)
syn region markdownLatex start=/\%(\_^\|[^\\\$]\)\@<=\$\%([^`]\|\_$\)/  skip=/\$\{2,}/ end=/\$/ oneline

"
hi link markdownLatex String


"" 6.6 Links
syn region markdownLinkDest start=/<[^>[:space:]]\@=/ skip=/\\[<>]/ end=/>/ nextgroup=markdownLinkTitle skipnl skipwhite oneline contained
" syn match  markdownLinkDest /<[^<>]*>/ nextgroup=markdownLinkTitle skipnl skipwhite contained

syn region markdownLinkTitle start=/"/ skip=/\\"/ end=/"/ oneline contained
syn region markdownLinkTitle start=/'/ skip=/\\'/ end=/'/ oneline contained
syn region markdownLinkTitle start=/(/ skip=/(\S.{})\|\\[()]/ end=/)/ oneline contained

syn region markdownLinkReference matchgroup=markdownLink start=/\[/ skip=/\[.{}\]\|\\[\[\]]/ end=/\]/ oneline contained

"
hi link markdownLinkDest  SpecialKey
hi link markdownLinkTitle  String
hi link markdownLinkReference SpecialKey

hi link markdownLink  Typedef


"" 6.7 Images
syn region markdownImageLabel matchgroup=markdownImage start=/!\[/ end=/\][(\[]\@=/ nextgroup=markdownLinkUrl,markdownLinkReference oneline

syn region markdownLinkUrl matchgroup=markdownLink start=/(/ skip=/\\[()]/ end=/)/  contained contains=markdownLinkDest oneline


"
hi link markdownImage Tag
hi link markdownImageLabel Underlined
hi link markdownLinkUrl  SpecialKey


"" 6.8 Autolinks
" www
syn match markdownAutoLink /<www\.[^[:cntrl:][:space:]<>]\+>/
" uri
syn match markdownAutoLink /<\a[[:alnum:]+-.]\{1,31}:[^[:cntrl:][:space:]<>]\+>/
" mail
syn match markdownAutoLink /<[[:alnum:].!#$%&'*+\/=?^_`{|}~-]\+@\a\%([[:alnum:]]\{0,61}[[:alnum:]]\)\?\%(\.[[:alnum:]]\%([[:alnum:]-]\{0,61}[[:alnum:]]\)\?\)*>/
" file
syn match markdownAutoLink /<file:\/\/\%(\/[A-Z]:\)\?[^>]\+>/

"
hi link markdownAutoLink Underlined


"" 6.9 Autolinks (extension)
" www
syn match markdownAutoLinkEx /\%(^\|[[:space:](]\)\@<=www\.[^[:cntrl:][:space:]<>]\+\%([[:space:];<]\|$\)\@=/
" http/https
syn match markdownAutoLinkEx /\%(^\|[[:space:](]\)\@<=[[:alpha:]][[:alnum:].\-_+]\+@[[:alnum:].-_]\+\%(\.[[:alnum:].-_]\+\)*[[:alnum:]]\%([[:space:];<.]\|$\)\@=/
" mail
syn match markdownAutoLinkEx /\%(^\|[[:space:](]\)\@<=https\?:[^[:cntrl:][:space:]<>]\+\%([[[:space:];<]\|$\)\@=/

"
hi link markdownAutoLinkEx Underlined


"" 6.10 Raw HTML
runtime! syntax/xml.vim

"
syn clear xmlTag
syn region xmlTag matchgroup=xmlTag start=/<\%([^ \/!?<>"'@+=]\+[[:space:]>]\)\@=/ matchgroup=xmlTag end=/>/ contains=xmlError,xmlTagName,xmlAttrib,xmlEqual,xmlString,@xmlStartTagHook

syn clear xmlEndTag
syn region xmlEndTag matchgroup=xmlTag start=/<\/\%([^ \/!?<>"'@+=]\+[[:space:]>]\)\@=/ matchgroup=xmlTag end=/>/ contains=xmlTagName,xmlNamespace,xmlAttribPunct,@xmlTagHook

syn clear xmlError


"" 6.11 Disallowed Raw HTML (extension)
"" 6.12 Hard line breaks
syn match markdownLineBreak /  $/ containedin=ALL

"
hi link markdownLineBreak  EndOfBuffer


"" 6.13 Soft line breaks
"" 6.14 Textual content


""""""""""""""""""""""""""""""""""""""""""""
"" Issue reference within a repository
syn match markdownIssueRef /\%(^\|\s\)\@<=#\d\+\%(\s\|$\)\@=/
syn match markdownIssueRef /\%(^\|\s\)\@<=\w[[:alnum:]-_]\+\%(\/[[:alnum:]-_]\+\)*#\d\+\%(\s\|$\)\@=/

"
hi link markdownIssueRef Tag


"" Username @mentions
syn match markdownMentions /\%(^\|\s\)\@<=@[[:alnum:]-_]\+\%(\s\|$\)\@=/

"
hi link markdownMentions Identifier

"" Emoji
syn match markdownEmoji /\%(^\|\s\)\@<=:\a\w\+\a:\%(\s\|$\)\@=/

"
hi link markdownEmoji Constant


""""""""""""""""""""""""""""""""""""""""""""
let b:current_syntax = "markdown"
