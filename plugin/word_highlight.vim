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

" id-count
let s:total_entry_cont = 0

" { id-count:, pattern; }
let s:global_entries = {}

" { id-count:, match-id; }
" let w:current_entries

" }}}


" **************************************************************
" {{{
"" 
function! s:word_highlight_update() abort "{{{
  let tabnr = tabpagenr()
  let winnr = tabpagewinnr(tabnr)
  execute printf( 'tabdo windo call WordHighlight_Update() | tabn %d | %d wincmd w', tabnr, winnr)
endfunction "}}}

"" 
function! s:WordHighlight_Add(word) abort "{{{
  if a:word ==# '' | return | endif

  " check duplicated
  for pattern in values( s:global_entries )
    if pattern ==# a:word | return | endif
  endfor

  let s:global_entries[ s:total_entry_cont ] = a:word
  let s:total_entry_cont += 1

  call s:word_highlight_update()
endfunction "}}}

"" 
function! s:WordHighlight_Delete() abort "{{{
  " select
  for [ key, l:pattern ] in items( s:global_entries )
    execute printf( 'echohl %s | echo %s | echohl None',
        \ printf( 'WordHighlight%d', key ),
        \ printf( '"%4d: %s"', key, escape( l:pattern, '\\' )))
  endfor

  let key = str2nr( input('no > '), 10 )

  "
  if has_key( s:global_entries, key )
    call remove(s:global_entries, key)

    call s:word_highlight_update()
  endif
endfunction "}}}

"" 
function! WordHighlight_Update() abort "{{{
  " hi
  for [key, val] in map(copy(s:highlight_table), { idx, val -> [ idx, val ] })
    execute printf( 'hi! WordHighlight%d %s', key, val )
  endfor

  " remove current syntax
  for id in values(get( w:, 'current_entries', {}))
    call matchdelete( id )
  endfor

  let w:current_entries = {}

  " update syntax from global syntax
  let len = len( s:highlight_table )

  for [ key, pattern ] in items( s:global_entries )
    let w:current_entries[ key ] = matchadd(
        \ printf( 'WordHighlight%d', key % len ),
        \ s:global_entries[ key ] )
  endfor
endfunction "}}}

"" 
function! s:WordHighlight_Clear() "{{{
  let s:global_entries = {}

  call s:word_highlight_update()
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
