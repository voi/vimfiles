vim9script

# entries : { id(from count, >0): pattern }
var WordHighlight = {
  colors: [
    'gui=bold ctermfg=16  ctermbg=153 guibg=#0a7383 guifg=#ffffff',
    'gui=bold ctermfg=7   ctermbg=1   guifg=#ffffff guibg=#a07040',
    'gui=bold ctermfg=7   ctermbg=2   guifg=#ffffff guibg=#4070a0',
    'gui=bold ctermfg=7   ctermbg=3   guifg=#ffffff guibg=#40a070',
    'gui=bold ctermfg=7   ctermbg=4   guifg=#ffffff guibg=#70a040',
    'gui=bold ctermfg=7   ctermbg=5   guifg=#ffffff guibg=#0070e0',
    'gui=bold ctermfg=7   ctermbg=6   guifg=#ffffff guibg=#007020',
    'gui=bold ctermfg=7   ctermbg=21  guifg=#ffffff guibg=#d4a00d',
    'gui=bold ctermfg=7   ctermbg=22  guifg=#ffffff guibg=#06287e',
    'gui=bold ctermfg=7   ctermbg=45  guifg=#ffffff guibg=#5b3674',
    'gui=bold ctermfg=7   ctermbg=16  guifg=#ffffff guibg=#4c8f2f',
    'gui=bold ctermfg=7   ctermbg=50  guifg=#ffffff guibg=#1060a0',
    'gui=bold ctermfg=7   ctermbg=56  guifg=#000000 guibg=#a0b0c0',
  ],
  count: 0,
  entries: {}
}

def WordHighlight_Update()
  var tabnr = tabpagenr()
  var winnr = tabpagewinnr(tabnr)
  execute printf('tabdo windo call WordHighlight_Sync() | tabn %d | :%d wincmd w', tabnr, winnr)
enddef

def WordHighlight_Add(word: string)
  var text = word

  if text ==# '' | text = getregion(getpos("'<"), getpos("'>"))->join('') | endif
  if text ==# '' | return | endif

  # check duplicated
  for pattern in values(WordHighlight.entries)
    if pattern ==# text | return | endif
  endfor

  WordHighlight.count += 1
  WordHighlight.entries[ WordHighlight.count ] = text

  call WordHighlight_Update()
enddef

def WordHighlight_Delete()
  var entry_id = inputlist(WordHighlight.entries
    ->items()
    ->map((idx, val) => printf("%d\t%s", val[0]->str2nr(), val[1])))

  if has_key(WordHighlight.entries, entry_id)
    call remove(WordHighlight.entries, entry_id)
    call WordHighlight_Update()
  endif
enddef

def WordHighlight_Sync()
  # initialize
  # entries : { id(from count, >0): syntax-match-ID }
  if !has_key(w:, 'word_highlight_matches')
    w:word_highlight_matches = {}

    for color in WordHighlight.colors
        ->copy()
        ->map((idx, val) => printf('hi! WordHighlight%d %s', idx + 1, val))
      execute color
    endfor
  endif

  # remove old match
  for entry_id in w:word_highlight_matches->keys()
    if !has_key(WordHighlight.entries, entry_id)
      call matchdelete(w:word_highlight_matches[entry_id])
      call remove(w:word_highlight_matches, entry_id)
    endif
  endfor

  # reset current match
  var count = WordHighlight.colors->len()

  for entry_id in WordHighlight.entries->keys()
    if !has_key(w:word_highlight_matches, entry_id)
      w:word_highlight_matches[entry_id] = matchadd(
        printf('WordHighlight%d', (entry_id->str2nr() % count) + 1),
        WordHighlight.entries[entry_id])
    endif
  endfor
enddef

def WordHighlight_Clear()
  WordHighlight.entries = {}

  call WordHighlight_Update()
enddef

command! -nargs=+ WordHLAdd       call WordHighlight_Add('<args>')
command! -range   WordHLVisualAdd call WordHighlight_Add('')

command! WordHLDelete call WordHighlight_Delete()
command! WordHLClear  call WordHighlight_Clear()

augroup plugin_autocmd_word_highlight
  autocmd!
  autocmd WinEnter * call WordHighlight_Sync()
augroup END

