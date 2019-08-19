" vim:foldmethod=marker:fen:
scriptencoding utf-8

""
try
  packadd eskk.vim
catch
  finish
endtry

" ***********************************************
" eskk.vim "{{{
let s:vimrc_cache_dir = expand('~/.eskk/', ':p')

let g:eskk#no_default_mappings = 1

let g:eskk#directory = s:vimrc_cache_dir . '.eskk'

let g:eskk#dictionary = { 'path': s:vimrc_cache_dir . '.skk-jisyo', 'sorted': 0, 'encoding': 'utf-8' }
" let g:eskk#large_dictionary = { 'path': globpath(&rtp, '_skk/empty.skk-jisyo'), 'sorted': 1, 'encoding': 'euc-jp' }
let g:eskk#large_dictionary = { 'path': globpath(&rtp, '_skk/SKK-JISYO.L'), 'sorted': 1, 'encoding': 'euc-jp' }

let g:eskk#sub_dictionaries = extend(
    \ get(g:, 'eskk#sub_dictionaries', []),
    \ map(sort(globpath(&rtp, '_skk/SKK-JISYO.??*', 0, 1)), { -> { 'path': v:val, 'sorted': 1, 'encoding': 'euc-jp' } })
    \ )
" default: encoding=euc-jp, timeout=1000, type=dictionary
" let g:eskk#server = { 'host': 'localhost', 'port': 30001 }
let g:eskk#auto_save_dictionary_at_exit = 1
" let g:eskk#dictionary_save_count = 0

let g:eskk#show_candidates_count = 3
let g:eskk#show_annotation = 1

if 1
  let g:eskk#marker_henkan = '$'
  let g:eskk#marker_henkan_select = '@'
  let g:eskk#marker_jisyo_touroku = '?'
  let g:eskk#marker_okuri = '*'
  let g:eskk#marker_popup = '#'
else
  let g:eskk#marker_henkan = '▽'
  let g:eskk#marker_henkan_select = '▼'
  let g:eskk#marker_jisyo_touroku = '？'
  let g:eskk#marker_okuri = '…'
  let g:eskk#marker_popup = '§'
endif

let g:eskk#enable_completion = 1
let g:eskk#max_candidates = 120 " default:30
let g:eskk#start_completion_length = 1
let g:eskk#register_completed_word = 0
let g:eskk#tab_select_completion = 1

if !get(g:, 'loaded_neocomplete', 0)
  let g:eskk#enable_embed_completion = 1
endif

let g:eskk#egg_like_newline = 1
let g:eskk#egg_like_newline_completion = 1
let g:eskk#keep_state = 0
let g:eskk#keep_state_beyond_buffer = 0
let g:eskk#rom_input_style ='msime'

let g:eskk#debug = 0

function! s:eskk_initial_pre() "{{{
  let t = eskk#table#new('rom_to_hira*', 'rom_to_hira')

  call t.add_map('z~', '～')
  call t.add_map('z(', '（')
  call t.add_map('z)', '）')
  call t.add_map('z0', '０')
  call t.add_map('z1', '１')
  call t.add_map('z2', '２')
  call t.add_map('z3', '３')
  call t.add_map('z4', '４')
  call t.add_map('z5', '５')
  call t.add_map('z6', '６')
  call t.add_map('z7', '７')
  call t.add_map('z8', '８')
  call t.add_map('z9', '９')
  call t.add_map('z ', '　')

  call t.add_map('j,', '，')
  call t.add_map('j.', '．')

  call t.add_map('c1', '①')
  call t.add_map('c2', '②')
  call t.add_map('c3', '③')
  call t.add_map('c4', '④')
  call t.add_map('c5', '⑤')
  call t.add_map('c6', '⑥')
  call t.add_map('c7', '⑦')
  call t.add_map('c8', '⑧')
  call t.add_map('c9', '⑨')

  call eskk#register_mode_table('hira', t)
endfunction "}}}

augroup vimrc-local-eskk-commands "{{{
  autocmd!
  autocmd User eskk-initialize-pre call s:eskk_initial_pre()
augroup END "}}}

" overwrite default ime
silent! imap <unique> <C-^> <Plug>(eskk:toggle)
silent! cmap <unique> <C-^> <Plug>(eskk:toggle)
silent! lmap <unique> <C-^> <Plug>(eskk:toggle)

" skk keymap compatible
silent! imap <unique> <C-j> <Plug>(eskk:toggle)
silent! cmap <unique> <C-j> <Plug>(eskk:toggle)
silent! lmap <unique> <C-j> <Plug>(eskk:toggle)

if !isdirectory(g:eskk#directory)
  call mkdir(g:eskk#directory, 'p')
endif
"}}}

