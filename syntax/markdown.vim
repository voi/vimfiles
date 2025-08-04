vim9script

if exists("b:current_syntax")
  finish
endif


################################################################
syn sync minlines=50 maxlines=75
syn case ignore

var link_url_cchar = get(g:, 'markdown_link_url_conceal_char', '')


################################################################
# 3. Block and Inline {{{
if &expandtab
  syn match markdownBlockStart /^\%( \{4}\)*\%( \{1,3}\)\?/ 
        \ nextgroup=@markdownLeafBlock,@markdownContainerBlock,markdownFrontMatter display
else
  syn match markdownBlockStart /^\t*\%( \{1,3}\)\?/ 
        \ nextgroup=@markdownLeafBlock,@markdownContainerBlock,markdownFrontMatter display
endif

# }}}

################################################################
# 4. Leaf blocks {{{
syn cluster markdownLeafBlock contains=markdownThematicBreak,markdownHeader,markdownCodeBlock,markdownFencedCodeBlock,markdownLinkReferenceDefine


################################
#   4.1 Thematic breaks {{{
syn match markdownThematicBreak /\*\{3,}\s*$/ contained display
syn match markdownThematicBreak /_\{3,}\s*$/  contained display
syn match markdownThematicBreak /-\{3,}\s*$/  contained display

syn match markdownThematicBreak /\%(\s\+\*\+\)\{3,}$/ contained display
syn match markdownThematicBreak /\%(\s\+_\+\)\{3,}$/  contained display
syn match markdownThematicBreak /\%(\s\+-\+\)\{3,}$/  contained display

hi link markdownThematicBreak Operator
#   }}}


################################
#   4.2 ATX headings {{{
syn region markdownHeader matchgroup=markdownAtx 
      \ start=/#\{1,6}\s\@=/ end=/\%(\s\@<=#\+\)\?\s*$/ 
      \ keepend transparent oneline contained display

hi link markdownAtx PreProc
#   }}}


################################
#   4.3 Setext headings {{{
syn match markdownHeader /^ \{,3}[^\-\*_=>[:space:]].\+\n\s\{,3}\%(-\|=\)\+\s*$/ 
      \ contains=markdownSetext transparent contained display
syn match markdownSetext /[=-]\+/ contained

hi link markdownSetext PreProc
#   }}}


################################
#   4.4 Indented code blocks {{{
if &expandtab
  syn match markdownCodeBlock /\t.*/ contained display
else
  syn match markdownCodeBlock /\%(    \).*/ contained display
endif

hi link markdownCodeBlock Comment
#   }}}


################################
#   4.5 Fenced code blocks {{{
syn region markdownFencedCodeBlock matchgroup=Delimiter 
      \ start=/\z(`\{3,}\)\%(\.\?\w\+\|\s\?{[^}]\+}\)\?/  end=/\z1`*\s*$/ 
      \ keepend contained display
syn region markdownFencedCodeBlock matchgroup=Delimiter 
      \ start=/\z(\~\{3,}\)\%(\.\?\w\+\|\s\?{[^}]\+}\)\?/ end=/\z1\~*\s*$/ 
      \ keepend contained display

syn sync match markdownFencedCodeBlockMarker grouphere markdownFencedCodeBlock "[`\~]\{3,}" 

hi link markdownFencedCodeBlock Comment
#   }}}


################################
#   4.6 HTML blocks
#   4.7 Link reference definitions {{{
syn region markdownLinkReferenceDefine matchgroup=markdownLinkMarker start=/\[\s\@!/ skip=/\\[\[\]]/ end=/\s\@<!\]:/ 
      \ nextgroup=markdownLinkRefDefDest skipwhite oneline contained display

hi link markdownLinkReferenceDefine Tag
hi link markdownLinkMarker Statement

#
var link_ref_def_dest = 'nextgroup=markdownLinkTitle skipwhite contained display'

if !link_url_cchar->empty()
  link_ref_def_dest ..= ' conceal cchar=' .. link_url_cchar[0]
endif

execute 'syn region markdownLinkRefDefDest start=/</ skip=/\\[<>]/ end=/>/ oneline ' .. link_ref_def_dest
execute 'syn match markdownLinkRefDefDest /[^<>[:space:]]\+/ ' .. link_ref_def_dest

hi link markdownLinkRefDefDest Underlined

#
syn region markdownLinkTitle start=/\"/ skip=/\\\"/ end=/\"/ contained display

hi link markdownLinkTitle String
#   }}}


################################
#   4.8 Paragraphs
#   4.9 Blank lines
#   4.10 Tables (extension) {{{
syn cluster markdownLeafBlock add=markdownTable

syn match markdownTable /\%(\S.*\s\)\\\@<!|\%(.*\s|\)*\%(.*\)\?/ 
      \ transparent contains=markdownTableBorder,@markdownInline contained
syn match markdownTableBorder /\%(^\|\s\)\@<=|\ze\%(\s\|$\)/ contained
syn match markdownTableBorder /:\?-\+:\?/ contained

hi link markdownTableBorder Statement
#   }}}


################################
#   x.x Latex Block (extension) {{{
syn cluster markdownLeafBlock add=markdownLatexBlock

syn region markdownLatexBlock matchgroup=Delimiter
      \ start=/\z(\$\{2}\)\%(\.\?\w\+\|\s\?{[^}]\+}\)\?/  end=/\z1\s*$/ 
      \ keepend contained

syn sync match markdownLatexBlockMarker grouphere markdownLatexBlock "[`\$]\{2}" 
#   }}}

# }}}

################################################################
# 5 Container blocks {{{
syn cluster markdownContainerBlock 
      \ contains=markdownBlockquote,markdownListMarker

if &expandtab
  syn match markdownContainerBlockStart /\%( \{4}\)*\%( \{1,3}\)\?/ 
        \ nextgroup=@markdownLeafBlock,@markdownContainerBlock contained
else
  syn match markdownContainerBlockStart /\t*\%( \{1,3}\)\?/ 
        \ nextgroup=@markdownLeafBlock,@markdownContainerBlock contained
endif


################################
#   5.1 Block quotes {{{
syn match markdownBlockquote />/ nextgroup=markdownContainerBlockStart contained display

hi link markdownBlockquote Directory
#   }}}


################################
#   5.2 List items
#   5.4 Lists {{{
syn match markdownListMarker /\d\{1,9}[.)][[:space:]]\@=/ 
      \ display contained skipwhite nextgroup=markdownContainerBlockStart
syn match markdownListMarker /\([-+*]\)[[:space:]]\@=/ 
      \ display contained skipwhite nextgroup=markdownTaskTodo,markdownTaskDone,markdownContainerBlockStart

hi link markdownListMarker  Tag
#   }}}


################################
#   5.3 Task list items (extension) {{{
syn match markdownTaskTodo /\[ \]/    contained display
syn match markdownTaskDone /\[x\] .*/ contained display

#
hi link markdownTaskTodo Statement

if has('gui_running')
  hi markdownTaskDone  gui=strikethrough guifg=#999999
else
  hi link markdownTaskDone  SpecialKey
endif
#   }}}

# }}}

################################################################
# 6 Inlines {{{
syn cluster markdownInline contains=markdownEscape,markdownCodeSpan,markdownStrongEmphasis,markdownEmphasis,markdownStrongEmphasis,markdownLink,markdownImage,markdownAutoLink


################################
#   6.1 Backslash escapes {{{
syn match markdownEscape /\\[!"#$%&'()*+,\-./:;<=>?@\[\]^_`{|}~]/ display

hi link markdownEscape WarningMsg
#   }}}


################################
#   6.2 Entity and numeric character references
#   6.3 Code spans {{{
syn region markdownCodeSpan start=/\z([\\`]\@<!``\@!\)/  skip=/`\{2,}/ end=/\z1/ 
      \ oneline display
syn region markdownCodeSpan start=/\z([\\`]\@<!```\@!\)/ skip=/`\{3,}/ end=/\z1/ 
      \ oneline display

hi link markdownCodeSpan  String
#   }}}


################################
#   6.4 Emphasis and strong emphasis {{{
def Markdown_defineEmphasis(name: string, beg: string, end: string)
  execute printf('syn region markdown%s matchgroup=markdownStrongEmphasisMarker start=/%s/ end=/%s/ keepend display %s',
    name, beg, end, (get(g:, 'markdown_strong_emphasis_oneline', 0) ? 'oneline' : ''))
enddef

def LeftFlanking_Delimiter_Run(chr: string, count: number, punct: string, left: string): string
  var delim = repeat(chr, count)

  return join([
    # (1) and (2a)
    '[[:space:][:cntrl:]' .. punct .. chr .. left .. '\\]\@<!' 
          \ .. delim 
          \ .. '[[:space:][:cntrl:]' .. punct .. ']\@!',
    # (2b)
    '[[:space:][:cntrl:]' .. punct .. ']\@<=' 
          \ .. delim 
          \ .. '[[:space:][:cntrl:]]\@!'
  ], '\|')
enddef

def RightFlaking_Delimiter_Run(chr: string, count: number, punct: string, right: string): string
  var delim = repeat(chr, count)

  return join([
    # (1) and (2a)
    '[[:space:][:cntrl:]' .. punct .. chr .. '\\]\@<!' .. 
          \ delim .. 
          \ '[[:space:][:cntrl:]' .. punct .. chr .. right .. ']\@!',
    # (2b)
    '[[:space:][:cntrl:]\\]\@<!' 
          \ .. delim 
          \ .. '[[:space:][:cntrl:]' .. punct .. ']\@='
  ], '\|')
enddef

def Markdown_syntaxEmphasis(name: string, count: number)
  # asterisk
  var ast_punct = "'" .. '!"#$%&()+,\-./:;<=>?@\[\]^_`{|}~'
  var ast_left = LeftFlanking_Delimiter_Run('\*', count, ast_punct, '')
  var ast_right = RightFlaking_Delimiter_Run('\*', count, ast_punct, '')

  call Markdown_defineEmphasis(name, ast_left, ast_right)

  # underscore
  var udl_punct = "'" .. '!"#$%&()+,\-./:;<=>?@\[\]^*`{|}~'
  var udl_left = LeftFlanking_Delimiter_Run('_', count, udl_punct, '[:alnum:]\u2E00-\U3FFFF')
  var udl_right = RightFlaking_Delimiter_Run('_', count, udl_punct, '[:alnum:]\u2E00-\U3FFFF')

  call Markdown_defineEmphasis(name, udl_left, udl_right)
enddef

call Markdown_syntaxEmphasis('Emphasis', 1)
call Markdown_syntaxEmphasis('Strong', 2)
call Markdown_syntaxEmphasis('StrongEmphasis', 3)

#
if has('gui_running')
  hi markdownEmphasis  gui=italic
  hi markdownStrong  gui=bold
  hi markdownStrongEmphasis  gui=bold,italic
else
  hi markdownEmphasis  term=italic cterm=italic
  hi markdownStrong  term=bold,undercurl cterm=bold,undercurl
  hi markdownStrongEmphasis  term=bold,undercurl,italic cterm=bold,undercurl,italic
endif

hi link markdownStrongEmphasisMarker SpecialKey
#   }}}


################################
#   6.5 Strikethrough (extension) {{{
syn region markdownStrikeThrough start=/\z([\\\~]\@<!\~\{2}[\~]\@!\)/ skip=/\~\{3,}/ end=/\z1/ 
      \ containedin=@markdownInline contains=markdownConcealUrlInStrikeThrough oneline display

if !link_url_cchar->empty()
  var conceal_syntax = 'syn match markdownConcealUrlInStrikeThrough /%s/ conceal cchar=' .. link_url_cchar[0]

  execute printf(conceal_syntax, "\\<www\\.[^[:cntrl:][:space:]<>]\\+\\>")
  execute printf(conceal_syntax, "\\<[a-z]]\\{3,}:\\/\\/[\\w!?\\/+\\-_\\~;.,*&@#$%()'[\\]]+\\>")
  execute printf(conceal_syntax, "\\<[\\w\\-._]+@[\\w\\-._]+\\.[A-Za-z]+\\>")

  hi link markdownConcealUrlInStrikeThrough markdownTaskDone
endif

hi link markdownStrikeThrough markdownTaskDone
#   }}}


################################
#   x.x Latex Span (extension) {{{
syn region markdownLatexSpan start=/\z([\\\$]\@<!\$$\@!\)/ skip=/\$\{2,}/ end=/\z1/ 
      \ containedin=@markdownInline oneline display

hi link markdownLatexSpan String
#   }}}


################################
#   6.6 Links
#   6.7 Images {{{
syn region markdownLink matchgroup=markdownLinkMarker start=/\\\@<!\[\s\@!/ skip=/\\[\[\]]/ end=/\s\@<!\][(\[]\@=/ 
      \ nextgroup=markdownLinkDest,markdownLinkRef keepend oneline display

hi link markdownLink String

#
syn region markdownLinkDest matchgroup=markdownLinkMarker start=/(/ skip=/\\[()]/ end=/\\\@<!)/ 
      \ oneline contains=markdownLinkUrl transparent keepend contained display

#
syn region markdownLinkRef matchgroup=markdownLinkMarker start=/\[/ skip=/\\[\[\]]/ end=/\\\@<!\]/ 
      \ oneline contained display

hi link markdownLinkRef Tag

#
var link_dest = 'nextgroup=markdownLinkAltTitle skipwhite contained display'

if !link_url_cchar->empty()
  link_dest ..= ' conceal cchar=' .. link_url_cchar[0]
endif

execute 'syn region markdownLinkUrl start=/</ skip=/\\[<>]/ end=/>/ oneline ' .. link_dest
execute 'syn match markdownLinkUrl /[^<>[:space:]]\+/ ' .. link_dest

hi link markdownLinkUrl Underlined

#
syn region markdownLinkAltTitle start=/"/ skip=/\\"/ end=/"/ contained display conceal cchar="

hi link markdownLinkAltTitle String
#   }}}


################################
#   6.8 Autolinks {{{
# www
syn match markdownAutoLink /<www\.[^[:cntrl:][:space:]<>]\+>/ display
# uri
syn match markdownAutoLink /<[a-z]]\{3,}:\/\/[\w!?\/+\-_\~;.,*&@#$%()'[\]]+>/ display
# mail
syn match markdownAutoLink /<[\w\-._]+@[\w\-._]+\.[A-Za-z]+>/ display

hi link markdownAutoLink Underlined
#   }}}


################################
#   6.9 Autolinks (extension) {{{
# www
syn match markdownAutoLinkEx /\<www\.[^[:cntrl:][:space:]<>]\+\>/ 
      \ display containedin=@markdownInline
# url
syn match markdownAutoLinkEx /\<[a-z]]\{3,}:\/\/[\w!?\/+\-_\~;.,*&@#$%()'[\]]+\>/ 
      \ display containedin=@markdownInline
# mail
syn match markdownAutoLinkEx /\<[\w\-._]+@[\w\-._]+\.[A-Za-z]+\>/ 
      \ display containedin=@markdownInline

hi link markdownAutoLinkEx Underlined
#   }}}


################################
#   6.10 Raw HTML {{{
runtime! syntax/xml.vim

syn clear xmlTag
syn region xmlTag matchgroup=xmlTag 
      \ start=/<\%([^ \/!?<>"'@+=]\+[[:space:]>]\)\@=/ end=/>/ 
      \ contains=xmlError,xmlTagName,xmlAttrib,xmlEqual,xmlString,@xmlStartTagHook

syn clear xmlEndTag
syn region xmlEndTag matchgroup=xmlTag 
      \ start=/<\/\%([^ \/!?<>"'@+=]\+[[:space:]>]\)\@=/ end=/>/ 
      \ contains=xmlTagName,xmlNamespace,xmlAttribPunct,@xmlTagHook

syn clear xmlError
#   }}}


################################
#   6.11 Disallowed Raw HTML (extension)
#   6.12 Hard line breaks {{{
syn match markdownLineBreak /  $/ containedin=@markdownInline

hi link markdownLineBreak ErrorMsg
#   }}}


################################
#   6.13 Soft line breaks
#   6.14 Textual content

# }}}

################################################################
#   Issue reference within a repository (Github) {{{
syn match markdownIssueRef /\%(^\|\s\)\@<=#\d\+\%(\s\|$\)\@=/ 
      \ display containedin=@markdownInline
syn match markdownIssueRef /\%(^\|\s\)\@<=\w[[:alnum:]-_]\+\%(\/[[:alnum:]-_]\+\)*#\d\+\%(\s\|$\)\@=/ 
      \ display containedin=@markdownInline

hi link markdownIssueRef Tag
#   }}}

#   Username @mentions (Github) {{{
syn match markdownMentions /\%(^\|\s\)\@<=@[[:alnum:]-_]\+\%(\s\|$\)\@=/ 
      \ display containedin=@markdownInline

hi link markdownMentions Identifier
#   }}}

#   Emoji (Github) {{{
syn match markdownEmoji /\%(^\|\s\)\@<=:\a\w\+\a:\%(\s\|$\)\@=/ 
      \ display containedin=@markdownInline

hi link markdownEmoji Constant
#   }}}


################################################################
# Front matter (YAML) {{{
syn region markdownFrontMatter matchgroup=markdownFrontMatterMarker 
      \ start=/\%^---$/ end=/^\%(---\|\.\.\.\)\s*$/ keepend display contains=@Spell

hi link markdownFrontMatterMarker Delimiter
hi link markdownFrontMatter Comment

# }}}


################################################################
b:current_syntax = "markdown"
