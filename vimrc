"" vim: set ft=vim foldmethod=marker
"" vim: set et ts=2 sts=2 sw=2
if has('gui_running') && has('clientserver') && argc() && !&diff
  let servers = filter(split(serverlist(), '\n'), { idx, val -> v:servername !=# val })

  if !empty(servers)
    silent execute '!start gvim'
        \ '--servername' servers[0]
        \ '--remote-tab-silent ' join(map(copy(argv()), { key, val -> fnameescape(val) }), ' ')
    qa!
  endif
endif

""
source $VIMRUNTIME/defaults.vim


" ***********************************************
set ambiwidth=double
set encoding=utf-8
set fileformats+=mac
set fileencodings=utf-8,ucs-bom,euc-jp,eucjp-jisx0213,cp932,iso-2022-jp-3,iso-2022-jp,ucs-2le,ucs-2,cp936,default,latain1

" for win32
if has('win32')
  set makeencoding=cp932
  set termencoding=cp932
endif

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
set statusline+=%#StatusLine_Visual#%{(mode()=='s')?'\ \ SE\ ':''}
set statusline+=%#StatusLine_Modes#
set statusline+=%{(&modified?'⚡':'')}
set statusline+=%{(&readonly?'❎':'')}
set statusline+=〉
set statusline+=%#StatusLine#
set statusline+=\ %{pathshorten(bufname('%'))}  " short file name
set statusline+=%=    " right align
set statusline+=%#StatusLine_Modes#
set statusline+=§
set statusline+=%y\ %{&fileencoding}\ %{&fileformat}\   " file type + encoding + format
set statusline+=%#StatusLine_CursorPos#
set statusline+=∠\ %l,\ %v\ -\ %04B\  " line + column + char-code

set guioptions+=cM

set number
set list
set cursorline

if has('gui')
  " |¦»▸>￫↲
  let &showbreak="▸ "
  set listchars=tab:￫\ ,trail:.,extends:»,precedes:«,nbsp:%,conceal:￫
  " set listchars=tab:￫\ ,space:.,trail:.,extends:$,precedes:^,nbsp:%,conceal:@
else
  let &showbreak="> "
  set listchars=tab:>\ ,trail:.,extends:$,precedes:^,nbsp:%,conceal:.
endif

if has('conceal') | set conceallevel=1 | endif 

" set colorcolumn=120
set formatoptions+=jnmM2
set formatoptions-=l
set display=lastline
set nofixendofline
set showtabline=2
set textwidth=0
set scrolloff=0
set nowrap

set whichwrap+=h,l,<,>,[,]
set virtualedit+=block

set smarttab shiftround
set tabstop=4 shiftwidth=4 softtabstop=4

set autoindent smartindent
set copyindent preserveindent
set breakindent breakindentopt=shift:2

set complete=.,b,k,w
set completeopt=menuone,preview
set wildignorecase
set wildmode=list:full
set pumheight=16

if has('win32')
  set wildignore+=*\\.git\\*,*\\.hg\\*,*\\.svn\\*  " Windows ('noshellslash')
else
  set wildignore+=*/.git/*,*/.hg/*,*/.svn/*        " Linux/MacOSX
endif

set isfname+=(,)

set autowrite autowriteall
set autoread
set autochdir


" ***********************************************
"" history files.
set noswapfile
set viminfo=

"" switch buffer
set switchbuf=useopen,usetab
set hidden

"" word search.
set ignorecase
set smartcase

set nowrapscan
" set noincsearch
set hlsearch
set tags+=./tags;

if has('win32')
  set grepprg=findstr\ /NSR
endif

"" encrypt file.
set cryptmethod=blowfish


" ***********************************************
"" key mappings
" 
function! Vimrc_AutoComplete_Key(chr) "{{{
  return a:chr . ( pumvisible() ? '' : "\<C-X>\<C-P>\<C-N>")
endfunction "}}}

for k in split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_",'\zs')
  exec printf("imap <silent> <expr> %s Vimrc_AutoComplete_Key('%s')", k, k)
endfor

""
let maplocalleader="\<Space>"

inoremap <expr> <CR>  pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
inoremap <expr> <C-n> pumvisible() ? "\<Down>" : "\<C-n>"
inoremap <expr> <C-p> pumvisible() ? "\<Up>" : "\<C-p>"

" a"/a'/a` trim whitespaces, a(/a{/a[ don't trim whitespaces.
vnoremap a" 2i"
vnoremap a' 2i'
vnoremap a` 2i`

onoremap a" 2i"
onoremap a' 2i'
onoremap a` 2i`

"" blackhole
nnoremap <silent> d "_d
nnoremap <silent> D "_D
vnoremap <silent> d "_d

"" compatible D
nnoremap <silent> Y y$

"" clipboard
if has('clipboard') && 0
  set clipboard&
  set clipboard+=unnamed,unnamedplus
else
  nnoremap <silent> gp "*p
  nnoremap <silent> gP "*P

  nnoremap <silent> gy "*y
  nnoremap <silent> gY "*y$

  nnoremap <silent> gx "*x
  nnoremap <silent> gX "*X

  vnoremap <silent> gp "*p
  vnoremap <silent> gy "*y
  vnoremap <silent> gx "*x
endif

" visual replace
vnoremap <silent> _ "0p`<

"" switch modes.
nnoremap <silent> <LocalLeader>e :setl expandtab! expandtab?<CR>
nnoremap <silent> <LocalLeader>h :setl hlsearch!  hlsearch?<CR>
nnoremap <silent> <LocalLeader>r :setl readonly!  modifiable! modifiable?<CR>
nnoremap <silent> <LocalLeader>w :setl wrap!      wrap?<CR>
nnoremap <silent> <LocalLeader>s :setl wrapscan!  wrapscan?<CR>
nnoremap <silent> <LocalLeader>i :setl incsearch! incsearch?<CR>
nnoremap <silent> <LocalLeader>l :setl relativenumber! relativenumber?<CR>

" buffer
nnoremap <silent> [b :bprev<CR>
nnoremap <silent> ]b :bnext<CR>

" window
nnoremap <silent> <C-Down>  <C-w>j
nnoremap <silent> <C-Up>    <C-w>k
nnoremap <silent> <C-Left>  <C-w>h
nnoremap <silent> <C-Right> <C-w>l

inoremap <silent> <C-Down>  <C-o><C-w>j
inoremap <silent> <C-Up>    <C-o><C-w>k
inoremap <silent> <C-Left>  <C-o><C-w>h
inoremap <silent> <C-Right> <C-o><C-w>l

" text operations
nnoremap <silent> <LocalLeader>d :copy .-1<CR>
vnoremap <silent> <LocalLeader>d :copy '<-1<CR>gv

nnoremap <silent> <C-k> :move .-2<CR>
nnoremap <silent> <C-j> :move .+1<CR>

vnoremap <silent> <C-k> :move '<-2<CR>gv
vnoremap <silent> <C-j> :move '>+1<CR>gv

" hints
function! Vimrc_Register_hints(prefix, cmd) abort
  echo execute(a:cmd)

  return a:prefix . nr2char(getchar())
endfunction

" カーソル位置のマーク
nnoremap <expr> <LocalLeader>m  Vimrc_Register_hints('m', 'marks')
" マーク位置へのジャンプ
nnoremap <expr> <LocalLeader>`  Vimrc_Register_hints('`', 'marks')
" レジスタ参照（ヤンクや削除）
nnoremap <expr> <LocalLeader>"  Vimrc_Register_hints('"', 'registers')
" マクロ記録
nnoremap <expr> <LocalLeader>q  Vimrc_Register_hints('q', 'registers')
" マクロ再生
nnoremap <expr> <LocalLeader>@  Vimrc_Register_hints('@', 'registers')


" ***********************************************
inoreabbr -d <C-r>=strftime('%Y-%m-%d')<CR>
inoreabbr /d <C-r>=strftime('%Y/%m/%d')<CR>
inoreabbr -t <C-r>=strftime('%H:%M')<CR>
inoreabbr -f <C-r>=strftime('%Y-%m-%dT%H:%M')<CR>
inoreabbr /f <C-r>=strftime('%Y/%m/%dT%H:%M')<CR>


" ***********************************************
"" utility commands
"" tempolaly buffer.
command! -nargs=? -complete=filetype Temp 
    \ execute printf('tabe %s_%s | setf %s', tempname(), strftime('%Y-%m-%d_%H-%M-%S'),
    \   ('<args>' ==# '' ? (&filetype ==# 'qf' ? 'text' : &filetype) : '<args>'))

"" rename
"" <http://d.hatena.ne.jp/fuenor/20100115/1263551230>
command! -nargs=+ -bang -complete=file Rename
    \ let pbnr=fnamemodify(bufname('%'), ':p') | exec 'f '.escape(<q-args>, ' ') | w<bang> | call delete(pbnr)

command! -bang BufOnly 
    \ let bnrs = join(filter(range(1, bufnr('$')), {
    \   idx, val -> bufexists(val) && val != bufnr('%')
    \ }), ' ') |
    \ if bnrs !=# '' | execute 'bw<bang> ' . bnrs | endif

command! -bang BufClear bufdo bw<bang>

command! -bang BufTidyUp 
    \ let bnrs = range(1, bufnr('$'))
    \   ->filter({ idx, val -> bufexists(val) && bufloaded(val) })
    \   ->filter({ idx, val -> get(get(getbufinfo(val), 0, {}), 'hidden', 0) })
    \   ->join(' ') |
    \ if bnrs !=# '' | execute 'bw<bang> ' . bnrs | endif

command! -nargs=1 -complete=dir LcdX
    \ execute 'lcd ' . fnamemodify(<f-args>, ':p',)


" ***********************************************
"" other options
"" *ft-c-syntax* spedial syntax
let c_gnu = 1  " GNU gcc固有の要素
let c_comment_strings = 1  " コメント内の文字列と数値
let c_space_errors = 1  " 行末の空白文字とタブ文字前のスペース文字
let c_no_tab_space_error = 1  "  ... 但しタブ文字前のスペース文字は除外
let c_no_bracket_error = 1  " []の中の{}をエラーとして表示しない
let c_no_curly_error = 1  " { と } が第1桁にあるときを除き、[] と () の内側の {} をエラーとして表示しない。 デフォルトでエラーとして表示される。欠落した ')' を見つけられないため。

"" menu
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
let g:loaded_2html_plugin = 1
let g:loaded_vimball = 1
let g:loaded_vimballPlugin = 1
let g:loaded_getscript = 1
let g:loaded_getscriptPlugin = 1

" let g:loaded_netrw = 1 
" let g:loaded_netrwPlugin = 1 
" let g:loaded_netrwSettings = 1
" let g:loaded_netrwFileHandlers = 1

" let g:loaded_matchparen = 1 

let g:vim_indent_cont = 4

" ***********************************************
"" utility functions
function! s:Vimrc_HighlightPlus() abort "{{{
  " ime
  hi CursorIM gui=NONE guifg=#FFFFFF guibg=#8000FF ctermbg=White ctermbg=Red

  if !has('gui_running')
    hi clear CursorLine
    hi CursorLine term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE
  endif

  " statusline
  hi StatusLine_Modes      guifg=#030303 guibg=#FFFFFF ctermfg=Black ctermbg=White
  hi StatusLine_CursorPos  guifg=#FFFFFF guibg=#333399 ctermfg=White ctermbg=DarkBlue

  hi StatusLine_Normal     guifg=#FFFFFF guibg=#0000FF ctermfg=White ctermbg=Blue
  hi StatusLine_Insert     guifg=#FFFFFF guibg=#009944 ctermfg=White ctermbg=Green
  hi StatusLine_Replace    guifg=#FFFFFF guibg=#9933A3 ctermfg=White ctermbg=Cyan
  hi StatusLine_Visual     guifg=#FFFFFF guibg=#F20000 ctermfg=White ctermbg=Red
  hi StatusLine_Select     guifg=#030303 guibg=#F2F200 ctermfg=Black ctermbg=Yellow

  hi link TrailingSpace NonText

  if &g:background ==# 'dark'
    hi SpecialKey   gui=NONE      guifg=#808080  guibg=NONE ctermfg=grey 
    hi ZenkakuSpace gui=underline guifg=darkgrey cterm=underline ctermfg=darkgrey
    hi NormalNC                   guifg=#808080  guibg=#606060

  else
    hi SpecialKey   gui=NONE      guifg=#cccccc  guibg=NONE ctermfg=grey 
    hi ZenkakuSpace gui=underline guifg=grey cterm=underline ctermfg=grey
    hi NormalNC                   guifg=#cccccc  guibg=#dddddd

  endif
endfunction "}}}

" markdown indentexpr
function! Vimrc_Markdown_IndentExpr() "{{{
  if v:lnum == 1 | return -1 | endif

  let baseLineNum = prevnonblank(v:lnum - 1)
  let marker = matchstr(getline(baseLineNum), '^\s*\zs\([-+*]\|\d\+[\.)]\)\s\+')
  let offset = ( &expandtab ? len(marker) : &shiftwidth )

  return (marker !=# '' ? indent(baseLineNum) + offset : -1)
endfunction "}}}


" ***********************************************
" {{{
augroup vimrc_auto_commands
  autocmd!

  "
  autocmd QuickFixCmdPost grep,grepadd,vimgrep topleft copen
  autocmd QuickFixCmdPost lgrep,lgrepadd,lvimgrep topleft lopen

  "
  " autocmd WinEnter,BufWinEnter * setlocal wincolor=
  " autocmd WinLeave             * setlocal wincolor=NormalNC
  autocmd WinEnter,BufWinEnter * setlocal cursorline
  autocmd WinLeave             * setlocal nocursorline

  "
  if has('win32')
    autocmd BufWritePre *.c,*.cpp,*.h,*.hpp,*.def,*.bat,*.ini,*.env,*.js,*.vbs,*.ps1 setl fenc=cp932 ff=dos
  endif

  " Open the quickfix window automatically
  autocmd FileType help,qf nnoremap <buffer> q :pclose<CR><C-w>c
  autocmd CmdwinEnter *    nnoremap <buffer> q <C-w>c

  " additional colors
  autocmd VimEnter,ColorScheme * call <SID>Vimrc_HighlightPlus()

  " visualize wide-space (need scriptencoding == fenc on vimrc)
  autocmd VimEnter,WinEnter * hi def Bold gui=bold
      \ | hi def DateTime gui=bold,underline
      \ | call matchadd('ZenkakuSpace', '　')
      \ | call matchadd('TrailingSpace', '\s\{2,\}$')
      \ | call matchadd('DateTime', '[12]0\d\{2}-\%(1[0-2]\|0[1-9]\)-\%(3[01]\|[12][0-9]\|0[1-9]\)')
      \ | call matchadd('DateTime', '[12]0\d\{2}\/\%(1[0-2]\|0[1-9]\)\/\%(3[01]\|[12][0-9]\|0[1-9]\)')
      \ | call matchadd('DateTime', '\%(2[0-3]\|[0-1][0-9]\):\%([0-5][0-9]\)\%(:\%([0-5][0-9]\)\%(\.\d\{1,3}\)\?\)\?')

  " ***********************************************************
  autocmd FileType * let &commentstring = substitute(&commentstring, '%s', ' %s ', '')
  autocmd FileType * if &l:omnifunc == '' | setl omnifunc=syntaxcomplete#Complete | endif
  autocmd FileType c,cpp setl omnifunc=syntaxcomplete#Complete

  autocmd FileType c,cpp,cs,java,javascript setl
      \ cindent cinoptions=:1s,l1,t0,(0,)0,W1s,u0,+0,g0
  autocmd FileType html,xhtml,xml,javascript,vim
      \ setl tabstop=2 softtabstop=2 shiftwidth=2 expandtab

  autocmd FileType javascript setl cinoptions+=J1
  autocmd FileType cpp        setl commentstring=//\ %s
  autocmd FileType dosbatch   setl commentstring=@rem\ %s
  autocmd FileType vim        setl fenc=utf8 ff=unix

  autocmd FileType markdown setl
      \ tabstop=2 softtabstop=2 shiftwidth=2 wrap
      \ nosmartindent indentkeys=!^F,o,O indentexpr=Vimrc_Markdown_IndentExpr()
      \ commentstring=<!--\ %s\ -->
      \ | inoreabbr <buffer> -[ - [ ]

  autocmd FileType html,xhtml,xml inoremap <buffer> </ </<C-x><C-o>

  autocmd FileType casl2 setl sw=10 ts=10 sts=10
  autocmd FileType changelog setl textwidth=0
  autocmd FileType todotxt setl concealcursor=n conceallevel=1
augroup END


" *****************************************************************************
"
command! -range -nargs=0 GfmTodo call call({ begin, end -> 
    \ execute(printf('silent! %d,%ds/^\s*[-+*]\s\zs\[[x ]\]/\=(submatch(0) ==# "[x]" ? "[ ]" : "[x]")/', begin, end)) },
    \ [ <line1>, <line2> ])


" *****************************************************************************
"
command! -range -nargs=0 IndentAtHead call call({ begin, end -> 
    \ execute(printf('silent! %d,%ds/^\ze./%s/', begin, end, (&expandtab ? repeat(' ',&sw) : '\t'))) },
    \ [ <line1>, <line2> ])

command! -range -nargs=0 UnIndentAtHead call call({ begin, end -> 
    \ execute(printf('silent! %d,%ds/^%s//', begin, end, (&expandtab ? repeat(' ',&sw) : '\t'))) },
    \ [ <line1>, <line2> ])


" *****************************************************************************
function! s:vimrc_comment_toggle(first_line, last_line) abort "{{{
  let [cbegin, cend] = split(escape(&commentstring, '/?'), '\s*%s\s*', 1)
  let pattern = printf('^\(\s*\)\V%s\m\s\?\(.*\)\s\?\V%s', cbegin, cend)

  for ln in range(a:first_line, a:last_line)
    let line = getline(ln)
    if line =~# pattern
      execute printf('%ds/%s/\1\2/', ln, pattern)
    elseif line !=# ''
      execute printf('%ds/\v^(\s*)(\S.*)/\1%s%s\2%s%s/',
          \ ln, cbegin, (empty(cbegin) ? '' : ' '), (empty(cend) ? '' : ' '), cend)
    endif
  endfor
endfunction "}}}

command! -range -nargs=0 CommentToggleLine call <SID>vimrc_comment_toggle(<line1>, <line2>) 


" *****************************************************************************
"
augroup vimrc_additional_syntax
  autocmd FileType c,cpp
      \   syn keyword Type __int16 __int32 __int64 __fastcall
      \ | syn keyword Type int16_t uint16_t int32_t uint32_t int64_t uint64_t
      \ | syn keyword Typedef BYTE WORD DWORD SHORT USHORT LONG ULONG LONGLONG ULONGLONG
      \ | syn keyword Typedef WPARAM LPARAM WINAPI UINT_PTR
      \ | syn keyword Boolean BOOL TRUE FALSE

  autocmd FileType c,cpp,cs,java,javascript 
      \   syn match Operator /\s\zs[+\-\*\/<>=|&]\ze\s/
      \ | syn match Operator /;/
      \ | syn match Operator /[<>!=~+\-\*\/]=/
      \ | syn match Operator /||\|&&\|++\|--/
      \ | syn match Operator /::\ze\w/
      \ | syn match Operator /\>[\*&]/
      \ | syn match Operator /\*\</
      \ | syn match Operator /[!&]\s*\</
      \ | syn match Operator /[!&]\s*\ze(/
      \ | syn match Operator /\%(->\|\.\)\</
      " \ | syn match Bold /[{}]/

  autocmd FileType log 
      \ | syn match LogDumpNonZero /\<\%([13-9A-F]0\|\x[1-9A-F]\)\>/
      \ | syn match LogDumpZero    /\<00\>/
      \ | syn match LogDumpSpace   /\<20\>/
      \ | syn match LogErrWord     /\cERR\%[OR]/
      \ | hi def link LogDumpZero    SpecialKey
      \ | hi def link LogDumpNonZero String
      \ | hi def link LogDumpSpace   Comment
      \ | hi def link LogErrWord     Error

augroup END


" *****************************************************************************
"
function! s:find_repos_dir() abort "{{{
  let current = fnamemodify(getcwd(), ':p:h') . ';'
  let repos = map([ '.git', '.svn', '.bzr' ], { idx, val -> finddir(val, current) })

  if !empty(repos) | execute 'lcd ' . fnamemodify(repos[0], ':h') | endif
endfunction "}}}

command! -nargs=0 Root call <SID>find_repos_dir()


" *****************************************************************************
""
function! s:vimrc_ShowCmdLine(height) "{{{
  let h_ = max([ 3, min([ str2nr(a:height), ((&lines * 9) / 10) ]) ])
  let w_ = (&columns * 9) / 10

  call popup_create(
    \ term_start([&shell], #{ hidden: 1, term_finish: 'close'}),
    \ #{ border: [], fixed: 1, minwidth: w_, minheight: h_, maxwidth: w_, maxheight: h_ })
endfunction "}}}

command! -nargs=? Cmdline call <SID>vimrc_ShowCmdLine(<q-args>)


" *****************************************************************************
""
nnoremap <silent> g> :IndentAtHead<CR>
vnoremap <silent> g> :IndentAtHead<CR>

nnoremap <silent> g< :UnIndentAtHead<CR>
vnoremap <silent> g< :UnIndentAtHead<CR>

nnoremap <silent> <C-q> :CommentToggleLine<CR>
vnoremap <silent> <C-q> :CommentToggleLine<CR>

nnoremap <silent> <LocalLeader>x :GfmTodo<CR>
vnoremap <silent> <LocalLeader>x :GfmTodo<CR>


" *****************************************************************************
"
packadd! matchit
packadd! cfilter

augroup plugin_cfilter_autocmd
  autocmd FileType qf nnoremap <buffer> <expr> i printf(":%sfilter /%s/\<CR>",
      \ getwininfo(win_getid())[0].loclist ? 'L' : 'C', input('>', ''))
augroup END

if !has('gui_running')
  runtime! _local_*.vim
endif

