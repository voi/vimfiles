"" vim: set ft=vim foldmethod=marker
"" vim: set et ts=2 sts=2 sw=2
if has('gui_running') && has('clientserver') && argc() && !&diff
  let g:ignore_servers = [ v:servername ]
  let servers = filter(split(serverlist(), '\n'), { idx, val -> index(g:ignore_servers, val) == -1 })

  if !empty(servers)
    silent execute '!start gvim'
        \ '--servername' servers[0]
        \ '--remote-tab-silent ' join(map(copy(argv()), { key, val -> fnameescape(val) } ), ' ')
    qa!
  endif
endif

""
source $VIMRUNTIME/vimrc_example.vim

scriptencoding utf8


" ***********************************************
set ambiwidth=double
set encoding=utf-8
set fileformats+=mac
set fileencodings=utf-8,ucs-bom,euc-jp,eucjp-jisx0213,cp932,iso-2022-jp-3,iso-2022-jp,ucs-2le,ucs-2,cp936,default,latain1


" ***********************************************
" for win32
if has('win32')
  set makeencoding=char
  set termencoding=cp932
  set clipboard& clipboard+=unnamed
endif


" ***********************************************
scriptencoding utf-8


" ***********************************************
set lazyredraw
" set synmaxcol=200
set shortmess=coOIWtT
set laststatus=2
set belloff=all

set statusline=
set statusline+=%#StatusLine_Normal#%{(mode()=='n')?'\ \ NO\ ':''}
set statusline+=%#StatusLine_Insert#%{(mode()=='i')?'\ \ IN\ ':''}
set statusline+=%#StatusLine_Replace#%{(mode()=='r')?'\ \ RE\ ':''}
set statusline+=%#StatusLine_Visual#%{(mode()=='v')?'\ \ VI\ ':''}
set statusline+=%#StatusLine_Modes#
set statusline+=%{(&modified?'！':'')}
set statusline+=%{(&readonly?'×':'')}
set statusline+=〉
set statusline+=%#StatusLine#
set statusline+=\ %{pathshorten(bufname('%'))}  " short file name
set statusline+=%=    " right align
set statusline+=%#StatusLine_Modes#
set statusline+=§
set statusline+=%y\ %{&fileencoding}\   " file type + encoding
set statusline+=%#StatusLine_CursorPos#
set statusline+=∠\ %l,\ %v\ -\ %04B\  " line + column + char-code

set guioptions+=cM

set number
set list
set nowrap

if has('gui')
  " |¦»▸>
  let &showbreak="▸ "
  set listchars=tab:»\ ,trail:.,extends:»,precedes:«,nbsp:%
  " set listchars=tab:»\ ,space:.,trail:.,extends:$,precedes:^,nbsp:%,conceal:@
else
  let &showbreak="> "
  set listchars=tab:>\ ,trail:.,extends:$,precedes:^,nbsp:%
endif

if has('conceal') | set conceallevel=2 | endif 

set colorcolumn=120
set formatoptions+=jnmM
set display=lastline
set nofixendofline
set showtabline=2
set textwidth=0
set scrolloff=0

set whichwrap+=h,l,<,>,[,]
set virtualedit+=block

set smarttab shiftround
set tabstop=4 shiftwidth=4 softtabstop=4

set autoindent smartindent
set copyindent preserveindent

set complete=.,b,k
set wildignorecase
set wildmode=list:full

if has('win32')
  set wildignore+=*\\.git\\*,*\\.hg\\*,*\\.svn\\*  " Windows ('noshellslash')
else
  set wildignore+=*/.git/*,*/.hg/*,*/.svn/*        " Linux/MacOSX
endif

set autochdir
set isfname+=(,)

set autowrite autowriteall
set autoread


" ***********************************************
"" history files.
set nobackup
set nowritebackup
set noswapfile
set noundofile
" set viminfo=

"" switch buffer
set switchbuf=useopen,usetab
set hidden

"" word search.
set grepprg=internal
set ignorecase
set smartcase

"" encrypt file.
set cryptmethod=blowfish


" ***********************************************
"" key mappings
" a"/a'/a` trim whitespaces, a(/a{/a[ don't trim whitespaces.
xnoremap a" 2i"
xnoremap a' 2i'
xnoremap a` 2i`

onoremap a" 2i"
onoremap a' 2i'
onoremap a` 2i`

""
nnoremap gb :ls<CR>:b 

"" 
nnoremap <silent> Y y$

"" <Del>
inoremap <silent> <C-l> <Del>

" visual replace
xnoremap <silent> _ "0p`<
xnoremap <silent> * "*p`<

"" switch modes.
nnoremap <silent> <Leader>e :setlocal expandtab! expandtab? <CR>
nnoremap <silent> <Leader>h :setlocal hlsearch!  <CR>
nnoremap <silent> <Leader>r :setlocal readonly!  readonly? <CR>
nnoremap <silent> <Leader>w :setlocal wrap!      wrap?<CR>

" error jumps.
nnoremap <silent> cp :lprevious<CR>zz
nnoremap <silent> cn :lnext<CR>zz

nnoremap <silent> ck :cprevious<CR>zz
nnoremap <silent> cj :cnext<CR>zz


" hints
function! Vimrc_Register_hints(prefix, cmd) abort
  redir => str
  :execute a:cmd
  redir END

  echo str

  return a:prefix . nr2char(getchar())
endfunction

" カーソル位置のマーク
nnoremap <expr> <Leader>m  Vimrc_Register_hints('m', 'marks')
" マーク位置へのジャンプ
nnoremap <expr> <Leader>`  Vimrc_Register_hints('`', 'marks')
" マーク位置へのジャンプ
nnoremap <expr> <Leader>'  Vimrc_Register_hints("'", 'marks')
" レジスタ参照（ヤンクや削除）
nnoremap <expr> <Leader>"  Vimrc_Register_hints('"', 'registers')
" マクロ記録
nnoremap <expr> <Leader>q  Vimrc_Register_hints('q', 'registers')
" マクロ再生
nnoremap <expr> <Leader>@  Vimrc_Register_hints('@', 'registers')


" ***********************************************
"" utility commands
"" tempolaly buffer.
command! -nargs=? Temp 
    \ execute printf( 'tabedit %s.%s.%s', tempname(), strftime('%Y-%m-%d_%H-%M-%S'), '<args>')

"" rename
"" <http://d.hatena.ne.jp/fuenor/20100115/1263551230>
command! -nargs=+ -bang -complete=file Rename
    \ let pbnr=fnamemodify(bufname('%'), ':p') | exec 'f '.escape(<q-args>, ' ') | w<bang> | call delete(pbnr)

command! Mru 
    \ let pattern = input('filter:', '') | echo "\n" |
    \ execute printf('browse filter /%s/ oldfiles', pattern)

command! BufOnly 
    \ let bnrs = join(filter(range(1, bufnr('$')), {
    \   idx, val -> bufexists(val) && val != bufnr('%')
    \ }), ' ') |
    \ if bnrs !=# '' | execute 'bw ' . bnrs | endif

command! BufClean 
    \ let bnrs = join(filter(range(1, bufnr('$')), {
    \   idx, val -> bufexists(val) && buflisted(val) && bufname(val) ==# '' && !getbufvar(val, '&mod', 0) && val != bufnr('%')
    \ }), ' ') |
    \ if bnrs !=# '' | execute 'bw ' . bnrs | endif


" ***********************************************
"" other options
"" *ft-c-syntax* spedial syntax
let g:c_gnu = 1
let g:c_comment_strings = 1
let g:c_space_errors = 1
let g:c_no_bracket_error = 1  " []の中の{}をエラーとして表示しない
let g:c_no_curly_error = 1  " { と } が第1桁にあるときを除き、[] と () の内側の {}をエラーとして表示しない。

let did_install_default_menus = 1
let did_install_syntax_menu = 1


" ***********************************************
" disable default plugins " {{{
let g:loaded_gzip = 1
let g:loaded_tar = 1
let g:loaded_tarPlugin = 1
let g:loaded_zip = 1
let g:loaded_zipPlugin = 1
let g:loaded_rrhelper = 1
let g:loaded_2html_plugin = 0
let g:loaded_vimball = 1
let g:loaded_vimballPlugin = 1
let g:loaded_getscript = 1
let g:loaded_getscriptPlugin = 1

let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1
let g:loaded_netrwSettings = 1
let g:loaded_netrwFileHandlers = 1

" let g:loaded_matchparen = 1 

let g:vim_indent_cont = 4

" ***********************************************
"" utility functions
function! s:Vimrc_HighlightPlus() abort "{{{
  " ime
  highlight CursorIM  gui=NONE  guifg=#FFFFFF  guibg=#8000ff ctermfg=White ctermbg=Red

  " statusline
  highlight StatusLine_Modes      guifg=#030303 guibg=#FFFFFF ctermfg=Black ctermbg=White
  highlight StatusLine_CursorPos  guifg=#FFFFFF guibg=#333399 ctermfg=White ctermbg=DarkBlue

  highlight StatusLine_Normal     guifg=#FFFFFF guibg=#0000FF ctermfg=White ctermbg=Blue
  highlight StatusLine_Insert     guifg=#FFFFFF guibg=#009944 ctermfg=White ctermbg=Green
  highlight StatusLine_Replace    guifg=#FFFFFF guibg=#9933A3 ctermfg=White ctermbg=Cyan
  highlight StatusLine_Visual     guifg=#FFFFFF guibg=#F20000 ctermfg=White ctermbg=Red

  highlight link TrailingSpace NonText

  if &g:background ==# 'dark'
    " highlight SpecialKey   gui=NONE      guifg=#808080  guibg=bg ctermfg=grey 
    highlight ZenkakuSpace gui=underline guifg=darkgrey term=underline ctermfg=darkgrey

  else
    " highlight SpecialKey   gui=NONE      guifg=#cccccc  guibg=NONE ctermfg=grey 
    highlight ZenkakuSpace gui=underline guifg=grey cterm=underline ctermfg=grey

  endif
endfunction "}}}

call <SID>Vimrc_HighlightPlus()

" simple auto-complete
function! s:Vimrc_AutoComplete() abort "{{{
  if get(b:, 'set_complete', 0) | return | else | let b:set_complete = 1 | endif

  for l:k in split( 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_','\zs')
    execute printf('imap <buffer><expr> %s !pumvisible() ? "%s\<C-n>\<C-p>" : "%s"', l:k, l:k, l:k)
  endfor

  imap <buffer><expr> <C-k> pumvisible() ? "\<C-e>\<C-x>\<C-o>" : "\<C-x>\<C-o>"
endfunction "}}}

" markdown indentexpr
function! Vimrc_IndentExpr_Markdown() "{{{
  if v:lnum == 1 | return -1 | endif

  let l:baseLineNum = prevnonblank(v:lnum - 1)
  let l:marker = matchstr(getline(l:baseLineNum), '^\s*\zs\([-+*]\|\d\+[\.)]\)\s\+')

  return ( l:marker !=# '' ? indent(l:baseLineNum) + len(l:marker) : -1 )
endfunction "}}}


" ***********************************************
" {{{
augroup vimrc_auto_commands
  autocmd!

  " ** filetype
  autocmd BufNewFile,BufRead *.hta setfiletype  xhtml
  autocmd BufNewFile,BufRead *.vcproj,*.sln,*.xaml setfiletype  xml
  autocmd BufRead,BufNewFile *.cas setf casl2
  autocmd BufRead,BufNewFile *.changelog setf changelog

  if has('win32')
    autocmd BufWritePre *.c,*.cpp,*.h,*.hpp,*.def,*.bat,*.ini,*.env,*.js,*.vbs,*.ps1 setlocal fenc=cp932 ff=dos
  endif

  " auto completion
  autocmd InsertEnter * call <SID>Vimrc_AutoComplete()

  " Open the quickfix window automatically
  autocmd FileType help,qf nnoremap <buffer> q <C-w>c
  autocmd CmdwinEnter *    nnoremap <buffer> q <C-w>c

  " jump and close
  autocmd FileType qf nnoremap <buffer> <expr> <S-CR> printf( "\<CR>:%sclose\<CR>",
      \ getwininfo(win_getid())[0].loclist ? 'l' : 'c' )

  " visualize wide-space ( need scriptencoding == fenc on vimrc )
  autocmd VimEnter,WinEnter * call matchadd('ZenkakuSpace', '　')
  autocmd VimEnter,WinEnter * call matchadd('TrailingSpace', '\s\{2,\}$')

  " additional colors
  autocmd VimEnter,ColorScheme * call <SID>Vimrc_HighlightPlus()

  " ***********************************************************
  autocmd FileType * let &commentstring = substitute(&commentstring, '%s', ' %s ', '')
  autocmd FileType * if &l:omnifunc == '' | setlocal omnifunc=syntaxcomplete#Complete | endif
  autocmd FileType c,cpp setlocal omnifunc=syntaxcomplete#Complete

  autocmd FileType c,cpp,cs,java,javascript 
      \ setlocal cindent cinoptions=:1s,l1,t0,(0,)0,W1s,u0,+0,g0
  autocmd FileType html,xhtml,xml,javascript,vim,markdown 
      \ setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab

  autocmd FileType javascript setlocal cinoptions+=J1
  autocmd FileType c,cpp      setlocal includeexpr=substitute(v:fname,'^\\/','','') path+=./;/
  autocmd FileType cpp        setlocal commentstring=//\ %s
  autocmd FileType dosbatch   setlocal commentstring=@rem\ %s
  autocmd FileType vim        setlocal fenc=utf8 ff=unix

  autocmd FileType markdown setlocal nosmartindent indentkeys=!^F,o,O indentexpr=Vimrc_IndentExpr_Markdown()
      \ | setlocal tabstop=4 commentstring=<!--\ %s\ -->
      \ | iabbr <buffer> -[ - [ ]

  autocmd FileType html,xhtml,xml inoremap <buffer> </ </<C-x><C-o>

  autocmd FileType casl2 setl sw=10 ts=10 sts=10
  autocmd FileType changelog setl textwidth=0
augroup END


" *****************************************************************************
function! s:calc_padding_tabs( token, align_width ) abort "{{{
  let l:ts = &tabstop
  let l:mergin = a:align_width - strdisplaywidth( a:token )

  return repeat( "\t", (( l:mergin + ( l:mergin % l:ts ? l:ts : 0 )) / l:ts ))
endfunction "}}}

function! s:calc_padding_space( token, align_width ) abort "{{{
  return repeat( ' ', a:align_width - strdisplaywidth( a:token ))
endfunction "}}}

function! s:align_token( tokens, align_width, ctx ) abort "{{{
  if len(a:tokens) > 1
    let l:token = substitute( remove( a:tokens, 0 ), '\s*$', '', '' )

    let a:tokens[0] = l:token
        \ . a:ctx.filler( l:token, a:align_width )
        \ . a:tokens[0]
  endif

  return a:tokens
endfunction "}}}

function! s:align_parse( arguments ) abort "{{{
  " ----------------
  " -g   global:        align all tokens
  " -1   1st:           align first token (default)
  " ----
  " -t   tab:           use tab ('\t')
  " -w   whitespace:    use space (' ') (default)
  " ----
  " -a   after:         align at after specified pattern
  " -h   just here:     align at specified pattern (default)
  " ----
  " -e   text:          pattern as text (default)
  " -r   regexp:        pattern as regexp
  " ----
  " -c   case sencitive:
  " ----------------
  let l:ctx = {
      \ 'pattern': '',
      \ 'global': '',
      \ 'filler': function( '<SID>calc_padding_space' ),
      \ 'sub': '\n&',
      \ 'delim': '\n'
      \ }
  let l:use_regexp = 0
  let l:case = ''

  for l:opt in a:arguments
    if     l:opt ==# '-g' | let l:ctx.global = 'g'
    elseif l:opt ==# '-1' | let l:ctx.global = ''
    elseif l:opt ==# '-t' | let l:ctx.filler = function( '<SID>calc_padding_tabs' )
    elseif l:opt ==# '-w' | let l:ctx.filler = function( '<SID>calc_padding_space' )
    elseif l:opt ==# '-a' | let l:ctx.sub = '&\n' | let l:ctx.delim = '\n\s*'
    elseif l:opt ==# '-h' | let l:ctx.sub = '\n&' | let l:ctx.delim = '\n'
    elseif l:opt ==# '-e' | let l:use_regexp = 0
    elseif l:opt ==# '-r' | let l:use_regexp = 1
    elseif l:opt ==# '-c' | let l:case = '\C'
    else                  | let l:ctx.pattern = l:opt
    endif
  endfor

  if l:use_regexp
    let l:ctx.pattern = l:case . l:ctx.pattern
  else
    let l:ctx.pattern = '\V' . l:case . escape( l:ctx.pattern, '\' )
  endif

  return l:ctx
endfunction "}}}

function! s:Vimrc_Alignment( startl, endl, arguments ) abort "{{{
  if empty( a:arguments )
    return
  endif

  let l:ctx = s:align_parse( a:arguments )
  let l:line_tokens = map( getline( a:startl, a:endl ),
      \ { key, val -> split( substitute( val, l:ctx.pattern, l:ctx.sub, l:ctx.global ), l:ctx.delim, 1 ) })
  let l:width = 0

  while max(map(copy(l:line_tokens), { key, val -> (len(val) > 1) }))
    " 
    let l:width = max( map( filter( copy( l:line_tokens ),
        \ { idx, val -> ( len( val ) > 1 ) }),
        \ { key, val -> strdisplaywidth( val[0] ) }))
    " 
    let l:line_tokens = map( l:line_tokens,
        \ { key, val -> s:align_token( val, l:width, l:ctx ) })
  endwhile

  if l:width > 0
    call setline( a:startl, map( l:line_tokens, 'v:val[0]' ))
  endif
endfunction "}}}

function! s:Vimrc_Complete_Alignment( ArgLead, CmdLine, CursorPos ) abort "{{{
  return [ '-g', '-1', '-t', '-w', '-a', '-h', '-e', '-r', '-s', '-n' ]
endfunction "}}}

command! -range -nargs=+ -complete=customlist,<SID>Vimrc_Complete_Alignment Align
    \ call <SID>Vimrc_Alignment( <line1>, <line2>, [<f-args>] )


" *****************************************************************************
function! s:escape_trim( word ) abort "{{{
  return substitute( escape( a:word, '\.*[]' ), '\v^\s*|\s$', '', 'g' )
endfunction "}}}

function! s:Vimrc_ToggleComment() abort "{{{
  let l:line = getline( '.' )
  let [l:begin, l:end] = split( &commentstring, '%s', 1 )

  if match( l:begin, '\s\+$' ) < 0
    let l:pattern = printf( '\V\^\(\s\*\)%s\(\.\*\)%s',
        \ s:escape_trim( l:begin ), s:escape_trim( l:end ))
  else
    let l:pattern = printf( '\V\^\(\s\*\)%s\%%(%s\)\?\(\.\*\)%s', 
        \ s:escape_trim( l:begin ), matchstr( l:begin, '\s\+$' ), s:escape_trim( l:end ))
  endif

  if l:line =~# l:pattern
    let l:line = substitute( l:line, l:pattern, '\1\2', '' )
  else
    let l:line = substitute( l:line, '\v^(\s*)(\S.*)', '\1' . l:begin . '\2' . l:end, '' )
  endif

  call setline( '.', l:line )
endfunction "}}}

" command! -range -nargs=0 ToggleComment call <SID>Vimrc_ToggleComment( <line1>, <line2> ) 

nnoremap <silent> gc :call <SID>Vimrc_ToggleComment()<CR>
xnoremap <silent> gc :call <SID>Vimrc_ToggleComment()<CR>


" *****************************************************************************
function! s:EncloseText_Parse( arguments ) abort "{{{
  let l:command = '-a'
  let l:Escape = { val -> '\V' . escape( val, '\' ) }
  let l:trim_ptn = ''
  let l:spacing = ''
  let l:tokens = []

  for l:arg in a:arguments
    if     l:arg =~# '^-[adr]$' | let l:command = l:arg
    elseif l:arg ==# '-g'       | let l:Escape = { val -> val }
    elseif l:arg ==# '-s'       | let l:spacing = ' '
    elseif l:arg ==# '-t'       | let l:trim_ptn = '\v\s*'
    else                        | call add( l:tokens, l:arg )
    endif
  endfor

  let l:tokens += [ '', '', '', '' ]

  if     l:command ==# '-a'
    return {
        \ 'fo': '^' . l:trim_ptn,
        \ 'fc': l:trim_ptn . '$',
        \ 'to': l:tokens[0] . l:spacing,
        \ 'tc': l:spacing . l:tokens[1]
        \ }
  elseif l:command ==# '-d'
    return {
        \ 'fo': '^' . l:Escape( l:tokens[0] ) . l:trim_ptn,
        \ 'fc': l:trim_ptn . l:Escape( l:tokens[1] ) . '\v$',
        \ 'to': '',
        \ 'tc': ''
        \ }
  elseif l:command ==# '-r'
    return {
        \ 'fo': '^' . l:Escape( l:tokens[0] ) . l:trim_ptn,
        \ 'fc': l:trim_ptn . l:Escape( l:tokens[1] ) . '\v$',
        \ 'to': l:tokens[2] . l:spacing,
        \ 'tc': l:spacing . l:tokens[3]
        \ }
  endif

  return {}
endfunction "}}}

function! s:EncloseText_Edit( text, pattern, type ) abort "{{{
  let l:edit_text = a:text

  if and( a:type, 0x01 )
    let l:edit_text = substitute( l:edit_text, a:pattern.fo, a:pattern.to, '' )
  endif

  if and( a:type, 0x02 )
    let l:edit_text = substitute( l:edit_text, a:pattern.fc, a:pattern.tc, '' )
  endif

  return l:edit_text
endfunction "}}}

function! s:Vimrc_EncloseText( arguments ) range abort "{{{
  let l:pattern = s:EncloseText_Parse(a:arguments)

  if !empty(l:pattern)
    let l:is_multi_line = ( getpos( "'<" )[1] != getpos( "'>" )[1] )

    if visualmode() ==# 'v' && is_multi_line
      keepjumps execute "'<s/\\%V.*/\\=<SID>EncloseText_Edit(submatch(0), l:pattern, 0x01)/e"
      keepjumps execute "'>s/.*\\%V.\\?/\\=<SID>EncloseText_Edit(submatch(0), l:pattern, 0x02)/e"
    else
      keepjumps execute "'<,'>s/\\%V.*\\%V./\\=<SID>EncloseText_Edit(submatch(0), l:pattern, 0x03)/e"
    endif

    execute "normal `<"
  endif
endfunction "}}}

function! s:Vimrc_Complete_EncloseText( ArgLead, CmdLine, CursorPos ) abort "{{{
  return [ '-a', '-d', '-r', '-g', '-t' ]
endfunction "}}}

command! -range -nargs=* -complete=customlist,<SID>Vimrc_Complete_EncloseText
    \ EncloseText call <SID>Vimrc_EncloseText( [ <f-args> ] )


" *****************************************************************************
function! s:Vimrc_ToggleTodoList( begin, end ) range "{{{
  silent execute printf( 'silent %d,%ds/^\s*[-+*] \zs\[\([x ]\)\]/\=(submatch(1) ==# "x" ? "[ ]" : "[x]")/',
      \ a:begin, a:end )
endfunction "}}}

command! -range -nargs=0 TodoToggle call <SID>Vimrc_ToggleTodoList( <line1>, <line2> )


" *****************************************************************************
nnoremap <silent> <Leader>d :copy .-1<CR>
xnoremap <silent> <Leader>d :copy .-1<CR>gv


" *****************************************************************************
function! s:do_command( cmdline ) abort "{{{
  if has( 'iconv' ) && ( &termencoding != &encoding )
    return iconv( system( iconv( a:cmdline, &encoding, &termencoding )), &termencoding, &encoding )
  else
    return system( a:command )
  endif
endfunction

function! s:get_qf_context( cmdline, errformat ) abort "{{{
  return {
      \ 'efm': a:errformat,
      \ 'lines': split( s:do_command( a:cmdline ), '\n' ),
      \ 'title': a:cmdline
      \ }
endfunction "}}}

function! s:quickfix_command( bang, commands, errformat ) abort "{{{
  let ctx = s:get_qf_context( join( a:commands, ' ' ), a:errformat )

  if a:bang ==# ''
    call setqflist( [], 'r', ctx )
    copen
  else
    call setloclist( 0, [], 'r', ctx )
    lopen
  endif
endfunction "}}}


" *****************************************************************************
"
command! -bang -nargs=* GTag  call <SID>quickfix_command(
    \ '<bang>', [ '(', 'global -qax', <q-args>, '&', 'global -qax -s -r', <q-args>, ')' ],
    \ '%*\S%*\s%l%\s%f%\s%m' )
command! -nargs=* LGTag GTag! <args>

if has('win32')
  command! -bang -nargs=0 Ls  call <SID>quickfix_command(
      \ '<bang>', [ 'dir /B /A:-D ', input( 'pattern: ', '' ) ], '%f' )
else
  command! -bang -nargs=0 Ls  call <SID>quickfix_command(
      \ '<bang>', [ 'ls -1 -F | grep -v /', input( 'pattern: ', '' ) ], '%f' )
endif

command! -nargs=0 LLs  Ls!


" *****************************************************************************
"
let g:vimrc_outline_commands = {
    \ 'markdown': '^#\{1,6}',
    \ 'dosini': '^\[.\+\]'
    \ }

function! s:compare_tagline( i1, i2 ) "{{{
  let l:n1 = str2nr( matchstr( a:i1, '\s\zs\d\+\ze\s' ) )
  let l:n2 = str2nr( matchstr( a:i2, '\s\zs\d\+\ze\s' ) )

  return l:n1 == l:n2 ? 0 : l:n1 > l:n2 ? 1 : -1
endfunction "}}}

function! s:simple_outline( bang, files ) "{{{
  let file = fnameescape( empty( a:files ) ? expand( '%' ) : a:files[0] )

  if has_key( g:vimrc_outline_commands, &filetype )
    silent execute printf( 'lvimgrep /%s/ %s', g:vimrc_outline_commands[ &filetype ], file )
  else
    let kind = get( { 'c': '--c-kinds=dfgpsu', 'cpp': '--c++-kinds=dfgpsucn' }, &filetype, '' )
    let lang = get( { 'cpp': 'c++', 'cs': 'c#' }, &filetype, &filetype )
    let cmdline = printf( 'ctags -x --language-force=%s %s %s', lang, kind, file )
    let what = {
        \ 'efm': '%*\S%*\s%*\S%*\s%l%\s%f%\s%m',
        \ 'lines': split( s:do_command( cmdline ), '\n' ),
        \ 'title': cmdline
        \ }
    call sort(what.lines, "<SID>compare_tagline" )
    call setloclist( 0, [], 'r', what )
  endif

  if a:bang ==# ''
      lopen
  else
      vertical topleft lopen 35
  endif

  call matchadd('Conceal', '^.\+|\d\+\%(\s*col\s*\d\+\)\?|')
endfunction "}}}

command! -bang -nargs=? -complete=file Outline call <SID>simple_outline( '<bang>', [ <q-args> ] )


" *****************************************************************************
"
function! s:buffer_command_get_output( command, arguments, ext ) abort "{{{
  let l:output = s:do_command( a:command . ' ' . join( a:arguments, ' ' ) )
  let l:output_tmp = fnamemodify( tempname() . a:ext, ':p' )

  call writefile( split( l:output, '\n' ), l:output_tmp )

  execute printf( 'silent! tabe +set\ ro %s', l:output_tmp )
endfunction "}}}

function! s:buffer_command_do( command, arguments ) abort "{{{
  echomsg s:do_command( a:command . ' ' . join( a:arguments, ' ' ) )
endfunction "}}}

command! -nargs=? -complete=dir  SvnLs     call <SID>quickfix_command( '!', [ 'svn ls ', <q-args> ], '%f' )

command! -nargs=? -complete=file SvnLog    call <SID>buffer_command_get_output( 'svn log', [ <q-args> ], '.log' )
command! -nargs=? -complete=file SvnDiff   call <SID>buffer_command_get_output( 'svn diff', [ <q-args> ], '.diff' )
command! -nargs=? -complete=file SvnBlame  call <SID>buffer_command_get_output( 'svn blame', [ <q-args> ], '.blame' )

command! -nargs=? -complete=file SvnAdd       call <SID>buffer_command_do( 'svn add', [ <q-args> ] )
command! -nargs=? -complete=file SvnRevert    call <SID>buffer_command_do( 'svn revert', [ <q-args> ] )
command! -nargs=? -complete=file SvnResolved  call <SID>buffer_command_do( 'svn resolved', [ <q-args> ] )


command! -nargs=? -complete=dir  GitLs     call <SID>quickfix_command( '!', [ 'git ls-files ', <q-args> ], '%f' )

command! -nargs=? -complete=file GitLog    call <SID>buffer_command_get_output( 'git log', [ <q-args> ], '.log' )
command! -nargs=? -complete=file GitDiff   call <SID>buffer_command_get_output( 'git diff', [ <q-args> ], '.diff' )
command! -nargs=? -complete=file GitBlame  call <SID>buffer_command_get_output( 'git blame', [ <q-args> ], '.blame' )

command! -nargs=? -complete=file GitAdd       call <SID>buffer_command_do( 'git add', [ <q-args> ] )
command! -nargs=? -complete=file GitRevert    call <SID>buffer_command_do( 'git revert', [ <q-args> ] )
command! -nargs=? -complete=file GitResolved  call <SID>buffer_command_do( 'git resolved', [ <q-args> ] )


" *****************************************************************************
"
augroup vimrc_additional_syntax
  autocmd FileType * syn match Operator /\s\zs[+\-\*\/<>=|&]\ze\s/
      \ | syn match Bold     /[{}]/
      \ | hi Bold gui=bold

  autocmd FileType c,cpp syn keyword Typedef __int16 __int32 __int64 BYTE WORD DWORD SHORT USHORT LONG ULONG
      \ | syn keyword Typedef WPARAM LPARAM BOOL TRUE FALSE WINAPI TCHAR UINT_PTR

  autocmd FileType c,cpp,java,javascript syn match Operator /;;\|[<>!|&=~+\-\*\/]=\|||\|&&\|++\|--/
      \ | syn match Operator /::\ze\w/
      \ | syn match Operator /\*\</
      \ | syn match Operator /\>\*/
      \ | syn match Statement /!\</
      \ | syn match Statement /!\ze(/
      \ | syn match Statement /\%(->\|\.\)\</

  autocmd FileType log syn match LogDateTime  /\d\{4}\/\d\{2}\/\d\{2}/
      \ | syn match LogDateTime     /\d\{4}-\d\{2}-\d\{2}/
      \ | syn match LogDateTime     /\d\{2}:\d\{2}:\d\{2}\%(\.\d\{1,3}\)\?/
      \ | syn match LogDumpNonZero  /\<\%([13-9A-F]0\|\x[1-9A-F]\)\>/
      \ | syn match LogDumpZero     /\<00\>/
      \ | syn match LogDumpSpace    /\<20\>/
      \ | syn match LogErrWord      /\cERR\%[OR]/
      \ | hi def link LogDateTime     Identifier
      \ | hi def link LogDumpZero     SpecialKey
      \ | hi def link LogDumpNonZero  String
      \ | hi def link LogDumpSpace    Comment
      \ | hi def link LogErrWord      Error

augroup END


" *****************************************************************************
"
function! Plugin_ReadTemplate_Complete( ArgLead, CmdLine, CursorPos ) abort "{{{
  if &filetype !=# ''
    let l:template_path = expand( get(g:, 'vimrc_template_path', '~/templates/'))

    return map( globpath( l:template_path, '*.' . &filetype, 0, 1 ),
        \ { idx, val -> fnamemodify( val, ':t:r' ) } )
  else
    return []
  endif
endfunction "}}}

function! s:Vimrc_ReadTemplate( files ) abort "{{{
  if &filetype !=# ''
    let l:template_path = expand( get(g:, 'vimrc_template_path', '~/templates/'))
    let l:template_path = fnamemodify( l:template_path, ':p' ) . a:files . '.' . &filetype

    execute '.r ' . l:template_path
  endif
endfunction "}}}

function! s:Vimrc_ReadTemplatePost() abort "{{{
  call setline( "'[", map( getline( "'[", "']" ), { idx, val -> 
      \ substitute( val, '%[YmdHMS]', '\=strftime(submatch(0))', 'g' ) }) )
endfunction "}}}

command! -nargs=1 -complete=customlist,Plugin_ReadTemplate_Complete Snippet 
    \ call <SID>Vimrc_ReadTemplate( <f-args> )

augroup vimrc_snippet_command
  autocmd FileReadPost * call <SID>Vimrc_ReadTemplatePost()
augroup END


" *****************************************************************************
"
function! s:find_repos_dir() abort "{{{
  let current = fnamemodify( getcwd(), ':p:h') . ';'
  let repos = map( [ '.git', '.svn', '.bzr' ], { idx, val -> finddir( val, current ) })

  if !empty( repos ) | execute 'lcd ' . fnamemodify( repos[0], ':h' ) | endif
endfunction "}}}

command! -nargs=0 Root call <SID>find_repos_dir()


" *****************************************************************************
""
let g:changelog_spacing_errors = 0
let g:changelog_dateformat = '%Y-%m-%d'
let g:changelog_username = '<localhost>'


""
nnoremap <Leader>x :TodoToggle<CR>
xnoremap <Leader>x :TodoToggle<CR>

xnoremap syy :EncloseText -a 
xnoremap sdd :EncloseText -d 
xnoremap srr :EncloseText -r 

nnoremap sn  :Snippet 

nnoremap <silent> s. :LLs<CR>


""
nnoremap <silent> <F2>    :browse e<CR>
nnoremap <silent> <C-F2>  :browse tabe<CR>
nnoremap <silent> <C-F4>  :bwipeout<CR>
nnoremap <silent> <C-s>   :update<CR>

nnoremap <silent> <F9>    :lnext<CR>zz
nnoremap <silent> <S-F9>  :lprevious<CR>zz

nnoremap <silent> <F10>   :cnext<CR>zz
nnoremap <silent> <S-F10> :cprevious<CR>zz

nnoremap <silent> <F11>   :Outline  %<CR>
nnoremap <silent> <S-F11> :Outline! %<CR>

nnoremap <silent> <F12>   :LGTag <C-r><C-w><CR>

nnoremap <silent> [b :bprev<CR>
nnoremap <silent> ]b :bnext<CR>


" *****************************************************************************
"
if !has('gui_running')
  runtime! _local_*.vim
endif

