" vim:ft=vim
if !get(g:, 'vim_markdown_extra_syntax_enable', 0)
  finish
endif

""" Markdown Extra
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Definition Lists
syntax match markdownExDefList /\%(\_^\s*[^[:space:]#:\t\-+*].*\n\)\+\_^\s*:\ze\s/ contained nextgroup=@markdownInline skipwhite
syntax match markdownExDefList /:\ze\s/ contained nextgroup=@markdownInline,@markdownBlock skipwhite

syntax cluster markdownBlock add=markdownExDefList

"" Annotation
syntax match markdownExNoteLabel /\[\^\w\+\]/
syntax match markdownExNote      /\[\^\w\+\]: .*/ contained

syntax cluster markdownInline add=markdownExNoteLabel
syntax cluster markdownBlock  add=markdownExNote

"" Headers with ID
" include `Headers`
syntax match markdownExHeaderID /{#\S\+}/ containedin=@markdownHeader contained

"" Tables
syntax match markdownExTable /|[: ]-\+[: ]\?\s*/
syntax match markdownExTable /|\ze\%(\s\|$\)/

syntax cluster markdownBlock  add=markdownExTable

"" Footnotes
syntax region markdownExFootNotes start=/\[^/ end=/\]/
syntax region markdownExFootNote  start=/\[^/ end=/\]/

"" highlight
hi def link markdownExDefList    Statement
hi def link markdownExNote       String
hi def link markdownExFootNotes  Type
hi def link markdownExFootNote   Comment
hi def link markdownExHeaderID   Comment
hi def link markdownExTable      Statement
