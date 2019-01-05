" vim:ft=vim
syntax clear markdownLineStart
syntax match markdownLineStart /^\%(\s*\S\)\@=/ nextgroup=@markdownBlock,htmlSpecialChar skipwhite display

syntax clear markdownCodeBlock
syntax cluster markdownBlock remove=markdownCodeBlock

"" 4.5 Fenced code blocks
syntax region markdownCode matchgroup=rawHtmlTag start=/<pre[^>]*>/  end=/<\/pre>/  contains=markdownBlockquoteNest,markdownCodeHtml
syntax region markdownCode matchgroup=rawHtmlTag start=/<code[^>]*>/ end=/<\/code>/ contains=markdownBlockquoteNest,markdownCodeHtml

syntax region markdownCode start=/\z(`\{3,}\)\%(\s*[^`]\+$\)\?/  end=/\z1`*\s*$/  keepend
syntax region markdownCode start=/\z(\~\{3,}\)\%(\s*[^~]\+$\)\?/ end=/\z1\~*\s*$/ keepend

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
call s:EmphasisAndStrongStar('Bold ', 2)
call s:EmphasisAndStrongStar('BoldItalic ', 3)

call s:EmphasisAndStrongUnderline('Italic', 1)
call s:EmphasisAndStrongUnderline('Bold ', 2)
call s:EmphasisAndStrongUnderline('BoldItalic ', 3)


"" Github Flaver
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" fenced code block
syntax region markdownCode matchgroup=markdownCodeDelimiter start=/\z(`\{3,}\)\%(\s*[^`]\+$\)\?/  end=/\z1`*\s*$/  keepend
syntax region markdownCode matchgroup=markdownCodeDelimiter start=/\z(\~\{3,}\)\%(\s*[^~]\+$\)\?/ end=/\z1\~*\s*$/ keepend

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

