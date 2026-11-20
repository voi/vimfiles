vim9script

if exists("b:current_syntax")
  finish
endif


################################################################
syn sync minlines=50 maxlines=75
syn case ignore


# 
var is_latex_syntax_enabled = get(g:, 'markdown_latex_syntax_enabled', 1)
var is_gfm_syntax_enabled = get(g:, 'markdown_gfm_extension_syntax_enabled', 1)
var is_github_wiki_syntax_enabled = get(g:, 'markdown_github_wiki_syntax_enabled', 1)


#
def Get_markdown_conceal(option: string): string
  var option_string = get(g:, option, '')

  if option_string->empty()
    return ''
  else
    return ' conceal cchar=' .. option_string->split('\zs')->get(0, '')
  endif
enddef


#
var markdown_link_reference_conceal = Get_markdown_conceal('markdown_link_reference_cchar')
var markdown_link_destination_conceal = Get_markdown_conceal('markdown_link_destination_cchar')
var markdown_link_title_conceal = Get_markdown_conceal('markdown_link_title_cchar')


#
var markdown_list_item_conceal = Get_markdown_conceal('markdown_list_item_cchar')
var markdown_list_todo_conceal = Get_markdown_conceal('markdown_list_todo_cchar')
var markdown_list_done_conceal = Get_markdown_conceal('markdown_list_done_cchar')


################################################################
# 3. Block and Inline {{{1
if &expandtab
  syn match markdownBlockStart /^\%( \{4}\)*\%( \{1,3}\)\?/ 
        \ nextgroup=@markdownLeafBlock,@markdownContainerBlock,markdownFrontMatter 
        \ display
else
  syn match markdownBlockStart /^\t*\%( \{1,3}\)\?/ 
        \ nextgroup=@markdownLeafBlock,@markdownContainerBlock,markdownFrontMatter 
        \ display
endif

# }}}

################################################################
# 4. Leaf blocks {{{1
syn cluster markdownLeafBlock 
      \ contains=markdownThematicBreak,markdownHeader,markdownCodeBlock,markdownFencedCodeBlock,markdownLinkReferenceDefine


################################
#   4.1 Thematic breaks {{{2
syn match markdownThematicBreak /\*\{3,}\s*$/ contained display
syn match markdownThematicBreak /_\{3,}\s*$/  contained display
syn match markdownThematicBreak /-\{3,}\s*$/  contained display

syn match markdownThematicBreak /\%(\s\+\*\+\)\{3,}$/ contained display
syn match markdownThematicBreak /\%(\s\+_\+\)\{3,}$/  contained display
syn match markdownThematicBreak /\%(\s\+-\+\)\{3,}$/  contained display

hi link markdownThematicBreak Operator
#   }}}


################################
#   4.2 ATX headings {{{2
syn region markdownHeader matchgroup=markdownAtx 
      \ start=/#\{1,6}\s\@=/ end=/\%(\s\@<=#\+\)\?\s*$/ 
      \ keepend transparent oneline contained display

hi link markdownAtx PreProc
#   }}}


################################
#   4.3 Setext headings {{{2
syn match markdownHeader /^ \{,3}[^\-\*_=>[:space:]].\+\n\s\{,3}\%(-\|=\)\+\s*$/ 
      \ contains=markdownSetext transparent contained display
syn match markdownSetext /[=-]\+/ contained

hi link markdownSetext PreProc
#   }}}


################################
#   4.4 Indented code blocks {{{2
if &expandtab
  syn match markdownCodeBlock /\t.*/ contained display
else
  syn match markdownCodeBlock /\%(    \).*/ contained display
endif

hi link markdownCodeBlock Comment
#   }}}


################################
#   4.5 Fenced code blocks {{{2
syn region markdownFencedCodeBlock matchgroup=Delimiter 
      \ start=/\z(`\{3,}\)\%(\.\?\w\+\|\s\?{[^}]\+}\)\?/  end=/\z1`*\s*$/ 
      \ keepend contained display contains=markdownBlockquoteContained
syn region markdownFencedCodeBlock matchgroup=Delimiter 
      \ start=/\z(\~\{3,}\)\%(\.\?\w\+\|\s\?{[^}]\+}\)\?/ end=/\z1\~*\s*$/ 
      \ keepend contained display contains=markdownBlockquoteContained

syn sync match markdownFencedCodeBlockMarker 
      \ grouphere markdownFencedCodeBlock "[`\~]\{3,}" 

hi link markdownFencedCodeBlock Comment
#   }}}


################################
#   4.6 HTML blocks
#   4.7 Link reference definitions {{{2
syn region markdownLinkReferenceDefine matchgroup=markdownLinkMarker 
      \ start=/\[\s\@!/ skip=/\\[\[\]]/ end=/\s\@<!\]:/ 
      \ nextgroup=markdownLinkDestination skipwhite oneline display

hi link markdownLinkReferenceDefine Tag
hi link markdownLinkMarker Statement

#   }}}


################################
#   4.8 Paragraphs
#   4.9 Blank lines
#   4.10 Tables (extension) {{{2
if is_gfm_syntax_enabled
  syn cluster markdownLeafBlock add=markdownTable

  syn match markdownTable /\%(\S.*\s\)\\\@<!|\%(.*\s|\)*\%(.*\)\?/ 
        \ transparent contains=markdownTableBorder,@markdownInline contained
  syn match markdownTableBorder /\%(^\|\s\)\@<=|\ze\%(\s\|$\)/ contained
  syn match markdownTableBorder /:\?-\+:\?/ contained

  hi link markdownTableBorder Statement
endif
#   }}}


################################
#   x.x Latex Block (extension) {{{2
if is_latex_syntax_enabled
  syn cluster markdownLeafBlock add=markdownLatexBlock

  syn region markdownLatexBlock matchgroup=Delimiter
        \ start=/\z(\$\{2}\)\%(\.\?\w\+\|\s\?{[^}]\+}\)\?/  end=/\z1\s*$/ 
        \ keepend contained contains=markdownBlockquoteContained

  syn sync match markdownLatexBlockMarker 
        \ grouphere markdownLatexBlock "[`\$]\{2}" 
endif
#   }}}

# }}}

################################################################
# 5. Container blocks {{{1
syn cluster markdownContainerBlock 
      \ contains=markdownBlockquote

if &expandtab
  syn match markdownContainerBlockStart /\%( \{4}\)*\%( \{1,3}\)\?/ 
        \ nextgroup=@markdownLeafBlock,@markdownContainerBlock 
        \ contained
else
  syn match markdownContainerBlockStart /\t*\%( \{1,3}\)\?/ 
        \ nextgroup=@markdownLeafBlock,@markdownContainerBlock 
        \ contained
endif


################################
#   5.1 Block quotes {{{2
syn match markdownBlockquote />/ 
      \ nextgroup=markdownContainerBlockStart 
      \ contained display

hi link markdownBlockquote Directory


# HACK: 
syn match markdownBlockquoteContained /\%(^\s*\)\zs\%(>\s*\)\+/ 
      \ contained display

hi link markdownBlockquoteContained markdownBlockquote
#   }}}


################################
#   5.2 List items
#   5.4 Lists {{{2
syn cluster markdownContainerBlock 
      \ add=markdownOrderedList,markdownBulletList

syn match markdownOrderedList /\d\{1,9}[.)]\s\@=/ 
      \ skipwhite nextgroup=markdownContainerBlockStart
      \ contained display
execute 'syn match markdownBulletList /[-+*]\s\@=/ '
      \ .. 'skipwhite nextgroup=markdownContainerBlockStart '
      \ .. 'contained display '
      \ .. markdown_list_item_conceal

hi link markdownOrderedList Tag
hi link markdownBulletList Tag
#   }}}


################################
#   5.3 Task list items (extension) {{{2
if is_gfm_syntax_enabled
  syn cluster markdownContainerBlock 
        \ add=markdownTaskTodo,markdownTaskDone

  execute 'syn match markdownTaskTodo /[-+*]\%( \{1,4}\|\t\)\[ \]\s\@=/ '
        \ .. 'nextgroup=markdownContainerBlockStart '
        \ .. (markdown_list_todo_conceal->empty() ? 'contains=markdownBulletListMarker,markdownTaskTodoMarker ' : ' ')
        \ .. 'transparent contained display '
        \ .. markdown_list_todo_conceal

  execute 'syn match markdownTaskDone /[-+*]\%( \{1,4}\|\t\)\[[xX]\]\s\@=/ '
        \ .. 'nextgroup=markdownTaskDoneContent '
        \ .. (markdown_list_done_conceal->empty() ? 'contains=markdownBulletListMarker,markdownTaskDoneMarker ' : ' ')
        \ .. 'transparent contained display '
        \ .. markdown_list_done_conceal

  execute 'syn match markdownTaskDoneContent /.*$/ '
        \ .. (get(g:, 'markdown_task_done_include_inlines', 0) ? 'contains=@markdownInline ' : ' ')
        \ .. 'contained display'

  syn match markdownBulletListMarker /[-+*]\s\+/ skipwhite contained display
  syn match markdownTaskTodoMarker /\[ \]/    contained display
  syn match markdownTaskDoneMarker /\[[xX]\]/ contained display

  hi link markdownBulletListMarker Tag
  hi link markdownTaskTodoMarker Todo
  hi link markdownTaskDoneMarker Comment
  hi link markdownTaskDoneContent markdownStrikeThrough
endif
#   }}}


# }}}

################################################################
# 6. Inlines {{{1
syn cluster markdownInline 
      \ contains=markdownEscape,markdownCodeSpan,markdownStrongEmphasis,markdownEmphasis,markdownStrongEmphasis,markdownLink,markdownImage,markdownAutoLink,markdownLineBreak


################################
#   6.1 Backslash escapes {{{2
syn match markdownEscape /\\[!"#$%&'()*+,\-./:;<=>?@\[\]^_`{|}~]/ 
      \ display

hi link markdownEscape WarningMsg
#   }}}


################################
#   6.2 Entity and numeric character references
#   6.3 Code spans {{{2
syn region markdownCodeSpan start=/\z([\\`]\@<!``\@!\)/  skip=/`\{2,}/ end=/\z1/ 
      \ oneline display
syn region markdownCodeSpan start=/\z([\\`]\@<!```\@!\)/ skip=/`\{3,}/ end=/\z1/ 
      \ oneline display

hi link markdownCodeSpan  String
#   }}}


################################
#   6.4 Emphasis and strong emphasis {{{2
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
          \ .. '[[:space:][:cntrl:]' .. punct .. chr .. ']\@!',
    # (2b)
    '[[:space:][:cntrl:]' .. punct .. ']\@<=' 
          \ .. delim 
          \ .. '[[:space:][:cntrl:]' .. chr .. ']\@!'
  ], '\|')
enddef

def RightFlaking_Delimiter_Run(chr: string, count: number, punct: string, right: string): string
  var delim = repeat(chr, count)

  return join([
    # (1) and (2a)
    '[[:space:][:cntrl:]' .. punct .. chr .. '\\]\@<!' 
          \ ..  delim 
          \ ..  '[[:space:][:cntrl:]' .. punct .. chr .. right .. ']\@!',
    # (2b)
    '[[:space:][:cntrl:]\\' .. chr .. ']\@<!' 
          \ .. delim 
          \ .. '[[:space:][:cntrl:]' .. punct .. chr .. ']\@='
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
#   6.5 Strikethrough (extension) {{{2
if is_gfm_syntax_enabled
  syn cluster markdownInline add=markdownStrikeThrough

  syn region markdownStrikeThrough 
        \ start=/\z([\\\~]\@<!\~\{2}[\~]\@!\)/ skip=/\~\{3,}/ end=/\z1/ 
        \ contains=markdownLink oneline display

  if has('gui_running')
    hi markdownStrikeThrough  gui=strikethrough guifg=#999999
  else
    hi link markdownStrikeThrough  SpecialKey
  endif
endif
#   }}}


################################
#   x.x Latex Span (extension) {{{2
if is_latex_syntax_enabled
  syn cluster markdownInline add=markdownLatexSpan

  syn region markdownLatexSpan 
        \ start=/\z([\\\$]\@<!\$$\@!\)/ skip=/\$\{2,}/ end=/\z1/ 
        \ oneline display

  hi link markdownLatexSpan String
endif
#   }}}


################################
#   6.6 Links {{{2
syn region markdownLink matchgroup=markdownLinkMarker 
      \ start=/\\\@<!\[\s\@!/ skip=/\\[\[\]]/ end=/\s\@<!\][(\[]\@=/ 
      \ nextgroup=markdownInlineLink,markdownLinkRef 
      \ keepend oneline display
      \ contains=@markdownInline

hi link markdownLink String


#
syn region markdownInlineLink matchgroup=markdownLinkMarker 
      \ start=/(/ skip=/\\[()]\|([^()]\+)/ end=/\\\@<!)/ 
      \ transparent oneline contains=markdownLinkDestination 
      \ keepend contained display


#
execute 'syn match markdownLinkRef /\[\%(\\[\[\]]\|[^\[\][:space:]]\)\+\]/ '
      \ .. 'contained display '
      \ .. markdown_link_reference_conceal

hi link markdownLinkRef Tag


#
execute 'syn region markdownLinkDestination start=/</ skip=/\\[<>]/ end=/>/ '
      \ 'keepend oneline nextgroup=markdownLinkTitle skipwhite contained display '
      \ .. markdown_link_destination_conceal
execute 'syn match markdownLinkDestination /\%([^<>()[:space:][:cntrl:]]\|\[()]\)\+/ '
      \ 'nextgroup=markdownLinkTitle skipwhite contained display'
      \ .. markdown_link_destination_conceal

hi link markdownLinkDestination Underlined


#
def Markdown_syntaxLinkTitle(start: string, skip: string, end: string)
  execute 'syn region markdownLinkTitle '
        \ .. printf('start=/\\\@<!%s/ skip=/\\%s/ end=/\\\@<!%s/ ', start, skip, end)
        \ .. 'keepend contained display '
        \ .. markdown_link_title_conceal
enddef

call Markdown_syntaxLinkTitle('"', '"', '"')
call Markdown_syntaxLinkTitle("'", "'", "'")
call Markdown_syntaxLinkTitle('(', '[()]', ')')


hi link markdownLinkTitle String
#   }}}


################################
#   6.7 Images {{{2
syn region markdownImage matchgroup=markdownLinkMarker 
      \ start=/\\\@<!!\[\s\@!/ skip=/\\[\[\]]/ end=/\s\@<!\](\@=/ 
      \ nextgroup=markdownInlineLink 
      \ keepend oneline display

hi link markdownImage String

#   }}}


################################
#   6.8 Autolinks {{{2
# absolute URL
syn match markdownAutoLink /\\\@<!<[[:alnum:]+.-]\{2,32}:[^<>[:space:][:cntrl:]]\+>/ 
      \ display
# email
syn match markdownAutoLink /\\\@<!<[[:alnum:].!#$%&'*+\/=?^_`{|}~-]\+@\w\%([[:alnum:]-]\{0,61}\w\)\?\%(\.\w\%([[:alnum:]-]\{0,61}\w\)\?\)*>/ 
      \ display

hi link markdownAutoLink Underlined
#   }}}


################################
#   6.9 Autolinks (extension) {{{2
if is_gfm_syntax_enabled
  syn cluster markdownInline add=markdownAutoLinkEx

  # www
  syn match markdownAutoLinkEx /\%(\_^\|[[:space:]*_~]\)\@<=www\%(\.[[:alnum:]_-]\+\)*\.[[:alnum:]-]\+\.[[:alnum:]-]\+\%(\/[[:alnum:]_\/:%#\$&\?\(\)~\.=\+\-]\+\)*\>\/\?/ 
        \ display
  # URL (http/https)
  syn match markdownAutoLinkEx /\%(\_^\|[[:space:]*_~]\)\@<=https\?:\/\/[[:alnum:]_-]\+\%(\.[[:alnum:]_-]\+\)*\.[[:alnum:]-]\+\.[[:alnum:]-]\+\%(\/[[:alnum:]_\/:%#\$&\?\(\)~\.=\+\-]\+\)*\>\/\?/ 
        \ display
  # email
  syn match markdownAutoLinkEx /\%(\_^\|[[:space:]*_~]\)\@<=\%(mailto:\|xmpp:\)\?[[:alnum:]._+-]\+@[[:alnum:]._-]\+\%(\.[[:alnum:]._-]\+\)*[[:alnum:]]\>/ 
        \ display


  hi link markdownAutoLinkEx Underlined
endif
#   }}}


################################
#   6.10 Raw HTML {{{2
runtime! syntax/xml.vim


# 
syn clear xmlTag
syn region xmlTag matchgroup=xmlTag 
      \ start=/<\%([^ \/!?<>"'@+=]\+[[:space:]>]\)\@=/ end=/>/ 
      \ contains=xmlError,xmlTagName,xmlAttrib,xmlEqual,xmlString,@xmlStartTagHook


#
syn clear xmlEndTag
syn region xmlEndTag matchgroup=xmlTag 
      \ start=/<\/\%([^ \/!?<>"'@+=]\+[[:space:]>]\)\@=/ end=/>/ 
      \ contains=xmlTagName,xmlNamespace,xmlAttribPunct,@xmlTagHook

syn clear xmlError
#   }}}


################################
#   6.11 Disallowed Raw HTML (extension)
#   6.12 Hard line breaks {{{2
syn match markdownLineBreak / \{2,}$/ contained
syn match markdownLineBreak /\\$/ contained

hi link markdownLineBreak ErrorMsg
#   }}}


################################
#   6.13 Soft line breaks
#   6.14 Textual content

# }}}

################################################################
if is_github_wiki_syntax_enabled
# github wiki # {{{1
  syn cluster markdownInline add=markdownIssueRef,markdownMentions,markdownEmoji


  #   Issue reference within a repository (Github) {{{
  syn match markdownIssueRef /\%(\_^\|[^#[:alnum:]/_-]\)\@<=#\d\+\%(\_$\|[^#[:alnum:]_-]\)\@=/ 
        \ display
  syn match markdownIssueRef /\%(\_^\|[^#[:alnum:]/_-]\)\@<=\w[[:alnum:]-_]\+\%(\/[[:alnum:]-_]\+\)*#\d\+\%(\_$\|[^#[:alnum:]_-]\)\@=/ 
        \ display

  hi link markdownIssueRef Tag
  #   }}}


  #   Username @mentions (Github) {{{
  syn match markdownMentions /\%(\_^\|[^@[:alnum:]/_-]\)\@<=@[[:alnum:]_-]\+\%(\_$\|[^@[:alnum:]_-]\)\@=/ 
        \ display

  hi link markdownMentions Identifier
  #   }}}


  #   Emoji (Github) {{{
  syn match markdownEmoji /\%(\_^\|[^:[:alnum:]/_-]\)\@<=:\a\w*\a:\%(\_$\|[^[:alnum:]_-]\)\@=/ 
        \ display

  hi link markdownEmoji Constant
  #   }}}
endif
# }}}


################################################################
# Front matter (YAML) {{{1
syn region markdownFrontMatter matchgroup=markdownFrontMatterMarker 
      \ start=/\%^---$/ end=/^\%(---\|\.\.\.\)\s*$/ 
      \ keepend contained display contains=@Spell

hi link markdownFrontMatterMarker Delimiter
hi link markdownFrontMatter Comment

# }}}


################################################################
b:current_syntax = "markdown"
