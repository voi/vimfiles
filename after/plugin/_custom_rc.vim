vim9script

# set path for VSCode snippets folder.
g:code_snippet_glob_pathes = '~/scoop/persist/vscode/data/user-data/User/snippets'
  ->expand()->fnamemodify(':p')

# icon character ( color emoji )
g:vimrc_statusline_icon_pwd = '📍'
g:vimrc_statusline_icon_ro  = '❎'
g:vimrc_statusline_icon_mod = '⚡'

g:vimrc_tabline_icon_dir = '📂:'
g:vimrc_tabline_icon_nor = '📝'
g:vimrc_tabline_icon_mod = '⚡'

g:popup_editee_icon_dir   = '📁'
g:popup_editee_icon_file  = '📝'
g:popup_editee_icon_empty = '🈳'
g:popup_editee_icon_buff  = '📜'
g:popup_editee_icon_wind  = '📑'

# limit
# g:popup_editee_glob_max_candidates = 50000

# ignore pattern
# g:popup_editee_glob_regex_ignore_dir = '^\%(\.git\|\.svn\)$'
# g:popup_editee_glob_regex_ignore_file = '\%(^_FOSSIL_\|\.exe\|\.dll\|\.docx\?\|\.xls[xm]\?\|\.vsdx\?|\.pdf\)$'

# history
# g:vimrc_plugin_popup_mru_pinned = '~/_vim_mru_pinned.txt'

## gf improved
# g:smart_gf_web_browser_command = ''

## find root
augroup vimrc_local_autocmd
  autocmd VimEnter * Root
augroup END

## popup
nnoremap <silent> <C-p>f     :PopupFiles<CR>
nnoremap <silent> <C-p>F     :PopupFiles %:h<CR>
nnoremap <silent> <C-p>h     :PopupMru<CR>
nnoremap <silent> <C-p>b     :PopupBuffers<CR>
nnoremap <silent> <C-p>w     :PopupWindows<CR>
nnoremap <silent> <C-p>l     :PopupLines<CR>
nnoremap <silent> <C-p>g     :PopupGlob<CR>
nnoremap <silent> <C-p>G     :PopupGlob %:h<CR>
nnoremap <silent> <C-p><C-g> :PopupGlob!<CR>

## word highlight
nnoremap          <Leader>wa :WordHLAdd 
nnoremap <silent> <Leader>ww :WordHLAdd expand('<cword>')<CR>
xnoremap <silent> <Leader>w  :WordHLVisualAdd<CR>

## code snippet
nnoremap <Leader>s :VSCodeSnippetInsert 
inoremap <Leader>s <C-o>:VSCodeSnippetInsert 
xnoremap <Leader>s :VSCodeSnippetReplace 

## word surround
# g:enclose_text_pattern_list = []

xnoremap <Leader>eaa :EncloseText -a 
xnoremap <Leader>edd :EncloseText -d 
xnoremap <Leader>err :EncloseText -r 

xnoremap <Leader>eac :EncloseText -a -c<CR>
xnoremap <Leader>edc :EncloseText -d -c<CR>

xnoremap <silent> <Leader>ea( :EncloseText -a -t (     )<CR>
xnoremap <silent> <Leader>ea) :EncloseText -a -t (\  \ )<CR>
xnoremap <silent> <Leader>ea[ :EncloseText -a -t [     ]<CR>
xnoremap <silent> <Leader>ea] :EncloseText -a -t [\  \ ]<CR>
xnoremap <silent> <Leader>ea{ :EncloseText -a -t {     }<CR>
xnoremap <silent> <Leader>ea} :EncloseText -a -t {\  \ }<CR>
xnoremap <silent> <Leader>ea< :EncloseText -a -t <     ><CR>
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

# align words
# g:align_words_petterm_list = []

