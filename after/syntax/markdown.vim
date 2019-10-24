" vim:ft=vim
syntax clear markdownLineStart
syntax match markdownLineStart /^\%(\s*\S\)\@=/
    \ nextgroup=@markdownBlock,@markdownInline,htmlSpecialChar skipwhite display

"" 4.2 ATX headers
syn clear markdownH1
syn clear markdownH2
syn clear markdownH3
syn clear markdownH4
syn clear markdownH5
syn clear markdownH6

syntax match markdownH1 /#\%(\s.*\)\?$/      contained contains=@markdownInline
syntax match markdownH2 /##\%(\s.*\)\?$/     contained contains=@markdownInline
syntax match markdownH3 /###\%(\s.*\)\?$/    contained contains=@markdownInline
syntax match markdownH4 /####\%(\s.*\)\?$/   contained contains=@markdownInline
syntax match markdownH5 /#####\%(\s.*\)\?$/  contained contains=@markdownInline
syntax match markdownH6 /######\%(\s.*\)\?$/ contained contains=@markdownInline

"" 4.3 Setext headers
syntax match markdownH1 /^\s\{,3}[^[:space:]\->+*].\+\n\s\{,3}=\+\s*$/
syntax match markdownH2 /^\s\{,3}[^[:space:]\->+*].\+\n\s\{,3}-\+\s*$/

"" 4.5 Fenced code blocks
syntax region markdownFencedCodeBlock matchgroup=markdownCodeDelimiter
    \ start=/\z(`\{3,}\)\%(\.\?\w\+\|\s\?{[^}]\+}\)\?/  end=/\z1`*\s*$/  transparent keepend
syntax region markdownFencedCodeBlock matchgroup=markdownCodeDelimiter
    \ start=/\z(\~\{3,}\)\%(\.\?\w\+\|\s\?{[^}]\+}\)\?/ end=/\z1\~*\s*$/ transparent keepend

"" Code Block
syntax clear markdownCodeBlock
" syntax cluster markdownBlock remove=markdownCodeBlock

if &expandtab
  syntax match markdownCodeBlock /\t\zs.*/
else
  syntax match markdownCodeBlock /\(    \)\zs.*/
endif

"" 5.2 List items
syntax cluster markdownListNext contains=@markdownHeader,markdownCode,markdownBlockquote,markdownRule

syntax clear markdownListMarker
syntax clear markdownOrderedListMarker

syntax match markdownListMarker /[-+*]\s*$/ contained
syntax match markdownListMarker /\([-+*]\)\s\+\%(\1\|[[:space:]]\)\@!/ 
    \ contained nextgroup=@markdownListNext,@markdownInline skipwhite

syntax match markdownOrderedListMarker /\d\{1,9}[.)]\s*$/ contained
syntax match markdownOrderedListMarker /\d\{1,9}[.)]\%(\s\+\)\@=/ 
    \ contained nextgroup=@markdownListNext,@markdownInline skipwhite

"" 6.4 Emphasis and strong emphasis
function! s:EmphasisAndStrongStar(name, count) "{{{
  execute 'syntax region markdown'. a:name .
        \ ' start=/\%(\_^\|[^\\\*]\)\@<=\*\{' . a:count . '}\%([^[:space:][:punct:]]\)\@=/' .
        \ ' end=/[^[:space:][:punct:]]\@<=\*\{' . a:count . '}\%($\|[^\\\*]\)\@=/' .
        \ ' keepend oneline'
endfunction "}}}

function! s:EmphasisAndStrongUnderline(name, count) "{{{
  execute 'syntax region markdown'. a:name .
        \ ' start=/\%(\_^\|[[:space:][:punct:]]\)\@<=_\{' . a:count . '}\%([^[:space:][:punct:]]\)\@=/' .
        \ ' end=/[^[:space:][:punct:]]\@<=_\{' . a:count . '}\%($\|[[:space:][:punct:]]\)\@=/' .
        \ ' keepend oneline'
  execute 'syntax region markdown'. a:name .
        \ ' start=/[[:punct:]]\@<=_\{' . a:count . '}[[:punct:]]\@=/' .
        \ ' end=/[[:punct:]]\@<=_\{' . a:count . '}\>/' .
        \ ' keepend oneline'
endfunction "}}}

syntax clear markdownItalic
syntax clear markdownBold 
syntax clear markdownBoldItalic 
syntax clear markdownError

call s:EmphasisAndStrongStar('Italic', 1)
call s:EmphasisAndStrongStar('Bold', 2)
call s:EmphasisAndStrongStar('BoldItalic', 3)

call s:EmphasisAndStrongUnderline('Italic', 1)
call s:EmphasisAndStrongUnderline('Bold', 2)
call s:EmphasisAndStrongUnderline('BoldItalic', 3)


"" Github Flaver
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Tables
" syntax match markdownExTable /\%(|[: ]-\+[: ]\s*\)\+/
syntax match markdownExTable /|[: ]-\+[: ]\?\s*/
syntax match markdownExTable /|\ze\s/

syntax cluster markdownBlock  add=markdownExTable

" delete line
syntax region markdownDelete start="\%(\~\)\@<!\~\{2}\%([\~[:space:]]\)\@!"
    \ end="\%([\~[:space:]]\)\@<!\~\{2}\%(\~\)\@!" oneline containedin=@markdownInline

" todo list
syntax match markdownListTodo /\[ \]/
syntax match markdownListDone /\[x\] .*/

syntax cluster markdownInline add=markdownListTodo
syntax cluster markdownInline add=markdownListDone

" reference
syntax match markdownReference /#\@<!#\d\+\>/
syntax match markdownReference /\<GH-\d\+\>/

" mentions
syntax match markdownMentions /@\w[[:alnum:]-]\+/

" emoji
syntax match markdownEmoji /:\w\+:/

"" Link refernce definitions/Annotation
syntax match markdownExNoteLabel /\[\^\w\+\]/
syntax match markdownExNote      /\[\^\w\+\]: .*/

syntax cluster markdownInline add=markdownExNoteLabel
syntax cluster markdownBlock  add=markdownExNote

"" Definition Lists
syntax match markdownExDefList /\%(\_^\s*[^[:space:]#:\t\-+*].*\n\)\+\_^\s*:\ze\s/ 
    \ contained nextgroup=@markdownInline skipwhite
syntax match markdownExDefList /:\ze\s/ contained nextgroup=@markdownInline,@markdownBlock skipwhite

syntax cluster markdownBlock add=markdownExDefList

"" Headers with ID
" include `Headers`
syntax match markdownExHeaderID /{#\S\+}/ containedin=@markdownHeader

"" Footnotes
syntax region markdownExFootNotes start=/\[\^/ end=/\]/
syntax region markdownExFootNote  start=/\[\^/ end=/\]/


"" highlight
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
hi def link markdownDelete   SpecialKey
hi def link markdownListTodo Statement
hi def link markdownListDone SpecialKey

hi def link markdownReference PreProc
hi def link markdownMentions  Tag
hi def link markdownEmoji     Statement

hi def link markdownExDefList    Statement
hi def link markdownExNote       String
hi def link markdownExFootNotes  Type
hi def link markdownExFootNote   Comment
hi def link markdownExHeaderID   Comment
hi def link markdownExTable      Statement

hi markdownUrl gui=underline

hi def link markdownCode      String
hi def link markdownCodeBlock String

hi markdownH1 gui=bold,underline
hi markdownH2 gui=bold,underline
hi markdownH3 gui=bold,underline
hi markdownH4 gui=bold,underline
hi markdownH5 gui=bold,underline
hi markdownH6 gui=bold,underline

