" vim:set sw=2:
" Vim syntax file
if exists("b:current_syntax")
  finish
endif


""""""""""""""""""""""""""""""""""""""""""""
" configure
syn sync minlines=20 maxlines=50
syn case ignore


""""""""""""""""""""""""""""""""""""""""""""
"" 4 Leaf blocks
syntax cluster maarkdownInline contains=markdownEscape
syntax cluster markdownBlock   contains=@markdownInline

if &expandtab
  syntax match markdownBlockStart /^ */  nextgroup=@markdownBlock display
else
  syntax match markdownBlockStart /^\%( \{,3}\|\t*\)/  nextgroup=@markdownBlock display
endif


"" 4.1 Thematic breaks
syn match markdownThematicBreak /\%(\*\+\s*\)\{3,}$/ contained
syn match markdownThematicBreak /\%(_\+\s*\)\{3,}$/  contained
syn match markdownThematicBreak /\%(-\+\s*\)\{3,}$/  contained

"
syn cluster markdownBlock add=markdownThematicBreak

"
hi def link markdownThematicBreak Operator


"" 4.2 ATX headings
syn region markdownHeader matchgroup=markdownAtx start=/#\{1,6}\s\@=/ end=/#*\s*$/ contains=@markdownInline keepend transparent oneline contained

"
syn cluster markdownBlock add=markdownHeader

"
hi def link markdownAtx PreProc


"" 4.3 Setext headings
syn match markdownHeader /^ \{,3}[^\-\*_=>[:space:]].\+\n\s\{,3}\%(-\|=\)\+\s*$/ transparent contains=@markdownInline,markdownSetext

"
syn match markdownSetext /[=-]\+/ contained

"
hi def link markdownSetext PreProc


"" 4.4 Indented code blocks
if &expandtab
  syn match markdownCodeBlock /\t\zs.*/ contained
else
  syn match markdownCodeBlock /\(    \)\zs.*/ contained
endif

"
syn cluster markdownBlock add=markdownCodeBlock

"
hi def link markdownCodeBlock String


"" 4.5 Fenced code blocks
syn region markdownFencedCodeBlock matchgroup=Delimiter start=/\z(`\{3,}\)\%(\.\?\w\+\|\s\?{[^}]\+}\)\?/  end=/\z1`*\s*$/  keepend contained
syn region markdownFencedCodeBlock matchgroup=Delimiter start=/\z(\~\{3,}\)\%(\.\?\w\+\|\s\?{[^}]\+}\)\?/ end=/\z1\~*\s*$/ keepend contained

"
syn cluster markdownBlock add=markdownFencedCodeBlock

"
syn sync match markdownFencedCodeBlockSync grouphere markdownFencedCodeBlock "[`\~]\{3,}" 


"" 4.6 HTML blocks
"" 4.7 Link reference definitions
syn region markdownLinkLabel matchgroup=markdownLink start=/\[[^\][:space:]]\@=/ skip=/\[\S.{}\]\|\\[\[\]]/ end=/\]/ nextgroup=markdownLinkColon,markdownLinkReference,markdownLinkUrl oneline contains=markdownImageLabel,xmlTag

syn match markdownLinkColon  /:/ nextgroup=markdownLinkDest skipnl skipwhite contained

"
hi def link markdownLinkLabel  Underlined
hi def link markdownLinkColon  Typedef


"" 4.8 Paragraphs
"" 4.9 Blank lines
"" 4.10 Tables (extension)
syntax match markdownTable /|\ze\%(\s\|$\)/
syntax match markdownTable /|[: ]-\+[: ]\?\s*/

"
syntax cluster markdownBlock  add=markdownTable

"
hi def link markdownTable  Statement


"" 5 Container blocks
"" 5.1 Block quotes
syn match markdownBlockquote /\%(>\s\{}\)\+/ contained

"
syn cluster markdownBlock add=markdownBlockquote

"
hi def link markdownBlockquote  Comment


"" 5.2 List items
"" 5.4 Lists
syntax match markdownListMarker /\d\{1,9}[.)]\%(\s\+\)\@=/ contained nextgroup=@markdownBlock,@markdownInline 
syntax match markdownListMarker /\([-+*]\)\s\+\%(\1\|[[:space:]]\)\@!/ contained nextgroup=markdownTaskTodo,markdownTaskDone,@markdownBlock,@markdownInline

"
syn cluster markdownBlock add=markdownListMarker

"
hi def link markdownListMarker  Tag


"" 5.3 Task list items (extension)
syntax match markdownTaskTodo /\[ \]/    contained nextgroup=@markdownBlock,@markdownInline
syntax match markdownTaskDone /\[x\] .*/ contained

"
hi def link markdownTaskTodo Statement
hi def link markdownTaskDone SpecialKey


"" 6 Inlines
"" 6.1 Backslash escapes
syntax match markdownEscape /\\[\]\[\\`*_{}()#+.!\-]/ contained

"
hi def link markdownEscape Warning


"" 6.2 Entity and numeric character references
"" 6.3 Code spans
syntax region markdownCodeSpan start=/\%(\_^\|[^\\`]\)\@<=`\%([^`]\|\_$\)/  skip=/`\{2,}/ end=/`/ oneline
syntax region markdownCodeSpan start=/\%(\_^\|[^\\`]\)\@<=``\%([^`]\|\_$\)/ skip=/`\{3,}/ end=/``/ oneline

"
hi def link markdownCodeSpan  String


"" 6.4 Emphasis and strong emphasis
" [:punct:] - '*' - '_'
function! s:EmphasisAndStrongStar(name, count) "{{{
  let punct = '!"#$%&' . "'" . '()+,-.\/:;<=>?@\[\\\]^`{|}~'
  let ast = repeat('\*', a:count)
  execute 'syn region markdown' . a:name . ' start=/' . join([
      \   '^' . ast . '[^[:space:]*]\@=',
      \   '\%(\\\*\|[^*]\)\@<=' . ast . '[^[:space:]\u00A0[:punct:]]\@=',
      \   '[[:space:]\u00A0' . punct . '_]\@<=' . ast . '[' . punct . '_]\@='
      \ ], '\|') .
      \ '/ end=/' . join([
      \   '[' . punct . '_]\@<=' . ast . '\%($\|[[:space:]\u00A0' . punct . '_]\)\@=', 
      \   '[^[:space:]\u00A0[:punct:]]\@<=' . ast . '\%($\|[^*]\)\@='
      \ ], '\|') .
      \ '/ keepend oneline contains=markdownEmphasis,markdownStrong,markdownStrongEmphasis'
endfunction "}}}

function! s:EmphasisAndStrongUnderline(name, count) "{{{
  let punct = '!"#$%&' . "'" . '()+,-.\/:;<=>?@\[\\\]^`{|}~'
  let udl = repeat('_', a:count)
  execute 'syn region markdown' . a:name . ' start=/' . join([
      \   '^' . udl . '[^[:space:]\u00A0_]\@=',
      \   '[' . punct . '*]\@<=' . udl . '[^[:space:]\u00A0[:punct:]_]\@=',
      \   '[[:space:]\u00A0' . punct . '*]\@<=' . udl . '[' . punct . '*]\@='
      \ ], '\|') .
      \ '/ end=/' . join([
      \   '[^[:space:]\u00A0_]\@<=' . udl . '$',
      \   '[' . punct . '*]\@<=' . udl . '$',
      \   '[^[:space:]\u00A0[:punct:]_]\@<=' . udl . '[' . punct . '*]\@=',
      \   '[' . punct . '*]\@<=' . udl . '[[:space:]\u00A0' . punct . '*]\@='
      \ ], '\|') .
      \ '/ keepend oneline contains=markdownEmphasis,markdownStrong,markdownStrongEmphasis'

endfunction "}}}

call s:EmphasisAndStrongStar('Emphasis', 1)
call s:EmphasisAndStrongStar('Strong', 2)
call s:EmphasisAndStrongStar('StrongEmphasis', 3)

call s:EmphasisAndStrongUnderline('Emphasis', 1)
call s:EmphasisAndStrongUnderline('Strong', 2)
call s:EmphasisAndStrongUnderline('StrongEmphasis', 3)

"
if has('gui_running')
  hi def markdownEmphasis  gui=undercurl
  hi def markdownStrong  gui=bold
  hi def markdownStrongEmphasis  gui=standout
else
  hi def markdownEmphasis  term=underline cterm=underline
  hi def markdownStrong  term=bold cterm=bold
  hi def markdownStrongEmphasis  term=bold,underline cterm=bold,underline
endif


"" 6.5 Strikethrough (extension)
syntax region markdownStrikeThrough start="\%(\_^\|[^\\\~]\)\@<=\~\{2}\%([^\~]\|\_$\)" end="\~\{2}" oneline

"
if has('gui_running')
  hi def markdownStrikeThrough  gui=strikethrough guifg=#999999
else
  hi def link markdownStrikeThrough  SpecialKey
endif


"" 6.6 Links
syn region markdownLinkDest start=/<[^>[:space:]]\@=/ skip=/\\[<>]/ end=/>/ nextgroup=markdownLinkTitle skipnl skipwhite oneline contained
syn match  markdownLinkDest /[^<[:space:]]\S*/ nextgroup=markdownLinkTitle skipnl skipwhite oneline contained

syn region markdownLinkTitle start=/"/ skip=/\\"/ end=/"/ oneline contained
syn region markdownLinkTitle start=/'/ skip=/\\'/ end=/'/ oneline contained
syn region markdownLinkTitle start=/(/ skip=/(\S.{})\|\\[()]/ end=/)/ oneline contained

syn region markdownLinkReference matchgroup=markdownLink start=/\[/ skip=/\[.{}\]\|\\[\[\]]/ end=/\]/ oneline contained

"
hi def link markdownLinkDest  SpecialKey
hi def link markdownLinkTitle  String
hi def link markdownLinkReference SpecialKey

hi def link markdownLink  Typedef


"" 6.7 Images
syn region markdownImageLabel matchgroup=markdownImage start=/!\[/ end=/\][(\[]\@=/ nextgroup=markdownLinkUrl,markdownLinkReference oneline

syn region markdownLinkUrl matchgroup=markdownLink start=/(/ skip=/(\S.{})\|\\[()]/ end=/)/  contained contains=markdownLinkDest oneline


"
hi def link markdownImage Tag
hi def link markdownImageLabel Underlined
hi def link markdownLinkUrl  SpecialKey


"" 6.8 Autolinks
" www
syn match markdownAutoLink /<www\.[^[:cntrl:][:space:]<>]\+>/
" uri
syn match markdownAutoLink /<\a[[:alnum:]+-.]\{1,31}:[^[:cntrl:][:space:]<>]\+>/
" mail
syn match markdownAutoLink /<[[:alnum:].!#$%&'*+\/=?^_`{|}~-]\+@\a\%([[:alnum:]]\{0,61}[[:alnum:]]\)\?\%(\.[[:alnum:]]\%([[:alnum:]-]\{0,61}[[:alnum:]]\)\?\)*>/
" file
syn match markdownAutoLink /<file:\/\/\%(\/[A-Z]:\)\?[^[:cntrl:][:space:]<>]\+>/

"
hi def link markdownAutoLink Underlined


"" 6.9 Autolinks (extension)
" www
syn match markdownAutoLinkEx /\%(^\|[[:space:](]\)\@<=www\.[^[:cntrl:][:space:]<>]\+\%([[:space:];<]\|$\)\@=/
" http/https
syn match markdownAutoLinkEx /\%(^\|[[:space:](]\)\@<=[[:alpha:]][[:alnum:].\-_+]\+@[[:alnum:].-_]\+\%(\.[[:alnum:].-_]\+\)*[[:alnum:]]\%([[:space:];<.]\|$\)\@=/
" mail
syn match markdownAutoLinkEx /\%(^\|[[:space:](]\)\@<=https\?:[^[:cntrl:][:space:]<>]\+\%([[[:space:];<]\|$\)\@=/

"
hi def link markdownAutoLinkEx Underlined


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
hi def link markdownLineBreak  EndOfBuffer


"" 6.13 Soft line breaks
"" 6.14 Textual content


""""""""""""""""""""""""""""""""""""""""""""
"" Issue reference within a repository
syn match markdownIssueRef /\%(^\|\s\)\@<=#\d\+\%(\s\|$\)\@=/
syn match markdownIssueRef /\%(^\|\s\)\@<=\w[[:alnum:]-_]\+\%(\/[[:alnum:]-_]\+\)*#\d\+\%(\s\|$\)\@=/

"
hi def link markdownIssueRef Tag


"" Username @mentions
syn match markdownMentions /\%(^\|\s\)\@<=@[[:alnum:]-_]\+\%(\s\|$\)\@=/

"
hi def link markdownMentions Identifier

"" Emoji
syn match markdownEmoji /\%(^\|\s\)\@<=:\a\w\+\a:\%(\s\|$\)\@=/

"
hi def link markdownEmoji Constant


""""""""""""""""""""""""""""""""""""""""""""
let b:current_syntax = "markdown"
