" vim: ft=vim
function! s:SnippetFile_Expand(path, item) "{{{
  "
  let info = [ line('.'), matchstr(getline('.'), '^\s*'), &paste ]

  "    0123456789A12***3456789B1234567
  "     ↓
  "    " delete snippet word and split line
  "    0123456789A12
  "    3456789B1234567
  "     ↓
  "    " insert snippet file content
  "    0123456789A12
  "    snippet-file
  "    3456789B1234567
  "     ↓
  "    " join snippet content
  "    0123456789A12snippet-file3456789B1234567
  set paste
  execute printf("normal hv%dhc\<CR>", len(substitute(a:item.word, '.', '.', 'g')) -1)
  execute printf('keepalt %dr %s', info[0], a:path)
  let &paste = info[2]

  "
  let [ beg, end ] = [ line("'["), line("']") ]

  execute printf('silent! %d,%ds/%%[YmdaAHMS]/\=strftime(submatch(0))/g', beg, end)

  if beg < end
    execute printf('silent! %d,%ds/^/%s/', beg + 1, end, info[1])

    let off_str = ''
  else
    let off_str = getline(beg - 1)
  endif

  let pos = [
      \ 0,
      \ end - 1,
      \ get(matchstrpos(off_str . getline(end), '$'), 1, 0) + 1,
      \ 0
      \ ]

  execute printf('silent! normal %dGgJ%dGgJ', end, beg - 1)

  call setpos('.', pos)
endfunction "}}}

function! s:SnippetFile_OnCompleteDone() "{{{
  if empty(v:completed_item)
    return
  endif

  let path = get(v:completed_item, 'user_data', '')

  if empty(path) || !filereadable(path)
    return
  endif

  call s:SnippetFile_Expand(path, v:completed_item)
endfunction "}}}

function! SnippetFile_TriggerKey() "{{{
  let ft = getbufvar('%', '&filetype')
  let pat = empty(ft) ? '*' : '*.' . ft
  let path = expand(get(g:, 'vimrc_template_path', '~/templates/'))

  "
  call complete(col('.'), 
      \   map(globpath(path, pat, 0, 1), { idx, val -> {
      \     'word': fnamemodify(val, ':t'),
      \     'abbr': fnamemodify(val, ':t:r'),
      \     'kind': '*',
      \     'user_data': val
      \   } } ))

  return ''
endfunction "}}}

"
augroup plugin-snippet-file-vim-event
  autocmd!
  autocmd CompleteDone * call <SID>SnippetFile_OnCompleteDone()
augroup END

"
" inoremap <silent> ; <C-r>=SnippetFile_TriggerKey()<CR>

