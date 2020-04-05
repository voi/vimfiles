" vim:ft=vim
if !get(g:, 'vim_markdown_github_flaver_syntax_enable', 0)
  finish
endif

"" Github Flaver
"" <https://github.com/jtratner/vim-flavored-markdown.git>
"" syntax
" URL
syntax region markdownLinkUrl start="\(https\?:\|ftp:\|^\|[^:]\@<=\)\/\/" end="\()\|}\|]\|,\|\"\|\'\| \|$\|\. \|\.$\)\@="
syntax region markdownLinkUrl start="\(^\| \|(\|=\)\([-.[:alnum:]_~+]\+@\)\@=" end="\()\|}\|]\|,\|\"\|\'\| \|$\|\. \|\.$\)\@="

" delete line
syntax region markdownDelete start="\%(\_^\|[^\\\~]\)\@<=\~\{2}\%([^\~]\|\_$\)" end="\~\{2}" oneline

syntax cluster markdownInline add=markdownDelete

" todo list
syntax match markdownListTodo /\[ \]/    contained
syntax match markdownListDone /\[x\] .*/ contained

syntax cluster markdownListNext add=markdownListTodo
syntax cluster markdownListNext add=markdownListDone

" reference
syntax match markdownReference /#\@<!#[[:alnum:]-_]\+/

" mentions
syntax match markdownMentions /@[^[:space:](]\+\%(([^)]\+)\)\?/

"" highlight
hi def link markdownDelete   SpecialKey
hi def link markdownListTodo Statement
hi def link markdownListDone SpecialKey

hi def link markdownReference Tag
hi def link markdownMentions  PreProc
