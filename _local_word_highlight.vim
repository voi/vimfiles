" vim: ft=vim sw=2 sts=2 ts=2 expandtab
" **************************************************************
" {{{
" guibg=#0a7383 guifg=#ffffff
" guibg=#a07040 guifg=#ffffff
" guibg=#4070a0 guifg=#ffffff
" guibg=#40a070 guifg=#ffffff
" guibg=#70a040 guifg=#ffffff
" guibg=#0070e0 guifg=#ffffff
" guibg=#007020 guifg=#ffffff
" guibg=#d4a00d guifg=#ffffff
" guibg=#06287e guifg=#ffffff
" guibg=#5b3674 guifg=#ffffff
" guibg=#4c8f2f guifg=#ffffff
" guibg=#1060a0 guifg=#ffffff
" guibg=#a0b0c0 guifg=#000000
let s:highlight_table = [
    \ "gui=bold ctermfg=16  ctermbg=153 guifg=#ffffff guibg=#0a7383",
    \ "gui=bold ctermfg=7   ctermbg=1   guibg=#a07040 guifg=#ffffff",
    \ "gui=bold ctermfg=7   ctermbg=2   guibg=#4070a0 guifg=#ffffff",
    \ "gui=bold ctermfg=7   ctermbg=3   guibg=#40a070 guifg=#ffffff",
    \ "gui=bold ctermfg=7   ctermbg=4   guibg=#70a040 guifg=#ffffff",
    \ "gui=bold ctermfg=7   ctermbg=5   guibg=#0070e0 guifg=#ffffff",
    \ "gui=bold ctermfg=7   ctermbg=6   guibg=#007020 guifg=#ffffff",
    \ "gui=bold ctermfg=7   ctermbg=21  guibg=#d4a00d guifg=#ffffff",
    \ "gui=bold ctermfg=7   ctermbg=22  guibg=#06287e guifg=#ffffff",
    \ "gui=bold ctermfg=7   ctermbg=45  guibg=#5b3674 guifg=#ffffff",
    \ "gui=bold ctermfg=7   ctermbg=16  guibg=#4c8f2f guifg=#ffffff",
    \ "gui=bold ctermfg=7   ctermbg=50  guibg=#1060a0 guifg=#ffffff",
    \ "gui=bold ctermfg=7   ctermbg=56  guibg=#a0b0c0 guifg=#000000",
    \ ]

" key = count
let s:entry_count = 0

" { key:, pattern; }
let s:entry_table = {}

" { key:, id; }
" let w:match_table

" }}}


" **************************************************************
" {{{
function! s:WordHighlight_Add(word) abort "{{{
  if a:word ==# '' | return | endif

  for l:pattern in values( s:entry_table )
    if l:pattern ==# a:word | return | endif
  endfor

  let s:entry_table[ s:entry_count ] = a:word
  let s:entry_count += 1

  execute printf( 'tabdo windo call WordHighlight_Update() | tabn %d', tabpagenr())
endfunction "}}}

function! s:WordHighlight_Delete() abort "{{{
  " selector
  for [ l:key, l:pattern ] in items( s:entry_table )
    execute printf( 'echohl %s | echo %s | echohl None',
        \ printf( 'WordHighlight%d', l:key ),
        \ printf( '"%4d: %s"', l:key, escape( l:pattern, '\\' )))
  endfor

  let l:key = str2nr( input('no > '), 10 )

  if has_key( s:entry_table, l:key )
    call remove(s:entry_table, l:key)

    execute printf( 'tabdo windo call WordHighlight_Update() | tabn %d', tabpagenr())
  endif
endfunction "}}}

function! WordHighlight_Update() abort "{{{
  for l:hi in map( copy( s:highlight_table ),
      \ { idx, val -> printf( 'hi! WordHighlight%d %s', idx, val ) })
    execute l:hi
  endfor

  let w:match_table = get( w:, 'match_table', {})

  for l:key in filter( keys( w:match_table ),
      \ { idx, val -> !has_key( s:entry_table, val ) })
    call matchdelete( w:match_table[ l:key ] )
    call remove( w:match_table, l:key )
  endfor

  for [ l:key, l:pattern ] in filter( items( s:entry_table ),
      \ { idx, val -> !has_key( w:match_table, val[ 0 ] ) })
    let w:match_table[ l:key ] = matchadd( printf( 'WordHighlight%d',
        \ l:key % len( s:highlight_table )), l:pattern )
  endfor
endfunction "}}}

function! s:WordHighlight_Clear() "{{{
  let s:entry_table = {}

  execute printf( 'tabdo windo call WordHighlight_Update() | tabn %d', tabpagenr())
endfunction "}}}

" }}}


" **************************************************************
" {{{
command! -nargs=+ WordHLAdd call s:WordHighlight_Add('<args>')

nnoremap sma <Esc>:WordHLAdd 
nnoremap smm <Esc>:WordHLAdd \<<C-r><C-w>\><CR>

nnoremap <silent> smd <Esc>:call <SID>WordHighlight_Delete()<CR>
nnoremap <silent> smr <Esc>:call <SID>WordHighlight_Clear()<CR>

augroup plugin_vim_simple_word_highlight_
  autocmd!
  autocmd WinEnter * call WordHighlight_Update()
augroup END

" }}}
"
