vim9script

scriptencoding utf-8

# ***********************************************
try
  packadd eskk.vim

catch
  inoremap <silent> <C-j> <C-^>
  finish
endtry

# eskk.vim "{{{
g:eskk#no_default_mappings = 1

g:eskk#directory = expand('~/vimfiles/_skk')

g:eskk#dictionary = { 'path': '~/vimfiles/_skk/.skk-jisyo', 'sorted': 0, 'encoding': 'utf-8' }
g:eskk#large_dictionary = { 'path': globpath(&rtp, '_skk/SKK-JISYO.merge'), 'sorted': 1, 'encoding': 'utf-8' }
g:eskk#auto_save_dictionary_at_exit = 1

g:eskk#show_candidates_count = 3
g:eskk#show_annotation = 1

if 1
  g:eskk#marker_henkan = '$'
  g:eskk#marker_henkan_select = '@'
  g:eskk#marker_jisyo_touroku = '?'
  g:eskk#marker_okuri = '*'
  g:eskk#marker_popup = '#'
else
  g:eskk#marker_henkan = '▽'
  g:eskk#marker_henkan_select = '▼'
  g:eskk#marker_jisyo_touroku = '？'
  g:eskk#marker_okuri = '…'
  g:eskk#marker_popup = '§'
endif

g:eskk#enable_completion = 1
g:eskk#max_candidates = 120 # default:30
g:eskk#start_completion_length = 1
g:eskk#register_completed_word = 0
g:eskk#tab_select_completion = 1

if !get(g:, 'loaded_neocomplete', 0)
  g:eskk#enable_embed_completion = 1
endif

g:eskk#egg_like_newline = 1
g:eskk#egg_like_newline_completion = 1
g:eskk#keep_state = 0
g:eskk#keep_state_beyond_buffer = 0
g:eskk#rom_input_style ='msime'

g:eskk#debug = 0

def Eskk_initial_pre() # {{{
  var t = eskk#table#new('rom_to_hira*', 'rom_to_hira')

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

  call g:eskk#register_mode_table('hira', t)
enddef # }}}

augroup vimrc-local-eskk-commands # {{{
  autocmd!
  autocmd User eskk-initialize-pre call Eskk_initial_pre()
augroup END # }}}

# overwrite default ime
silent! imap <unique> <C-^> <Plug>(eskk:toggle)
silent! cmap <unique> <C-^> <Plug>(eskk:toggle)
silent! lmap <unique> <C-^> <Plug>(eskk:toggle)

# skk keymap compatible
silent! imap <unique> <C-j> <Plug>(eskk:toggle)
silent! cmap <unique> <C-j> <Plug>(eskk:toggle)
silent! lmap <unique> <C-j> <Plug>(eskk:toggle)

if !isdirectory(g:eskk#directory)
  call mkdir(g:eskk#directory, 'p')
endif
# }}}

