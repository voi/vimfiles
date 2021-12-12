" *****************************************************************************
"
" command! -bang -nargs=1 GTag  call <SID>quickfix_command(
"     \ <bang>0, [ '(', 'global -qax', <q-args>, '&', 'global -qax -s -r', <q-args>, ')' ],
"     \ '%*\S%*\s%l%\s%f%\s%m')
" 
"" 
function! s:get_gatag_bin() "{{{
  return get(g:, 'vimrc_gtags_command', 'global')
endfunction "}}}

function! s:gtags_job_out_cb(msg) "{{{
  if has('iconv') && &termencoding != &encoding
    let out = iconv(a:msg, &termencoding, &encoding)
  else
    let out = a:msg
  endif

  call setloclist(0, [], 'a', { 'efm': "%f\t%l\t%m", 'lines': split(out, '\n') })
endfunction "}}}

""
function! s:gtags_job_start(args) abort "{{{
  let ctx = {
      \ 'out_cb': { ch, msg -> s:gtags_job_out_cb(msg) },
      \ 'close_cb': { ch -> execute('topleft lwindow') }
      \ }
  let globalbin = s:get_gatag_bin()

  call setloclist(0, [])

  call job_start(printf('%s -qa   --result=ctags-mod %s', globalbin, a:args), ctx)
  call job_start(printf('%s -qasr --result=ctags-mod %s', globalbin, a:args), ctx)
endfunction "}}}

""
command! -nargs=1 GTag call s:gtags_job_start(<q-args>)


" *****************************************************************************
function! Vimrc_CLang_IncludeExpr(fname) "{{{
  let globalbin = s:get_gatag_bin()
  return get(split(system(printf('%s -P -a %s', globalbin, a:fname), '\n'), 0, a:fname))
endfunction "}}}

function! Vimrc_CLang_TagFunc(pattern, flag, info) "{{{
  let globalbin = s:get_gatag_bin()
  let cmd = (a:flag ==# 'i') ?
      \ printf('%s -qat -g %s', globalbin, a:pattern) :
      \ printf('%s -qat %s & %s -qat -rs %s', globalbin, a:pattern, globalbin, a:pattern)
  let lines = split(system(cmd), '\n')
  let lines = map(lines, { idx, val -> split(substitute(val, '^\(\w\+\)\s\+\(\S.*\S\)\s\+\(\d\+\)$', '\1\t\2\t\3', ''), '\t') })

  return map(lines, { idx, val -> { 'name': get(val, 0, ''), 'filename': get(val, 1, ''), 'cmd':get(val, 2, '') } })
endfunction "}}}

augroup global_util_vim_autocmd
  autocmd!
  autocmd FileType c,cpp setl path+=./;/
      \ includeexpr=Vimrc_CLang_IncludeExpr(v:fname)
      \ tagfunc=Vimrc_CLang_TagFunc
augroup END

