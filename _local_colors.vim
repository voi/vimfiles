if has('gui_win32')
  let colors = [
      \ g:colors_name,
      \ 'spring-night',
      \ 'fruchtig',
      \ 'wombat256grf',
      \ 'tango'
      \ ]
  execute 'colorscheme ' . colors[(len(split(serverlist(), '\n')) -1) % len(colors)]
endif

