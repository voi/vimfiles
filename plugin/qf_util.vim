" *****************************************************************************
function! s:qf_util_is_location(winid) "{{{
  return get(get(getwininfo(a:winid), 0, {}), 'loclist', 0)
endfunction "}}}

function! s:qf_util_open(command) "{{{
  let winid = win_getid()
  let list = s:qf_util_is_location(winid) ? getloclist(winid) : getqflist()
  let bufnr = get(get(list, line('.') -1, {}), 'bufnr', -1)

  if bufnr > 0
    wincmd p
    execute printf('%s %% | b %d', a:command, bufnr)
  endif
endfunction "}}}

function! s:qf_util_keymap() "{{{
  "
  nnoremap <buffer> <CR>   :pclose<CR><CR>
  nnoremap <buffer> <S-CR> :pclose<CR><CR><C-w>p<C-w>q
  nnoremap <buffer> <C-v>  :call <SID>qf_util_open('vsplit')<CR>
  nnoremap <buffer> <C-s>  :call <SID>qf_util_open('split')<CR>
  nnoremap <buffer> <C-t>  :call <SID>qf_util_open('tabe')<CR>

  if s:qf_util_is_location(win_getid())
    nnoremap <buffer> <C-p> :lolder<CR>
    nnoremap <buffer> <C-n> :lnewer<CR>
  else
    nnoremap <buffer> <C-p> :colder<CR>
    nnoremap <buffer> <C-n> :cnewer<CR>
  endif
endfunction "}}}

""
nnoremap <silent> Q :cclose <BAR> lclose<CR>

augroup qf_util_vim_autocmd
  autocmd FileType qf call <SID>qf_util_keymap()
augroup END

