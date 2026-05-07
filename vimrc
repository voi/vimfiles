vim9script

# source $VIMRUNTIME/defaults.vim
set nocompatible

scriptencoding utf-8

filetype plugin indent on
syntax on


###############################
set encoding=utf-8
set fileformats=dos,unix,mac
set fileencodings=utf-8,ucs-bom,euc-jp,eucjp-jisx0213,cp932,iso-2022-jp-3,iso-2022-jp,ucs-2le,ucs-2,cp936,default,latain1

set ambiwidth=double
set helplang=ja,en
set ttimeout timeoutlen=3000 ttimeoutlen=100

# display
set display=truncate
set lazyredraw
set number
set list
set ruler
set nowrap
set nofixendofline

set belloff=all
set display=lastline
set colorcolumn=80,100
set guioptions+=cM
set guioptions-=t
# |¦»▸>￫↲ƶ
set listchars=tab:￫\ ,trail:.,extends:»,precedes:«,nbsp:%,conceal:↲
set showcmd
set showbreak=▸\ 
set shortmess=coOIWtT
set matchpairs& matchpairs+=<:>
set cursorline
set cursorlineopt=number

# folding
def Vimrc_foldtext(): string
  return getline(v:foldstart)->slice(0, winwidth(0) - 5) .. ' ...'
enddef

set foldtext=Vimrc_foldtext()
set fillchars=fold:\ 
set fillchars+=vert:\:
set fillchars+=foldopen:▾,foldsep:.,foldclose:▸

# format
set formatoptions+=jnmM2
set formatoptions-=l
set nrformats-=octal

# forward/back
set backspace=indent,eol,start
set whichwrap+=h,l,<,>,[,]
set virtualedit+=block

# indent
set autoindent smartindent
set copyindent preserveindent
set breakindent breakindentopt=shift:2

set smarttab shiftround
set tabstop=4 shiftwidth=4 softtabstop=4

# completion
set complete=.,w^25,b^25
set completeopt=menuone,noinsert,fuzzy
set pumheight=16
set wildignore+=*/.git,*/.git/*
set wildignore+=*/.svn,*/.svn/*
set wildignore+=_FOSSIL_
set wildignorecase
set wildmode=longest,full
set wildoptions+=fuzzy

# file
# set autowrite autowriteall
set autoread

set noswapfile
set viminfo-=<50,s10,h,c

# buffer
set hidden
set switchbuf=useopen,usetab

# search
set ignorecase
set smartcase
set nowrapscan
set hlsearch
set tags+=./tags;

# crypt file
set cryptmethod=blowfish2

# tab line
def g:Vimrc_tabline(): string
  #
  var tabnr = tabpagenr()
  var bufnr = tabnr->tabpagebuflist()[tabnr->tabpagewinnr() - 1]
  var bufpath = bufnr->bufname()->fnamemodify(':p')
  var bufname = bufpath->fnamemodify(':t')
  var tabcount = tabpagenr('$')

  #
  var icon_page = get(g:, 'vimrc_tabline_icon_page', '🔖')
  var icon_mod = get(g:, 'vimrc_tabline_icon_mod', '⚡')
  var icon_nor = get(g:, 'vimrc_tabline_icon_nor', '📝')
  var icon_dir = get(g:, 'vimrc_tabline_icon_dir', '📁')
  var icon_prev = get(g:, 'Vimrc_tabline_icon_prev', '◀️')
  var icon_next = get(g:, 'Vimrc_tabline_icon_next', '▶️')

  #
  var tabs = printf('%s %s %s %s',
    icon_page,
    ((tabnr - 1) > 0 ? icon_prev : ''),
    ((tabcount > 1) ? tabnr->string() : ''),
    ((tabcount - tabnr) > 0 ? icon_next : ''))

  #
  var active = printf('%s %s ',
    (&modified ? icon_mod : icon_nor),
    (bufname->empty() ? '...' : bufname))
  var here = printf('%s %s/', icon_dir, bufpath->fnamemodify(':h:t'))

  #
  return '%(%#TabLine#' .. tabs .. '%#TabLineSel#' .. active  .. '%)%<' .. here .. '%T%#TabLineFill#'
enddef

set showtabline=2 tabline=%!g:Vimrc_tabline()

# status line
def g:Vimrc_statusline(): string
  var md = mode()
  var left = '...'

  if     md == 'n'  | left = '%#StatusLine_Normal#'  .. ' NOR '
  elseif md == 'i'  | left = '%#StatusLine_Insert#'  .. ' INS '
  elseif md == 'R'  | left = '%#StatusLine_Replace#' .. ' REP '
  elseif md == 'v'  | left = '%#StatusLine_Visual#'  .. ' VIS '
  elseif md == 'V'  | left = '%#StatusLine_Visual#'  .. ' VIS '
  elseif md == '' | left = '%#StatusLine_Visual#'  .. ' VIS '
  elseif md == 's'  | left = '%#StatusLine_Visual#'  .. ' SEL '
  elseif md == 'S'  | left = '%#StatusLine_Visual#'  .. ' SEL '
  elseif md == '' | left = '%#StatusLine_Visual#'  .. ' SEL '
  elseif md == 'c'  | left = '%#StatusLine_Command#' .. ' CMD '
  elseif md == '!'  | left = '%#StatusLine_Command#' .. ' EXE '
  elseif md == 't'  | left = '%#StatusLine_Command#' .. ' TRM '
  endif

  var icon_pwd = get(g:, 'vimrc_statusline_icon_pwd', '📍')
  var icon_mod = get(g:, 'vimrc_statusline_icon_mod', '⚡')
  var icon_ro  = get(g:, 'vimrc_statusline_icon_ro',  '❎')

  left ..= '%#StatusLine_Modes#'
    .. (&modified ? icon_mod : '')
    .. (&modifiable ? '' : icon_ro)
    .. ' %#StatusLine#'

  var mid = ' %t ' .. icon_pwd .. getcwd()->fnamemodify(':p:h:t') .. '/'
  var right = '%#StatusLine_Modes#'
    .. ' %y ' .. &fileencoding .. ' ' .. &fileformat
    .. '%#StatusLine_CursorPos#> %l, %v - %04B'

  return '%(' .. left .. '%)%<' .. mid .. '%=%(' .. right .. '%)'
enddef

set laststatus=2 statusline=%!g:Vimrc_statusline()

if has('vcon') | set termguicolors | endif
if has('conceal') | set conceallevel=2 | endif
if has('win32')
  set makeencoding=cp932
  set termencoding=cp932

  set grepprg=findstr\ /NSR
endif

if !has('gui_running') | set mouse=  | endif

# optional
# set autochdir
# set isfname+=(,)
# set textwidth=0
# set synmaxcol=200
# set scrolloff=999
# set splitbelow
# set splitright

###############################
# a"/a'/a` trim whitespaces, a(/a{/a[ don't trim whitespaces.
vnoremap a" 2i"
vnoremap a' 2i'
vnoremap a` 2i`

onoremap a" 2i"
onoremap a' 2i'
onoremap a` 2i`

#buffer paste from register
def Vimrc_map_expr_register_p(chr: string): string
  call inputsave()
  var r = (execute('register') .. "\n")->input()
  call inputrestore()

  return '"' .. r->split('\zs')->get(0, '"') .. chr
enddef

nnoremap <expr> <Space>p Vimrc_map_expr_register_p('p')
nnoremap <expr> <Space>P Vimrc_map_expr_register_p('P')

xnoremap <expr> <Space>p '"_d' .. Vimrc_map_expr_register_p('p')

# paste yank register
xnoremap _ "0p

# delete to blackhole register
nnoremap d "_d
nnoremap D "_D
xnoremap d "_d

# yank/cut like D
nnoremap <M-X> C<ESC>
nnoremap <M-v> v$

nnoremap Y y$

# system gui clipboard manip
if has('clipboard') && 0
  set clipboard&
  set clipboard+=unnamed,unnamedplus
else
  nnoremap <M-p> "*gp
  nnoremap <M-P> "*gP
  xnoremap <M-p> "*gp

  nnoremap <M-y> "*y
  nnoremap <M-Y> "*y$
  xnoremap <M-y> "*y

  nnoremap <M-x> "*C<ESC>
  xnoremap <M-x> "*c<ESC>
endif

# auto-indent editing at empty line
nnoremap <expr> <Space>i empty(getline('.')) ? '"_cc' : 'i'

# read only
nnoremap <silent> <M-m> :set modifiable!<CR>

# continuous indent
xnoremap < <gv
xnoremap > >gv

# narrowing by fold
nnoremap z, zMzv

# update
nnoremap <silent> <Leader><Leader> :update<CR>

# buffer
nnoremap <silent> [b :bprev<CR>
nnoremap <silent> ]b :bnext<CR>

# window
nnoremap <silent> <C-Down>  <C-w>j
nnoremap <silent> <C-Up>    <C-w>k
nnoremap <silent> <C-Left>  <C-w>h
nnoremap <silent> <C-Right> <C-w>l

inoremap <silent> <C-Down>  <C-o><C-w>j
inoremap <silent> <C-Up>    <C-o><C-w>k
inoremap <silent> <C-Left>  <C-o><C-w>h
inoremap <silent> <C-Right> <C-o><C-w>l

# tabpage
nnoremap <silent> [t :tabprev<CR>
nnoremap <silent> ]t :tabnext<CR>

# text operations
nnoremap <silent> <Leader>d :copy .-1<CR>
xnoremap <silent> <Leader>d :copy '<-1<CR>gv

nnoremap <silent> <M-k> :move .-2<CR>
nnoremap <silent> <M-j> :move .+1<CR>

xnoremap <silent> <M-k> :move '<-2<CR>gv
xnoremap <silent> <M-j> :move '>+1<CR>gv

# popup menu
inoremap <silent> <expr> <CR>  pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
inoremap <silent> <expr> <C-n> pumvisible() ? "\<Down>" : "\<C-n>"
inoremap <silent> <expr> <C-p> pumvisible() ? "\<Up>" : "\<C-p>"

inoremap <silent> <expr> <C-Space> pumvisible() ? "" : "\<C-x>\<C-o>"
inoremap <silent> <expr> <C-f>     pumvisible() ? "" : "\<C-x>\<C-f>"

# navigation
nnoremap <silent> <F9>    :lnext<CR>zz
nnoremap <silent> <S-F9>  :lprevious<CR>zz
nnoremap <silent> <C-F9>  :botright lw<CR>

nnoremap <silent> <F10>   :cnext<CR>zz
nnoremap <silent> <S-F10> :cprevious<CR>zz
nnoremap <silent> <C-F10> :botright cw<CR>

#
nnoremap <silent> gO :HelpToc<CR>

# C-w + v / C-w + s like C-w + ^
nnoremap <silent> <C-w>s  <C-w>s<C-^>
nnoremap <silent> <C-w>v  <C-w>v<C-^>

if has('patch-9.1.1590')
  set autocomplete autocompletedelay=5 autocompletetimeout=100

else
  # auto-complete imitation
  def Vimrc_Keymap_Complete(chr: string): string
    return chr .. ( pumvisible() ? '' : "\<C-x>\<C-p>\<C-n>" )
  enddef

  for k in split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_", '\zs')
    exec printf("imap <silent> <expr> %s Vimrc_Keymap_Complete('%s')", k, k)
  endfor
endif

# indent at begin of line
nnoremap <silent> g> :normal gI	<CR>
xnoremap <silent> g> :v/^$/ normal gI	<CR>

nnoremap <silent> <expr> g< printf(":normal s/^%s//\<CR>",
      \ (&et ? repeat(' ', &sw) : '\t'))
xnoremap <silent> <expr> g< printf(":g/^%s/ s/^%s//\<CR>",
      \ (&et ? repeat(' ', &sw) : '\t'),
      \ (&et ? repeat(' ', &sw) : '\t'))

# in-file search list
nnoremap <silent> g/ :vimgrep //gj %<CR>

# relative j/k
def g:Vimrc_relative_jk(jk: string)
  var rn = getbufvar('%', '&relativenumber')
  setl relativenumber | redraw

  var off = input('offset > ')
  if !off->empty() | call execute('normal ' .. off .. jk) | endif

  call setbufvar('%', '&relativenumber', rn)
enddef

nnoremap <silent> <C-k> :call g:Vimrc_relative_jk('k')<CR>
nnoremap <silent> <C-j> :call g:Vimrc_relative_jk('j')<CR>

# smart wrap
command! ToggleWrap {
  if getbufvar('%', '&wrap')
    setl nowrap
    nunmap <silent> <buffer> gj
    nunmap <silent> <buffer> gk
    nunmap <silent> <buffer> j
    nunmap <silent> <buffer> k
  else
    setl wrap
    nnoremap <silent> <buffer> gj j
    nnoremap <silent> <buffer> gk k
    nnoremap <silent> <buffer> j  gj
    nnoremap <silent> <buffer> k  gk
  endif

  setl wrap?
}

nnoremap <silent> <M-w> :ToggleWrap<CR>

################################################################
# command! -nargs=? -complete=filetype Temp 
#     \ execute printf('tabe %s_%s | setf %s', tempname(), strftime('%Y-%m-%d_%H-%M-%S'),
#     \   ('<args>' ==# '' ? (&filetype ==# 'qf' ? 'text' : &filetype) : '<args>'))

# <http://d.hatena.ne.jp/fuenor/20100115/1263551230>
command! -nargs=+ -bang -complete=file Rename {
      var old = bufname('%')->fnamemodify(':p')
      execute 'f ' .. escape(<q-args>, ' ')
      execute 'w<bang>'
      call delete(old)
}

# clear all buffers
command! -bang BufClear bufdo bw<bang>

# clear other buffers
command! -bang BufOnly {
  var bnrs = range(1, bufnr('$'))
    ->filter((i, v) => bufexists(v) && v != bufnr('%') )
    ->join(' ') |
  if bnrs !=# '' | execute 'bw<bang> ' .. bnrs | endif
}

# clear hidden buffers
command! -bang BufTidyUp {
  var bnrs = range(1, bufnr('$'))
    ->filter((i, v) => bufexists(v) && bufloaded(v) && get(get(getbufinfo(v), 0, {}), 'hidden', 0) )
    ->join(' ') |
  if bnrs !=# '' | execute 'bw<bang> ' .. bnrs | endif
}

# lcd at current file directory
command! -bang Here :call execute(('<bang>'->empty() ? 'l' : 't') .. 'cd %:p:h')

# print file location
command! Where echo expand('%')->fnamemodify(':p:h')

# print full file path
command! Me echo expand('%')->fnamemodify(':p')

# zoom in / out and reset
var vimrc_zoom_guifont_original = []

if has('gui_running') && has('win32')
  command! ZoomIn {
    if vimrc_zoom_guifont_original->empty()
      vimrc_zoom_guifont_original = [&guifont, &guifontwide]
    endif

    var SizeUp = (setfont) => setfont->substitute('\%(:h\)\zs\(\d\+\)', (m) => m[1]->str2nr() + 1, 'g')

    execute 'set guifont=' .. SizeUp(&guifont)
    execute 'set guifontwide=' .. SizeUp(&guifontwide)
  }

  command! ZoomOut {
    if vimrc_zoom_guifont_original->empty()
      vimrc_zoom_guifont_original = [&guifont, &guifontwide]
    endif

    var SizeDown = (setfont) => setfont->substitute('\%(:h\)\zs\(\d\+\)', (m) => max([1, m[1]->str2nr() - 1]), 'g')

    execute 'set guifont=' .. SizeDown(&guifont)
    execute 'set guifontwide=' .. SizeDown(&guifontwide)
  }

  command! ZoomReset {
    if !vimrc_zoom_guifont_original->empty()
      execute 'set guifont=' .. get(vimrc_zoom_guifont_original, 0, '')
      execute 'set guifontwide=' .. get(vimrc_zoom_guifont_original, 1, '')

      vimrc_zoom_guifont_original = []
    endif
  }
endif

# open powershell (terminal is cmd.exe)
if has('win32')
  command! Powershell terminal ++close ++rows=16 powershell

  nnoremap <silent> <C-@> :Powershell<CR>
endif

# file list at cwd.
command! -bang -nargs=? QFiles {
  var path = '<bang>'->empty() ? getcwd() : expand('%:h')->fnamemodify(':p')
  var expr = [<f-args>]
  var list = globpath(path, (expr->empty() ? '*' : expr[0]), 0, 1)
    ->filter((i, v) => !v->isdirectory())

  call setqflist([], 'r', { lines: list, efm: '%f', title: getcwd() })
  cwindow
  call matchadd('Conceal', '||\s*$')

  setl concealcursor=nvic
  setl conceallevel=3
}

# switch cursorline highlight
command! -nargs=0 CursorLineOnOff {
  if &cursorlineopt =~# 'line\|both'
    set cursorlineopt=number
  else
    set cursorlineopt=both
  endif
}

#
var hi_cursor_backup = ''

command! -nargs=0 CursorLineReverseOnOff {
  if &cursorlineopt =~# 'line\|both'
    if hi_cursor_backup->empty()
      hi_cursor_backup = execute('hi CursorLine')
        ->substitute('^.*CursorLine.*xxx', 'hi CursorLine', '')
      call execute('hi CursorLine term=reverse cterm=reverse gui=reverse')
    else
      call execute('hi clear CursorLine | ' .. hi_cursor_backup)
      hi_cursor_backup = ''
    endif
  endif
}

# switch scrolloff always center
command! -nargs=0 ScrolloffCenterOnOff {
  if &scrolloff != 0 | set scrolloff=0 | else | set scrolloff=999 | endif
  set scrolloff?
}

# show syntax
command! ShowSyntax echo synIDattr(synID(line('.'), col('.'), 1), 'name')

# new vim instance
command! -nargs=? GVim silent !start gvim <f-args>


################################################################
def Vimrc_qf_keymap()
  # jump after closing preview
  nnoremap <buffer> <CR>   :pclose<CR><CR>
  # jump after closing preview and quickfix
  nnoremap <buffer> <S-CR> :pclose<CR><CR><C-w>p<C-w>q

  if get(get(getwininfo(win_getid()), 0, {}), 'loclist', 0)
    # history
    nnoremap <buffer> <C-p> :lolder<CR>
    nnoremap <buffer> <C-n> :lnewer<CR>
    # filter
    nnoremap <buffer> <expr> i printf(":Lfilter  /%s/\<CR>", input('> ', ''))
    nnoremap <buffer> <expr> I printf(":Lfilter! /%s/\<CR>", input('> ', ''))
  else
    # history
    nnoremap <buffer> <C-p> :colder<CR>
    nnoremap <buffer> <C-n> :cnewer<CR>
    # filter
    nnoremap <buffer> <expr> i printf(":Cfilter  /%s/\<CR>", input('> ', ''))
    nnoremap <buffer> <expr> I printf(":Cfilter! /%s/\<CR>", input('> ', ''))
  endif
enddef

# filetype
def Vimrc_markdown_foldexpr(): string
  var line_ = getline(v:lnum)
  var head_ = line_->matchstr('^#\+\s\@=')->len()
  var synx_ = synIDattr(synID(v:lnum, 1, 1), 'name')

  if head_ > 0 && synx_ !~# 'markdown\w*CodeBlock'
    return '>' .. string(max([head_ - 1, 1]))
  endif

  if line_->substitute('^\s\+\|\s\+$', '', 'g')->empty() && getline(v:lnum + 1) =~# '^#\+'
    return '-1'
  endif

  return '='
enddef

augroup vimrc_autocmd_filetype
  autocmd!

  if has('win32')
    autocmd BufWritePre *.c,*.cpp,*.h,*.hpp,*.def,*.bat,*.ini,*.env,*.js,*.vbs,*.ps1 setl fenc=cp932 ff=dos
    autocmd BufNewFile,BufRead *.vcproj,*.sln,*.xaml setf xml
  endif

  autocmd BufReadPost * if bufnr('$') == 1 | execute('lcd %:p:h') | endif

  autocmd FileType help nnoremap <buffer> q :pclose<CR><C-w>c

  # comment
  autocmd FileType * &commentstring = substitute(&commentstring, '%s', ' %s ', '')

  # complete
  autocmd FileType * if &l:omnifunc == '' | setl omnifunc=syntaxcomplete#Complete | endif
  autocmd FileType c,cpp 
        \ setl omnifunc=syntaxcomplete#Complete

  # options
  autocmd FileType c,cpp,cs,java,javascript 
        \ setl cindent cinoptions=:1s,l1,t0,(0,)0,W1s,u0,+0,g0
  autocmd FileType html,xhtml,xml,javascript,vim 
        \ setl tabstop=2 softtabstop=2 shiftwidth=2 expandtab
  autocmd FileType html,xhtml,xml inoremap <buffer> </ </<C-x><C-o>
  autocmd FileType javascript setl cinoptions+=J1
  autocmd FileType cpp        setl commentstring=//\ %s
  autocmd FileType dosbatch   setl commentstring=@rem\ %s
  autocmd FileType vim        setl fenc=utf8 ff=unix
  autocmd FileType changelog  setl textwidth=0

  # quickfix
  autocmd FileType help,qf nnoremap <buffer> q :pclose<CR><C-w>c
  autocmd FileType qf setl cursorlineopt=both
  autocmd FileType qf call Vimrc_qf_keymap() 

  # markdown
  command! -range ToggleMarkdownTask s/\%([-+*]\%( \{1,4}\|\t\)\[\)\@<=[ xX]\%(\]\s\)\@=/\=(submatch(0) == ' ' ? 'x' : ' ')/

  autocmd FileType markdown 
        \   setl comments+=nb:> formatoptions-=c formatoptions+=jro completeslash=slash
        \ | setl foldexpr=Vimrc_markdown_foldexpr()
        \ | setl foldtext=Vimrc_foldtext()
        \ | nnoremap <buffer> <M-t> :ToggleMarkdownTask<CR>

  autocmd FileType markdown {
    #
    xnoremap <buffer> <Leader>eaC :EncloseText -a ``` ```<CR>
    xnoremap <buffer> <Leader>eai :EncloseText -a * *<CR>
    xnoremap <buffer> <Leader>eab :EncloseText -a ** **<CR>
    xnoremap <buffer> <Leader>eaB :EncloseText -a *** ***<CR>
    xnoremap <buffer> <Leader>eas :EncloseText -a ~~ ~~<CR>
    xnoremap <buffer> <Leader>eal :EncloseText -a [ ](<lt>>)<CR>
    #
    inoreabbr <buffer> 2# ## 
    inoreabbr <buffer> 3# ### 
    inoreabbr <buffer> 4# #### 
    inoreabbr <buffer> 5# ##### 
    inoreabbr <buffer> 6# ###### 
  }

augroup END

# syntax
augroup vimrc_autocmd_user_syntax
  autocmd!

  # datetime
  autocmd VimEnter,WinEnter * hi def Bold gui=bold
        \ | hi def link DateTime Number
        \ | call matchadd('DateTime', '[12]0\d\{2}-\%(1[0-2]\|0[1-9]\)-\%(3[01]\|[12][0-9]\|0[1-9]\)')
        \ | call matchadd('DateTime', '[12]0\d\{2}\/\%(1[0-2]\|0[1-9]\)\/\%(3[01]\|[12][0-9]\|0[1-9]\)')
        \ | call matchadd('DateTime', '\%(2[0-3]\|[0-1][0-9]\):\%([0-5][0-9]\)\%(:\%([0-5][0-9]\)\%(\.\d\{1,3}\)\?\)\?')

  # quickfix
  autocmd QuickFixCmdPost grep,grepadd,vimgrep,vimgrepadd botright copen
  autocmd QuickFixCmdPost lgrep,lgrepadd,lvimgrep,lvimgrepadd botright lopen

  # command-line
  autocmd CmdwinEnter * nnoremap <buffer> q <C-w>c

  # c/cpp
  autocmd FileType c,cpp
        \   syn keyword Type __int16 __int32 __int64 __fastcall
        \ | syn keyword Type int16_t uint16_t int32_t uint32_t int64_t uint64_t
        \ | syn keyword Typedef BYTE WORD DWORD SHORT USHORT LONG ULONG LONGLONG ULONGLONG
        \ | syn keyword Typedef WPARAM LPARAM WINAPI UINT_PTR
        \ | syn keyword Boolean BOOL TRUE FALSE

  # c like
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

  # log
  autocmd FileType log 
        \   syn match LogDumpNonZero /\<\%([13-9A-F]0\|\x[1-9A-F]\)\>/
        \ | syn match LogDumpZero    /\<00\>/
        \ | syn match LogDumpSpace   /\<20\>/
        \ | syn match LogErrWord     /\cERR\%[OR]/
        \ | hi def link LogDumpZero    SpecialKey
        \ | hi def link LogDumpNonZero String
        \ | hi def link LogDumpSpace   Comment
        \ | hi def link LogErrWord     Error

augroup END


################################################################
def Vimrc_custom_highlight()
  hi clear SpecialKey

  # cursor
  hi CursorLineNr term=reverse cterm=reverse gui=reverse

  # ime
  if has('multi_byte_ime')
    hi CursorIM gui=NONE guifg=#FFFFFF guibg=#8000FF
  endif

  # statusline
  hi StatusLine_Modes     guifg=#030303 guibg=#FFFFFF ctermfg=Black ctermbg=White
  hi StatusLine_CursorPos guifg=#FFFFFF guibg=#333399 ctermfg=White ctermbg=DarkBlue

  hi StatusLine_Normal    guifg=#FFFFFF guibg=#0000FF ctermfg=White ctermbg=Blue
  hi StatusLine_Insert    guifg=#FFFFFF guibg=#009944 ctermfg=White ctermbg=Green
  hi StatusLine_Replace   guifg=#FFFFFF guibg=#9933A3 ctermfg=White ctermbg=Cyan
  hi StatusLine_Visual    guifg=#FFFFFF guibg=#F20000 ctermfg=White ctermbg=Red
  hi StatusLine_Command   guifg=#FFFFFF guibg=#030303 ctermfg=Black ctermbg=Yellow
  hi StatusLine_Select    guifg=#030303 guibg=#F2F200 ctermfg=Black ctermbg=Yellow

  # vertical border
  hi vertsplit guifg=fg guibg=bg

  # space
  hi link TrailingSpace NonText
  hi Extraspace guibg=#8B008B ctermbg=darkmagenta

  if &g:background ==# 'dark'
    hi SpecialKey   guifg=#808080  guibg=NONE gui=NONE      ctermfg=grey
    hi ZenkakuSpace guifg=darkgrey            gui=underline ctermfg=darkgrey cterm=underline
    hi Comment      guifg=#CCCCCC  guibg=NONE gui=NONE      ctermfg=grey
    hi NormalNC     guifg=#BBBBBB             gui=italic    ctermfg=grey     cterm=italic

    if has('gui_running')
      hi Normal     guifg=#F0F0F0  guibg=#363636 gui=NONE
      hi LineNr     guibg=#000000

      hi Folded     guifg=#DDDDDD               gui=italic
      hi FoldColumn guifg=#FFFFFF               gui=bold

      hi Visual     guifg=#FF0000 guibg=#D0EEFF gui=NONE

    else
      # terminal transparency
      hi Normal     guifg=#FEFEFE guibg=NONE             ctermfg=231 ctermbg=NONE
      hi NonText    guifg=#DEDEDE guibg=NONE                         ctermbg=NONE

      hi Visual                   guibg=#D84848 gui=NONE
      hi VisualNOS                guibg=#D84848 gui=NONE

    endif
  else
    hi SpecialKey   guifg=#cccccc guibg=NONE gui=NONE      ctermfg=grey
    hi ZenkakuSpace guifg=grey               gui=underline ctermfg=grey     cterm=underline
    hi Comment      guifg=#808080 guibg=NONE gui=NONE      ctermfg=darkgrey
    hi NormalNC     guifg=#808080            gui=italic    ctermfg=darkgrey cterm=italic

    if has('gui_running')
      hi Normal     guifg=#303030 guibg=#FAFAFA gui=NONE
      # hi Normal     guifg=#333333 guibg=#EEEEEE gui=NONE
      # hi Terminal   guifg=#EFEFEF guibg=#303030
      # hi LineNr     guibg=#F5FFFA   # MintCream
      hi LineNr     guibg=#FFFAF0   # FloralWhite

    endif
  endif
enddef

def Vimrc_custom_syntax()
  # extra whitespaces
  #   u00A0 ' ' no-break space
  #   u2000 ' ' en quad
  #   u2001 ' ' em quad
  #   u2002 ' ' en space
  #   u2003 ' ' em space
  #   u2004 ' ' three-per em space
  #   u2005 ' ' four-per em space
  #   u2006 ' ' six-per em space
  #   u2007 ' ' figure space
  #   u2008 ' ' punctuation space
  #   u2009 ' ' thin space
  #   u200A ' ' hair space
  #   u200B '​' zero-width space
  call matchadd('ExtraSpace', '[\u00A0\u2000-\u200B]')
  #   u3000 '　' ideographic (zenkaku) space
  call matchadd('ZenkakuSpace', '　')
  call matchadd('TrailingSpace', '\s\{2,\}$')
enddef

augroup vimrc_autocmd_colors_highlight
  autocmd!
  autocmd ColorScheme       * call Vimrc_custom_highlight()
  autocmd VimEnter,WinEnter * call Vimrc_custom_syntax()
  autocmd WinEnter,BufWinEnter * setlocal cursorlineopt=both wincolor=
  autocmd WinLeave             * setlocal cursorlineopt=number wincolor=NormalNC
augroup END


################################################################
var c_gnu = 1
var c_comment_strings = 1
var c_space_errors = 1
var c_no_tab_space_error = 1
var c_no_bracket_error = 1
var c_no_curly_error = 1

var did_install_default_menus = 1
var did_install_syntax_menu = 1

g:loaded_getscriptPlugin = 1
g:loaded_gzip = 1
g:loaded_logiPat = 1
g:loaded_manpager_plugin = 1
g:loaded_netrw = 1
g:loaded_rrhelper = 1
g:loaded_spellfile_plugin = 1
g:loaded_tarPlugin = 1
g:loaded_2html_plugin = 1
g:loaded_tutor_mode_plugin = 1
g:loaded_vimballPlugin = 1
g:loaded_zipPlugin = 1

if !has('gui_running')
  g:loaded_matchparen = 1
endif

g:markdown_folding = 1
g:markdown_yaml_head = 1


################################################################
packadd! cfilter
packadd! comment
packadd! helptoc
packadd! hlyank
packadd! matchit
packadd! nohlsearch


################################################################
if has('gui_running')
  # options
  $LANG = 'ja'
  set guioptions=gr
  # set cmdheight=1
  # set columns=100
  # set lines=40
  set linespace=3
  set background=light

  colorscheme retrobox

  # font rendering
  if has('win32')
    set rop=type:directx,renmode:5,taamode:1,contrast:1
    set guifont=Cascadia_Code:h10.5,BIZ_UDゴシック:h11,Consolas:h11
    set guifontwide=BIZ_UDゴシック:h11

    # - ‐ ─ ― ー 　 → ⇒
    # 1 i I T l | 0 o O θ Θ , . ; : _
    #
    g:font_size = '11'
    g:guifonts = {
      1: ['Cascadia_Code:h10.5,BIZ_UDゴシック:h__', 'BIZ_UDゴシック:h__'],
      2: ['Cascadia_Code:h10.5,UD_デジタル_教科書体_N:h__', 'UD_デジタル_教科書体_N:h__'],
      3: ['Consolas:h__,BIZ_UDゴシック:h__', 'BIZ_UDゴシック:h__'],
    }

    def g:Vimrc_set_guifont(fonts: list<string>, size: string)
      execute printf('set guifont=%s', 
            \ fonts->get(0, '')->substitute('\%(:h\)\zs__', size, 'g'))
      execute printf('set guifontwide=%s',
            \ fonts->get(1, fonts->get(0, ''))->substitute('\%(:h\)\zs__', size, 'g'))
      execute 'set ambiwidth=double'
    enddef

    command! SetGuiFonts {
      var i = g:guifonts->items()->map((i, v) => v[0] .. "\t" .. v[1]->string())->sort()->inputlist()

      if g:guifonts->has_key(i)
        call g:Vimrc_set_guifont(g:guifonts->get(i, []), g:font_size)
      endif
    }
  endif

  # ime
  if has('multi_byte_ime') || has('xim')
    inoremap <silent> <Esc> <C-o>:set iminsert=0<CR><ESC>

    set iminsert=0 imsearch=0
  endif

  # indent guide
  def GVimrc_indent_guide()
    if &expandtab && &softtabstop != get(w:, 'win_tabstop', 0)
      setlocal conceallevel=2 # concealcursor=iv

      for id in get(w:, 'win_match_id_s', [])
        call matchdelete(id)
      endfor

      w:win_tabstop = &softtabstop
      w:win_match_id_s = []

      for i in range(1, 16)
        call add(w:win_match_id_s, matchadd(
          'Conceal', printf('\%%(^ \{%d}\)\zs ', i * &softtabstop), 0, -1, {'conceal': '¦'}))
      endfor
    endif
  enddef

  augroup gvimrc_autocmd_indent_guide
    autocmd!
    autocmd WinEnter * call GVimrc_indent_guide()
    autocmd VimEnter,ColorScheme * highlight Conceal gui=NONE guifg=#AAAAAA guibg=NONE
  augroup END

else
  set cursorlineopt=both
  set background=dark

  colorscheme retrobox
endif
