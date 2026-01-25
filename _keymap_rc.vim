vim9script

augroup vimrc_local_autocmd
  autocmd!
  autocmd VimEnter * Root
augroup END

### cursorline
nnoremap <silent> <Leader>l  :CursorLineOnOff<CR>
nnoremap <silent> <Leader>L  :CursorLineReverseOnOff<CR>
nnoremap <silent> <Leader>s  :ScrolloffCenterOnOff<CR>

### zoom in / out
if has('gui_running') && has('win32')
  nnoremap <silent> <Leader>+ :ZoomIn<CR>
  nnoremap <silent> <Leader>- :ZoomOut<CR>
  nnoremap <silent> <Leader>0 :ZoomReset<CR>
endif

### popup
nnoremap <silent> <C-p>f     :PopupFiles<CR>
nnoremap <silent> <C-p>F     :PopupFiles %:h<CR>
nnoremap <silent> <C-p>h     :PopupMru<CR>
nnoremap <silent> <C-p>b     :PopupBuffers<CR>
nnoremap <silent> <C-p>w     :PopupWindows<CR>
nnoremap <silent> <C-p>l     :PopupLines<CR>
nnoremap <silent> <C-p>g     :PopupGlob<CR>
nnoremap <silent> <C-p>G     :PopupGlob %:h<CR>
nnoremap <silent> <C-p><C-g> :PopupGlob!<CR>

### word highlight
nnoremap          <Leader>wa :WordHLAdd 
nnoremap <silent> <Leader>ww :WordHLAdd expand('<cword>')<CR>
nnoremap <silent> <Leader>wd :WordHLDelete<CR>
xnoremap <silent> <Leader>w  :WordHLVisualAdd<CR>

### code snippet
nnoremap <C-s> :VSCodeSnippetInsert 
inoremap <C-s> <C-o>:VSCodeSnippetInsert 
xnoremap <C-s> :VSCodeSnippetReplace 

### word surround
g:enclose_text_pattern_list = []

xnoremap <Leader>eaa :EncloseText -a 
xnoremap <Leader>edd :EncloseText -d 
xnoremap <Leader>err :EncloseText -r 

xnoremap <Leader>eac :EncloseText -a -c<CR>
xnoremap <Leader>edc :EncloseText -d -c<CR>

xnoremap <silent> <Leader>ea( :EncloseText -a -t (     )<CR>
xnoremap <silent> <Leader>ea[ :EncloseText -a -t [     ]<CR>
xnoremap <silent> <Leader>ea{ :EncloseText -a -t {     }<CR>
xnoremap <silent> <Leader>ea< :EncloseText -a -t <     ><CR>

xnoremap <silent> <Leader>ea) :EncloseText -a -t (\  \ )<CR>
xnoremap <silent> <Leader>ea] :EncloseText -a -t [\  \ ]<CR>
xnoremap <silent> <Leader>ea} :EncloseText -a -t {\  \ }<CR>
xnoremap <silent> <Leader>ea> :EncloseText -a -t <\  \ ><CR>

xnoremap <silent> <Leader>ea" :EncloseText -a    " "<CR>
xnoremap <silent> <Leader>ea' :EncloseText -a    ' '<CR>
xnoremap <silent> <Leader>ea` :EncloseText -a    ` `<CR>

xnoremap <silent> <Leader>ed( :EncloseText -d -t ( )<CR>
xnoremap <silent> <Leader>ed[ :EncloseText -d -t [ ]<CR>
xnoremap <silent> <Leader>ed{ :EncloseText -d -t { }<CR>
xnoremap <silent> <Leader>ed< :EncloseText -d -t < ><CR>
xnoremap <silent> <Leader>ed" :EncloseText -d -t " "<CR>
xnoremap <silent> <Leader>ed' :EncloseText -d -t ' '<CR>
xnoremap <silent> <Leader>ed` :EncloseText -d -t ` `<CR>

# smart_input_modoki
inoremap <silent> <expr> [ SmartInputModoki_open_bracket('[', ']')
inoremap <silent> <expr> ( SmartInputModoki_open_bracket('(', ')')
inoremap <silent> <expr> { SmartInputModoki_open_bracket('{', '}')

inoremap <silent> <expr> ] SmartInputModoki_close_bracket('[', ']')
inoremap <silent> <expr> ) SmartInputModoki_close_bracket('(', ')')
inoremap <silent> <expr> } SmartInputModoki_close_bracket('{', '}')

inoremap <silent> <expr> <Space> SmartInputModoki_inside_space()
inoremap <silent> <expr> <CR>    SmartInputModoki_inside_enter()

inoremap <silent> <expr> <C-h> SmartInputModoki_backspace()

inoremap <silent> <expr> ' SmartInputModoki_quote("'", '"')
inoremap <silent> <expr> " SmartInputModoki_quote('"', "'")
inoremap <silent> <expr> ` SmartInputModoki_quote('`', '')

