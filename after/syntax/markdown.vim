" vim:ft=vim

syntax clear markdownCodeBlock
syntax cluster markdownBlock remove=markdownCodeBlock


"" Github Flaver
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" fenced code block
syntax region markdownCode matchgroup=markdownCodeDelimiter start=/\z(`\{3,}\)\%(\s*[^`]\+$\)\?/  end=/\z1`*\s*$/  containedin=@markdownBlock keepend
syntax region markdownCode matchgroup=markdownCodeDelimiter start=/\z(\~\{3,}\)\%(\s*[^~]\+$\)\?/ end=/\z1\~*\s*$/ containedin=@markdownBlock keepend

"" Tables
syntax match markdownExTable /|[: ]-\+[: ]\?\s*/   containedin=@markdownBlock
syntax match markdownExTable /|\ze\%(\s[^-:]\|$\)/ containedin=@markdownBlock

" delete line
syntax region markdownDelete start="\%(\_^\|[^\\\~]\)\@<=\~\{2}\%([^\~]\|\_$\)" end="\~\{2}" oneline containedin=@markdownInline

" todo list
syntax match markdownListTodo /\[ \]/    containedin=@markdownInline
syntax match markdownListDone /\[x\] .*/ containedin=@markdownInline

" reference
syntax match markdownReference /#\@<!#[[:alnum:]-_]\+/

" mentions
syntax match markdownMentions /@[^[:space:](]\+\%(([^)]\+)\)\?/




"" Link refernce definitions/Annotation
syntax match markdownExNoteLabel /\[\^\w\+\]/
syntax match markdownExNote      /\[\^\w\+\]: .*/

syntax cluster markdownInline add=markdownExNoteLabel
syntax cluster markdownBlock  add=markdownExNote

"" Definition Lists
syntax match markdownExDefList /\%(\_^\s*[^[:space:]#:\t\-+*].*\n\)\+\_^\s*:\ze\s/ contained nextgroup=@markdownInline skipwhite
syntax match markdownExDefList /:\ze\s/ contained nextgroup=@markdownInline,@markdownBlock skipwhite

syntax cluster markdownBlock add=markdownExDefList

"" Headers with ID
" include `Headers`
syntax match markdownExHeaderID /{#\S\+}/ containedin=@markdownHeader

"" Footnotes
syntax region markdownExFootNotes start=/\[^/ end=/\]/
syntax region markdownExFootNote  start=/\[^/ end=/\]/


"" highlight
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
hi def link markdownDelete   SpecialKey
hi def link markdownListTodo Statement
hi def link markdownListDone SpecialKey

hi def link markdownReference Tag
hi def link markdownMentions  PreProc

hi def link markdownExDefList    Statement
hi def link markdownExNote       String
hi def link markdownExFootNotes  Type
hi def link markdownExFootNote   Comment
hi def link markdownExHeaderID   Comment
hi def link markdownExTable      Statement

hi markdownUrl gui=underline

