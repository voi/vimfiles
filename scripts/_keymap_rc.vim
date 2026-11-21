vim9script


# ###############################
# ## vimrc
# cursorline
nnoremap <silent> <Leader>l  :CursorLineOnOff<CR>
nnoremap <silent> <Leader>L  :CursorLineReverseOnOff<CR>


# zoom in / out
if has('gui_running') && has('win32')
  nnoremap <silent> <Leader>+ :ZoomIn<CR>
  nnoremap <silent> <Leader>- :ZoomOut<CR>
  nnoremap <silent> <Leader>0 :ZoomReset<CR>
endif


# ###############################
# fuzzy choice
nnoremap <silent> <C-p>f     :FuzzyChoiceFiles<CR>
nnoremap <silent> <C-p>F     :FuzzyChoiceFiles %:h<CR>
nnoremap <silent> <C-p>h     :FuzzyChoiceMru<CR>
nnoremap <silent> <C-p>b     :FuzzyChoiceBuffers<CR>
nnoremap <silent> <C-p>w     :FuzzyChoiceWindows<CR>
nnoremap <silent> <C-p>l     :FuzzyChoiceLines<CR>
nnoremap <silent> <C-p>g     :FuzzyChoiceGlob<CR>
nnoremap <silent> <C-p>G     :FuzzyChoiceGlob %:h<CR>
nnoremap <silent> <C-p><C-g> :FuzzyChoiceGlob!<CR>

nnoremap <silent> <C-p>vss  :FuzzySvnStatus<CR>
nnoremap <silent> <C-p>vsl  :FuzzySvnLs -R<CR>

nnoremap <silent> <C-p>vgs  :FuzzyGitStatus<CR>
nnoremap <silent> <C-p>vgl  :FuzzyGitLs<CR>


# ###############################
# word highlight
nnoremap          <Leader>wa :WordHLAdd 
nnoremap <silent> <Leader>ww :WordHLAdd expand('<cword>')<CR>
nnoremap <silent> <Leader>wd :WordHLDelete<CR>
xnoremap <silent> <Leader>w  :WordHLVisualAdd<CR>


# ###############################
# code snippet
nnoremap <C-s> :VSCodeSnippetInsert 
inoremap <C-s> <C-o>:VSCodeSnippetInsert 
xnoremap <C-s> :VSCodeSnippetReplace 


# ###############################
# word surround
xnoremap <Leader>eaa :EncloseText -a 
xnoremap <Leader>ed  :EncloseText -d -p<CR>
xnoremap <Leader>er  :EncloseText -r -p 

xnoremap <Leader>eac :EncloseText -a -c<CR>
xnoremap <Leader>edc :EncloseText -d -c<CR>

xnoremap <silent> <Leader>ea( :EncloseText -a -t -p (<CR>
xnoremap <silent> <Leader>ea[ :EncloseText -a -t -p [<CR>
xnoremap <silent> <Leader>ea{ :EncloseText -a -t -p {<CR>
xnoremap <silent> <Leader>ea< :EncloseText -a -t -p <<CR>

xnoremap <silent> <Leader>ea) :EncloseText -a -t -p )<CR>
xnoremap <silent> <Leader>ea] :EncloseText -a -t -p ]<CR>
xnoremap <silent> <Leader>ea} :EncloseText -a -t -p }<CR>
xnoremap <silent> <Leader>ea> :EncloseText -a -t -p ><CR>

xnoremap <silent> <Leader>ea" :EncloseText -a -p "<CR>
xnoremap <silent> <Leader>ea' :EncloseText -a -p '<CR>
xnoremap <silent> <Leader>ea` :EncloseText -a -p `<CR>


# ###############################
#
nnoremap <silent> <Leader>m :MarkAndSignToggle<CR>
nnoremap <silent> <Leader>M :MarkAndSignToggle!<CR>
nnoremap <silent> <M-m>     :MarkAndSignPopup<CR>


# ###############################
# input_helper
import 'input_helper.vim'

g:input_helper_map_left_parenthesis = [
      \ ['\%#[^()]',  "()\<Left>"],
      \ ['\%#$',      "()\<Left>"]]
g:input_helper_map_right_parenthesis = [
      \ ['\%#)', "\<Right>"]
      \ ]

g:input_helper_map_left_square_bracket = [
      \ ['\%#[^\[\]]',  "[]\<Left>"],
      \ ['\%#$',        "[]\<Left>"]]
g:input_helper_map_right_square_bracket = [
      \ ['\%#\]', "\<Right>"]
      \ ]

g:input_helper_map_left_curly_bracket = [
      \ ['\%#[^{}]',  "{}\<Left>"],
      \ ['\%#$',      "{}\<Left>"]]
g:input_helper_map_right_curly_bracket = [
      \ ['\%#}', "\<Right>"]
      \ ]

g:input_helper_map_space = [
      \ ['(\%#)',    "  \<Left>"],
      \ ['\[\%#\]',  "  \<Left>"],
      \ ['{\%#}',    "  \<Left>"]]
g:input_helper_map_enter = [
      \ ['(\%#)',    "\<CR>\<Up>\<End>\<CR>"],
      \ ['\[\%#\]',  "\<CR>\<Up>\<End>\<CR>"],
      \ ['{\%#}',    "\<CR>\<Up>\<End>\<CR>"]]
g:input_helper_map_backspace = [
      \ ['\[\%#\]', "\<Del>\<C-h>"],
      \ ['(\%#)',   "\<Del>\<C-h>"],
      \ ['{\%#}',   "\<Del>\<C-h>"],
      \ ['"\%#"',   "\<Del>\<C-h>"],
      \ ["'\\%#'",  "\<Del>\<C-h>"],
      \ ['\[\s\%#\s\]', "\<Del>\<C-h>"],
      \ ['(\s\%#\s)', "\<Del>\<C-h>"],
      \ ['{\s\%#\s}', "\<Del>\<C-h>"]]

g:input_helper_map_single_quote = [
      \ ["\\%#'", "\<Right>"],
      \ ['"[^"]*\%#[^"]*"', "'"],
      \ ['`[^`]*\%#[^`]*`', "'"],
      \ ['\%#', "''\<Left>"]]
g:input_helper_map_double_quote = [
      \ ['\%#"', "\<Right>"],
      \ ["'[^']*\\%#[^']*'",  '"'],
      \ ['`[^`]*\%#[^`]*`',   '"'],
      \ ['\%#', '""' .. "\<Left>"]]
g:input_helper_map_back_quote = [
      \ ['\%#`', "\<Right>"],
      \ ["'[^']*\\%#[^']*'",  '`'],
      \ ['"[^"]*\%#[^"]*"',   '`'],
      \ ['\%#', "``\<Left>"]]

inoremap <silent> <expr> ( input_helper.Map('(', g:input_helper_map_left_parenthesis)
inoremap <silent> <expr> ) input_helper.Map(')', g:input_helper_map_right_parenthesis)

inoremap <silent> <expr> ] input_helper.Map(']', g:input_helper_map_right_square_bracket)
inoremap <silent> <expr> [ input_helper.Map('[', g:input_helper_map_left_square_bracket)

inoremap <silent> <expr> { input_helper.Map('{', g:input_helper_map_left_curly_bracket)
inoremap <silent> <expr> } input_helper.Map('}', g:input_helper_map_right_curly_bracket)

inoremap <silent> <expr> <Space> input_helper.Map("\<Space>", g:input_helper_map_space)
inoremap <silent> <expr> <CR> input_helper.Map("\<CR>", g:input_helper_map_enter)
inoremap <silent> <expr> <C-h> input_helper.Map("\<C-h>", g:input_helper_map_backspace)

inoremap <silent> <expr> ' input_helper.Map("'", g:input_helper_map_single_quote)
inoremap <silent> <expr> " input_helper.Map('"', g:input_helper_map_double_quote)
inoremap <silent> <expr> ` input_helper.Map('`', g:input_helper_map_back_quote)

