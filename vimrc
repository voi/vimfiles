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
set statusline+=%#StatusLine_Modes#
set statusline+=%{(&modified?'⚡':'')}
set statusline+=%{(&readonly?'❎':'')}
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

if has('gui')
  " |¦»▸>￫↲
  let &showbreak="▸ "
  set listchars=tab:»\ ,trail:.,extends:»,precedes:«,nbsp:%,conceal:￫
  " set listchars=tab:»\ ,space:.,trail:.,extends:$,precedes:^,nbsp:%,conceal:@
else
  let &showbreak="> "
  set listchars=tab:>\ ,trail:.,extends:$,precedes:^,nbsp:%,conceal:.
endif

if has('conceal') | set conceallevel=1 | endif 

set colorcolumn=120
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

set complete=.,b,k
set wildignorecase
set wildmode=list:full
set pumheight=32

if has('win32')
  set wildignore+=*\\.git\\*,*\\.hg\\*,*\\.svn\\*  " Windows ('noshellslash')
else
  set wildignore+=*/.git/*,*/.hg/*,*/.svn/*        " Linux/MacOSX
endif

set isfname+=(,)

set autowrite autowriteall
set autoread
set autochdir

if has('clipboard')
  set clipboard=
endif


" ***********************************************
"" history files.
set noswapfile
" set viminfo=

"" switch buffer
set switchbuf=useopen,usetab
set hidden

"" word search.
set grepprg=internal
set ignorecase
set smartcase

set hlsearch
set tags+=./tags;

"" encrypt file.
set cryptmethod=blowfish


" ***********************************************
"" key mappings
" a"/a'/a` trim whitespaces, a(/a{/a[ don't trim whitespaces.
vnoremap a" 2i"
vnoremap a' 2i'
vnoremap a` 2i`

onoremap a" 2i"
onoremap a' 2i'
onoremap a` 2i`

"" blackhole
nnoremap <silent> d "_d
vnoremap <silent> d "_d

"" home-key del
inoremap <silent> <C-l> <Del>

"" compatible D
nnoremap <silent> Y y$

"" clipboard
if has('clipboard')
  nnoremap <silent> gy "*y
  nnoremap <silent> gY "*y$
  nnoremap <silent> gx "*x
  nnoremap <silent> gp "*p
  nnoremap <silent> gP "*P

  vnoremap <silent> gy "*y
  vnoremap <silent> gx "*x
  vnoremap <silent> gp "*p
  vnoremap <silent> gP "*P
endif

" visual replace
vnoremap <silent> _ "0p`<

"" switch modes.
nnoremap <silent> <Leader>e :setl expandtab! expandtab?<CR>
nnoremap <silent> <Leader>h :setl hlsearch!  hlsearch?<CR>
nnoremap <silent> <Leader>r :setl readonly!  modifiable! modifiable?<CR>
nnoremap <silent> <Leader>w :setl wrap!      wrap?<CR>
nnoremap <silent> <Leader>s :setl wrapscan!  wrapscan?<CR>

" error jumps.
nnoremap <silent> cp :lprevious<CR>zz
nnoremap <silent> cn :lnext<CR>zz

nnoremap <silent> ck :cprevious<CR>zz
nnoremap <silent> cj :cnext<CR>zz

" buffer
nnoremap <silent> [b :bprev<CR>
nnoremap <silent> ]b :bnext<CR>

" window
nnoremap <silent> sj <C-w>j
nnoremap <silent> sk <C-w>k
nnoremap <silent> sh <C-w>h
nnoremap <silent> sl <C-w>l
nnoremap <silent> sp <C-w>p

" text operations
nnoremap <silent> <Leader>d :copy .-1<CR>
vnoremap <silent> <Leader>d :'<,'>copy '<-1<CR>gv

nnoremap <silent> <C-k> :move .-2<CR>
nnoremap <silent> <C-j> :move .+1<CR>

vnoremap <silent> <C-k> :'<,'>move '<-2<CR>gv
vnoremap <silent> <C-j> :'<,'>move '>+1<CR>gv

" hints
function! Vimrc_Register_hints(prefix, cmd) abort
  echo execute(a:cmd)

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
inoreabbr -d <C-r>=strftime('%Y-%m-%d')<CR>
inoreabbr /d <C-r>=strftime('%Y/%m/%d')<CR>
inoreabbr -t <C-r>=strftime('%H:%M:%s')<CR>


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

command! -nargs=1 -complete=dir LcdX
    \ execute 'lcd ' . fnamemodify(<f-args>, ':p',)


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

" let g:loaded_netrw = 1 
" let g:loaded_netrwPlugin = 1 
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
    highlight SpecialKey   gui=NONE      guifg=#808080  guibg=bg ctermfg=grey 
    highlight ZenkakuSpace gui=underline guifg=darkgrey term=underline ctermfg=darkgrey

  else
    highlight SpecialKey   gui=NONE      guifg=#cccccc  guibg=NONE ctermfg=grey 
    highlight ZenkakuSpace gui=underline guifg=grey cterm=underline ctermfg=grey

  endif
endfunction "}}}

call <SID>Vimrc_HighlightPlus()

" markdown indentexpr
function! Vimrc_Markdown_IndentExpr() "{{{
  if v:lnum == 1 | return -1 | endif

  let l:baseLineNum = prevnonblank(v:lnum - 1)
  let l:marker = matchstr(getline(l:baseLineNum), '^\s*\zs\([-+*]\|\d\+[\.)]\)\s\+')

  return (l:marker !=# '' ? indent(l:baseLineNum) + len(l:marker) : -1)
endfunction "}}}

function! Vimrc_CLang_IncludeExpr(fname) "{{{
  return get(split(system('global -P -a ' . a:fname), '\n'), 0, a:fname)
endfunction "}}}

function! Vimrc_CLang_TagFunc(pattern, flag, info) "{{{
  let cmd = (a:flag ==# 'i') ?
      \ printf('global -qat -g %s', a:pattern) :
      \ printf('global -qat %s & global -qat -rs %s', a:pattern, a:pattern)
  let lines = split(system(cmd), '\n')
  let lines = map(lines, { idx, val -> split(substitute(val, '^\(\w\+\)\s\+\(\S.*\S\)\s\+\(\d\+\)$', '\1\t\2\t\3', ''), '\t') })

  return map(lines, { idx, val -> { 'name': get(val, 0, ''), 'filename': get(val, 1, ''), 'cmd':get(val, 2, '') } })
endfunction "}}}


" ***********************************************
" {{{
augroup vimrc_auto_commands
  autocmd!

  " ** filetype
  autocmd BufNewFile,BufRead *.vcproj,*.sln,*.xaml setf xml
  autocmd BufRead,BufNewFile *.cas setf casl2

  if has('win32')
    autocmd BufWritePre *.c,*.cpp,*.h,*.hpp,*.def,*.bat,*.ini,*.env,*.js,*.vbs,*.ps1 setl fenc=cp932 ff=dos
  endif

  " Open the quickfix window automatically
  autocmd FileType help,qf nnoremap <buffer> q :pclose<CR><C-w>c
  autocmd CmdwinEnter *    nnoremap <buffer> q <C-w>c

  " jump and close
  autocmd FileType qf nnoremap <buffer> <CR> :pclose<CR><CR>
  autocmd FileType qf nnoremap <buffer> <expr> <C-P> printf(":%solder\<CR>",
      \ getwininfo(win_getid())[0].loclist ? 'l' : 'c')
  autocmd FileType qf nnoremap <buffer> <expr> <C-N> printf(":%snewer\<CR>",
      \ getwininfo(win_getid())[0].loclist ? 'l' : 'c')

  " visualize wide-space (need scriptencoding == fenc on vimrc)
  autocmd VimEnter,WinEnter * hi def Bold gui=bold
      \ | call matchadd('ZenkakuSpace', '　')
      \ | call matchadd('TrailingSpace', '\s\{2,\}$')
      \ | call matchadd('Identifier', '[12]0\d\{2}-\%(1[0-2]\|0[1-9]\)-\%(3[01]\|[12][0-9]\|0[1-9]\)')
      \ | call matchadd('Identifier', '[12]0\d\{2}\/\%(1[0-2]\|0[1-9]\)\/\%(3[01]\|[12][0-9]\|0[1-9]\)')
      \ | call matchadd('Identifier', '\%(2[0-3]\|1[0-9]\|0[1-9]\):\%([0-5][0-9]\)\%(:\%([0-5][0-9]\)\%(\.\d\{1,3}\)\?\)\?')
      \ | call matchadd('Bold', '[{}]')

  " additional colors
  autocmd VimEnter,ColorScheme * call <SID>Vimrc_HighlightPlus()

  " ***********************************************************
  autocmd FileType * let &commentstring = substitute(&commentstring, '%s', ' %s ', '')
  autocmd FileType * if &l:omnifunc == '' | setl omnifunc=syntaxcomplete#Complete | endif
  autocmd FileType c,cpp setl omnifunc=syntaxcomplete#Complete

  autocmd FileType c,cpp,cs,java,javascript setl
      \ cindent cinoptions=:1s,l1,t0,(0,)0,W1s,u0,+0,g0
  autocmd FileType html,xhtml,xml,javascript,vim,markdown 
      \ setl tabstop=2 shiftwidth=2 softtabstop=2 expandtab

  autocmd FileType javascript setl cinoptions+=J1
  autocmd FileType c,cpp      setl path+=./;/
      \ includeexpr=Vimrc_CLang_IncludeExpr(v:fname)
      \ tagfunc=Vimrc_CLang_TagFunc
  autocmd FileType cpp        setl commentstring=//\ %s
  autocmd FileType dosbatch   setl commentstring=@rem\ %s
  autocmd FileType vim        setl fenc=utf8 ff=unix

  autocmd FileType markdown setl
      \ nosmartindent indentkeys=!^F,o,O indentexpr=Vimrc_Markdown_IndentExpr()
      \ tabstop=4 commentstring=<!--\ %s\ -->
      \ | inoreabbr <buffer> -[ - [ ]

  autocmd FileType html,xhtml,xml inoremap <buffer> </ </<C-x><C-o>

  autocmd FileType casl2 setl sw=10 ts=10 sts=10
  autocmd FileType changelog setl textwidth=0
augroup END


" *****************************************************************************
function! s:calc_padding_tabs(token, align_width) abort "{{{
  let l:ts = &tabstop
  let l:align_width = (a:align_width % l:ts == 0) ? a:align_width :
      \ ((a:align_width + l:ts) / l:ts) * l:ts
  let l:mergin = l:align_width - strdisplaywidth(a:token)

  return repeat("\t", ((l:mergin + (l:mergin % l:ts ? l:ts : 0)) / l:ts))
endfunction "}}}

function! s:calc_padding_space(token, align_width) abort "{{{
  return repeat(' ', a:align_width - strdisplaywidth(a:token))
endfunction "}}}

function! s:align_token(tokens, align_width, ctx) abort "{{{
  if len(a:tokens) > 1
    let l:token = substitute(remove(a:tokens, 0), '\s*$', '', '')

    let a:tokens[0] = l:token
        \ . a:ctx.filler(l:token, a:align_width)
        \ . a:tokens[0]
  endif

  return a:tokens
endfunction "}}}

function! s:align_parse(arguments) abort "{{{
  let l:ctx = {
      \ 'pattern': '',
      \ 'global': '',
      \ 'filler': function('<SID>calc_padding_space'),
      \ 'sub': '\n&',
      \ 'delim': '\n'
      \ }
  let l:use_regexp = 0
  let l:case = ''

  for l:opt in a:arguments
    if     l:opt ==# '-g' | let l:ctx.global = 'g'
    elseif l:opt ==# '-t' | let l:ctx.filler = function('<SID>calc_padding_tabs')
    elseif l:opt ==# '-a' | let l:ctx.sub = '&\n' | let l:ctx.delim = '\n\s*'
    elseif l:opt ==# '-r' | let l:use_regexp = 1
    elseif l:opt ==# '-c' | let l:case = '\C'
    else                  | let l:ctx.pattern = l:opt
    endif
  endfor

  if l:use_regexp
    let l:ctx.pattern = l:case . l:ctx.pattern
  else
    let l:ctx.pattern = '\V' . l:case . escape(l:ctx.pattern, '\')
  endif

  return l:ctx
endfunction "}}}

function! s:Vimrc_Alignment(startl, endl, arguments) abort "{{{
  if empty(a:arguments)
    return
  endif

  let l:ctx = s:align_parse(a:arguments)
  let l:line_tokens = map(getline(a:startl, a:endl),
      \ { key, val -> split(substitute(val, l:ctx.pattern, l:ctx.sub, l:ctx.global), l:ctx.delim, 1) })
  let l:width = 0

  while max(map(copy(l:line_tokens), { key, val -> (len(val) > 1) }))
    " 
    let l:width = max(map(filter(copy(l:line_tokens),
        \   { idx, val -> (len(val) > 1) }),
        \ { key, val -> strdisplaywidth(val[0]) }))
    " 
    let l:line_tokens = map(l:line_tokens,
        \ { key, val -> s:align_token(val, l:width, l:ctx) })
  endwhile

  if l:width > 0
    call setline(a:startl, map(l:line_tokens, 'v:val[0]'))
  endif
endfunction "}}}

function! s:Vimrc_Complete_Alignment(ArgLead, CmdLine, CursorPos) abort "{{{
  return [ '-g', '-t', '-a', '-r', '-c' ]
endfunction "}}}

command! -range -nargs=+ -complete=customlist,<SID>Vimrc_Complete_Alignment Align
    \ call <SID>Vimrc_Alignment(<line1>, <line2>, [<f-args>])


" *****************************************************************************
function! s:Vimrc_ToggleComment(first_line, last_line) abort "{{{
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

command! -range -nargs=0 CommentIt call <SID>Vimrc_ToggleComment(<line1>, <line2>) 


" *****************************************************************************
function! s:EncloseText_Parse(arguments) abort "{{{
  let l:command = '-a'
  let l:Escape = { val -> '\V' . escape(val, '\') }
  let l:trim_ptn = ''
  let l:spacing = ''
  let l:tokens = []

  for l:arg in a:arguments
    if     l:arg =~# '^-[adr]$' | let l:command = l:arg
    elseif l:arg ==# '-g'       | let l:Escape = { val -> val }
    elseif l:arg ==# '-s'       | let l:spacing = ' '
    elseif l:arg ==# '-t'       | let l:trim_ptn = '\v\s*'
    else                        | call add(l:tokens, l:arg)
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
        \ 'fo': '^' . l:Escape(l:tokens[0]) . l:trim_ptn,
        \ 'fc': l:trim_ptn . l:Escape(l:tokens[1]) . '\v$',
        \ 'to': '',
        \ 'tc': ''
        \ }
  elseif l:command ==# '-r'
    return {
        \ 'fo': '^' . l:Escape(l:tokens[0]) . l:trim_ptn,
        \ 'fc': l:trim_ptn . l:Escape(l:tokens[1]) . '\v$',
        \ 'to': l:tokens[2] . l:spacing,
        \ 'tc': l:spacing . l:tokens[3]
        \ }
  endif

  return {}
endfunction "}}}

function! s:EncloseText_Edit(text, pattern, type) abort "{{{
  let l:edit_text = a:text

  if and(a:type, 0x01)
    let l:edit_text = substitute(l:edit_text, a:pattern.fo, a:pattern.to, '')
  endif

  if and(a:type, 0x02)
    let l:edit_text = substitute(l:edit_text, a:pattern.fc, a:pattern.tc, '')
  endif

  return l:edit_text
endfunction "}}}

function! s:Vimrc_EncloseText(arguments) range abort "{{{
  let l:pattern = s:EncloseText_Parse(a:arguments)

  if !empty(l:pattern)
    let l:is_multi_line = (getpos("'<")[1] != getpos("'>")[1])

    if visualmode() ==# 'v' && is_multi_line
      keepjumps execute "'<s/\\%V.*/\\=<SID>EncloseText_Edit(submatch(0), l:pattern, 0x01)/e"
      keepjumps execute "'>s/.*\\%V.\\?/\\=<SID>EncloseText_Edit(submatch(0), l:pattern, 0x02)/e"
    else
      keepjumps execute "'<,'>s/\\%V.*\\%V./\\=<SID>EncloseText_Edit(submatch(0), l:pattern, 0x03)/e"
    endif

    execute "normal `<"
  endif
endfunction "}}}

function! s:Vimrc_Complete_EncloseText(ArgLead, CmdLine, CursorPos) abort "{{{
  return [ '-a', '-d', '-r', '-g', '-t' ]
endfunction "}}}

command! -range -nargs=* -complete=customlist,<SID>Vimrc_Complete_EncloseText
    \ EncloseText call <SID>Vimrc_EncloseText([ <f-args> ])


" *****************************************************************************
command! -range -nargs=0 GfmTodo call call({ begin, end -> 
    \ execute(printf('silent %d,%ds/^\s*[-+*] \zs\[[x ]\]/\=(submatch(0) ==# "[x]" ? "[ ]" : "[x]")/', begin, end)) },
    \ [ <line1>, <line2> ])


" *****************************************************************************
command! -range -nargs=0 IndentLine call call({ begin, end -> 
    \ execute(printf('silent %d,%ds/^\ze./%s/', begin, end, (&expandtab ? repeat(' ',&sw) : '\t'))) },
    \ [ <line1>, <line2> ])

command! -range -nargs=0 UnIndentLine call call({ begin, end -> 
    \ execute(printf('silent %d,%ds/^%s//', begin, end, (&expandtab ? repeat(' ',&sw) : '\t'))) },
    \ [ <line1>, <line2> ])


" *****************************************************************************
function! s:do_command(cmdline) abort "{{{
  if has('iconv') && (&termencoding != &encoding)  
    return iconv(system(iconv(a:cmdline, &encoding, &termencoding)), &termencoding, &encoding)
  else  
    return system(a:cmdline)
  endif  
endfunction

function! s:set_and_open_quickfix(what, colors, is_loc) "{{{
  if a:is_loc
    call setloclist(0, [], ' ', a:what)
    execute 'topleft lopen'
  else
    call setqflist([], ' ', a:what)
    execute 'topleft copen'
  endif

  if &filetype ==# 'qf' && !empty(a:colors)
    for [ syn, hi ] in items(a:colors)
      call matchadd(hi, syn)
    endfor

    setl concealcursor=n
    setl conceallevel=3
  endif
endfunction "}}}

function! s:quickfix_command(is_loc, commands, errformat) abort "{{{
  call s:set_and_open_quickfix(
      \ {
      \   'efm': a:errformat,
      \   'lines': split(s:do_command(join(a:commands, ' ')), '\n'),
      \   'title': join(a:commands, ' ')
      \ }, {}, a:is_loc)
endfunction "}}}


" *****************************************************************************
"
command! -bang -nargs=* GTag  call <SID>quickfix_command(
    \ <bang>0, [ '(', 'global -qax', <q-args>, '&', 'global -qax -s -r', <q-args>, ')' ],
    \ '%*\S%*\s%l%\s%f%\s%m')
command! -nargs=* LGTag GTag! <args>

if has('win32')
  command! -bang -nargs=? -complete=dir Ls  call <SID>quickfix_command(
      \ <bang>0, [ 'dir /B /A:-D ', <q-args> ], '%f')
else
  command! -bang -nargs=? -complete=dir Ls  call <SID>quickfix_command(
      \ <bang>0, [ 'ls -1 -F | grep -v /', <q-args> ], '%f')
endif


" *****************************************************************************
"
command! -bang BufList  call <SID>set_and_open_quickfix(
    \ {
    \   'items': call({ -> map(filter(range(1, bufnr('$')),
    \     { idx, val -> bufexists(val) && buflisted(val) && bufloaded(val) }),
    \     { idx, val -> { 'bufnr':val, 'filename':bufname(val) } }) },
    \     []),
    \   'title': 'buffers: <q-args>'
    \ },
    \ { '|| $': 'Conceal' },
    \ <bang>0)

command! -bang Mru call <SID>set_and_open_quickfix(
    \ {
    \   'items': call({ -> map(copy(v:oldfiles),
    \     { idx, val -> { 'filename':fnamemodify(expand(val), ':p') } }) },
    \     []),
    \   'title': 'oldfiles: <q-args>'
    \ },
    \ { '|| $': 'Conceal' },
    \ <bang>0)


" *****************************************************************************
"
function! s:tag2qfitem(bufnr, fname, taginfo) "{{{
  let prefix = ''
  let saffix = ''

  for field in a:taginfo[3:]
    if field =~# '^kind:'
      let saffix = ' : ' . substitute(field, '^\w\+:', '', '')
    elseif field =~# '^signature:'
      let saffix = substitute(field, '^\w\+:', '', '')
    elseif field =~# '^\w\+:'
      let prefix = substitute(field, '^\w\+:', '', '') . '.'
    endif
  endfor

  return {
      \   'bufnr': a:bufnr,
      \   'filename': a:fname,
      \   'text': prefix . get(a:taginfo, 0, '') . saffix,
      \   'lnum': str2nr(substitute(get(a:taginfo, 2, ''), ';"', '', '')),
      \ }
endfunction "}}}

function! s:simple_outline(is_loc) "{{{
  let tmp_source = tempname() . '.' . expand('%:e')

  call writefile(getbufline('%', 1, '$'), tmp_source)


  let force = '' " ' --jcode=utf8 '

  if &filetype ==# 'cpp' | let force .= '--language-force=c++' | endif
  if &filetype ==# 'vim' | let force .= '--language-force=vim' | endif
  if &filetype ==# 'markdown' | let force .= '--language-force=markdown' | endif

  let bufnr = bufnr('%')
  let fname = expand('%')
  let tags = map(map(systemlist(printf('ctags -n -f - %s %s', force, tmp_source)),
      \ { idx, val -> split(substitute(val, '[\n\r]$', '', ''), '\t') }),
      \ { idx, val -> s:tag2qfitem(bufnr, fname, val) })

  call delete(tmp_source)
  call s:set_and_open_quickfix(
      \ { 'items': tags, 'title': printf('ctags %s', tmp_source)},
      \ {
      \   '^.\+|\d\+\%(\s*col\s*\d\+\)\?|': 'Conceal',
      \   '(.*)$': 'SpecialKey',
      \   ' : \w\+$': 'SpecialKey',
      \   ' \.\.\+': 'SpecialKey',
      \   '__anon\w\+\(\.\|::\)': 'SpecialKey'
      \ },
      \ a:is_loc)
endfunction "}}}

command! -bang Outline  call <SID>simple_outline(<bang>0)


" *****************************************************************************
"
function! s:buffer_command_get_output(command, arguments, ext) abort "{{{
  let l:output = s:do_command(a:command . ' ' . join(a:arguments, ' '))
  let l:output_tmp = fnamemodify(tempname() . a:ext, ':p')

  call writefile(split(l:output, '\n'), l:output_tmp)

  execute printf('silent! tabe +set\ ro %s', l:output_tmp)
endfunction "}}}

function! s:buffer_command_do(command, arguments) abort "{{{
  echomsg s:do_command(a:command . ' ' . join(a:arguments, ' '))
endfunction "}}}

command! -nargs=? -complete=dir  SvnLs     call <SID>quickfix_command(1, [ 'svn ls ', <q-args> ], '%f')

command! -nargs=? -complete=file SvnLog    call <SID>buffer_command_get_output('svn log', [ <q-args> ], '.log')
command! -nargs=? -complete=file SvnDiff   call <SID>buffer_command_get_output('svn diff', [ <q-args> ], '.diff')
command! -nargs=? -complete=file SvnBlame  call <SID>buffer_command_get_output('svn blame', [ <q-args> ], '.blame')

command! -nargs=? -complete=file SvnAdd       call <SID>buffer_command_do('svn add', [ <q-args> ])
command! -nargs=? -complete=file SvnRevert    call <SID>buffer_command_do('svn revert', [ <q-args> ])
command! -nargs=? -complete=file SvnResolved  call <SID>buffer_command_do('svn resolved', [ <q-args> ])


command! -nargs=? -complete=dir  GitLs     call <SID>quickfix_command(1, [ 'git ls-files ', <q-args> ], '%f')

command! -nargs=? -complete=file GitLog    call <SID>buffer_command_get_output('git log', [ <q-args> ], '.log')
command! -nargs=? -complete=file GitDiff   call <SID>buffer_command_get_output('git diff', [ <q-args> ], '.diff')
command! -nargs=? -complete=file GitBlame  call <SID>buffer_command_get_output('git blame', [ <q-args> ], '.blame')

command! -nargs=? -complete=file GitAdd       call <SID>buffer_command_do('git add', [ <q-args> ])
command! -nargs=? -complete=file GitRevert    call <SID>buffer_command_do('git revert', [ <q-args> ])
command! -nargs=? -complete=file GitResolved  call <SID>buffer_command_do('git resolved', [ <q-args> ])


" *****************************************************************************
"
augroup vimrc_additional_syntax
  autocmd FileType c,cpp
      \   syn keyword Typedef __int16 __int32 __int64 __fastcall
      \ | syn keyword Typedef int16_t uint16_t int32_t uint32_t int64_t uint64_t
      \ | syn keyword Typedef BYTE WORD DWORD SHORT USHORT LONG ULONG LONGLONG ULONGLONG
      \ | syn keyword Typedef WPARAM LPARAM BOOL TRUE FALSE WINAPI UINT_PTR

  autocmd FileType c,cpp,java,javascript 
      \   syn match Operator /\s\zs[+\-\*\/<>=|&]\ze\s/
      \ | syn match Operator /;;\|[<>!=~+\-\*\/]=\|||\|&&\|++\|--/
      \ | syn match Operator /::\ze\w/
      \ | syn match Operator /\>[\*&]/
      \ | syn match Operator /\*\</
      \ | syn match Statement /[!&]\</
      \ | syn match Statement /[!&]\ze(/
      \ | syn match Statement /\%(->\|\.\)\</

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
function! Plugin_ReadTemplate_Complete(ArgLead, CmdLine, CursorPos) abort "{{{
  let pattern = ( &filetype ==# '' ) ? '*' : '*.' . &filetype
  let template_path = expand(get(g:, 'vimrc_template_path', '~/templates/'))

  return map(globpath(template_path, pattern, 0, 1),
      \ { idx, val -> fnamemodify(val, ':t') })
endfunction "}}}

function! s:Vimrc_ReadTemplate(files) abort "{{{
  let template_path = expand(get(g:, 'vimrc_template_path', '~/templates/'))
  let template_path = fnamemodify(template_path, ':p') . a:files

  execute '.r ' . template_path
endfunction "}}}

function! s:Vimrc_ReadTemplatePost() abort "{{{
  call setline("'[", map(getline("'[", "']"),
      \ { idx, val -> substitute(val, '%[YmdaAHMS]', '\=strftime(submatch(0))', 'g') }))
endfunction "}}}

command! -nargs=1 -complete=customlist,Plugin_ReadTemplate_Complete Snippet 
    \ call <SID>Vimrc_ReadTemplate(<f-args>)

augroup vimrc_snippet_command
  autocmd FileReadPost * call <SID>Vimrc_ReadTemplatePost()
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
if has('gui_win32')
  function! s:remote_open(is_move, bufname)
    let bname = get(a:bufname, 0, '')

    if empty(bname) | let bname = fnamemodify(expand('%'), ':p') | endif

    let bufnr = bufnr(bname)

    call job_start('gvim', { 'in_io': 'null', 'out_io': 'null', 'err_io': 'null' })

    call remote_send(get(filter(split(serverlist(), '\n'), { idx, val -> v:servername !=# val }), 0, ''),
        \ '<ESC>:tabedit ' . bname . '<CR>')

    if a:is_move | execute 'bw ' . bufnr | endif
  endfunction

  command! -nargs=? -complete=buffer RemoteCopy call s:remote_open(0, [<q-args>])
  command! -nargs=? -complete=buffer RemoteMove call s:remote_open(1, [<q-args>])
endif


" *****************************************************************************
""
let g:changelog_spacing_errors = 0
let g:changelog_dateformat = '%Y-%m-%d'
let g:changelog_username = '<localhost>'


""
nnoremap <silent> > :IndentLine<CR>
nnoremap <silent> < :UnIndentLine<CR>

vnoremap <silent> > :IndentLine<CR>
vnoremap <silent> < :UnIndentLine<CR>

nnoremap <silent> <C-q> :CommentIt<CR>
vnoremap <silent> <C-q> :CommentIt<CR>

nnoremap <silent> <Leader>x :GfmTodo<CR>
vnoremap <silent> <Leader>x :GfmTodo<CR>

nnoremap <silent> <Leader><Space> :LcdX %:h<CR>
nnoremap <silent> <Leader><Leader> :up<CR>

vnoremap syy :EncloseText -a 
vnoremap sdd :EncloseText -d 
vnoremap srr :EncloseText -r 

nnoremap sn  :Snippet 


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

