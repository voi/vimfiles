" *****************************************************************************
""
function! s:buflist_enumerate() "{{{
  return filter(range(1, bufnr('$')),
      \   { idx, val -> bufexists(val) && buflisted(val) && bufloaded(val) })
endfunction "}}}

""
function! s:buflist_show() "{{{
  call setloclist(0, [], ' ', {
    \ 'lines': map(s:buflist_enumerate(), { idx, val -> bufname(val) }),
    \ 'efm': '%f', 'title': 'buffers'
    \ })

  topleft lopen

  call matchadd('Conceal', '||\s$')

  setl concealcursor=n
  setl conceallevel=3
endfunction "}}}

""
command! -nargs=0 BufList call <SID>buflist_show()


" ****************************************************************
let g:stall_sources.buffer = extend({}, stall#api_get_buffer_opener())

function! g:stall_sources.buffer._collection(context, item, flags) dict "{{{
  return map(s:buflist_enumerate(), 
      \ { idx, val -> #{ text: printf("%d\t%s", val, bufname(val)), bufnr: val } })
endfunction "}}}

function! g:stall_sources.buffer._on_ready(context, item, flags) dict "{{{
  nnoremap <buffer> <silent> <CR> :call stall#api_handle_key('open')<CR>
  nnoremap <buffer> <silent> t    :call stall#api_handle_key('tabopen')<CR>
  nnoremap <buffer> <silent> v    :call stall#api_handle_key('vsplit')<CR>
  nnoremap <buffer> <silent> s    :call stall#api_handle_key('split')<CR>
  nnoremap <buffer> <silent> d    :call stall#api_handle_key('wipe')<CR>
endfunction "}}}

function! g:stall_sources.buffer.wipe(context, item, flags) dict "{{{
  let a:flags._update = 1

  if has_key(a:item, 'bufnr')
    execute printf('bw %s', a:item.bufnr)
  endif
endfunction "}}}

