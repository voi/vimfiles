if has('gui_win32')
  let colors = [
      \ g:colors_name,
      \ 'spring-night',
      \ 'fruchtig',
      \ 'artesanal',
      \ 'atomic',
      \ 'mojave',
      \ 'desert-warm-256',
      \ 'disco',
      \ 'tango-desert',
      \ 'tango-morning'
      \ ]
  execute 'colorscheme ' . colors[(len(split(serverlist(), '\n')) -1) % len(colors)]
endif

