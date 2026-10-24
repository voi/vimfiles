vim9script

if has('gui_running') && has('win32')
  # font rendering
  set rop=type:directx,renmode:5,taamode:1,contrast:1
  set guifont=Cascadia_Code:h10.5,BIZ_UDゴシック:h11,Consolas:h11
  set guifontwide=BIZ_UDゴシック:h11

  # set guifont/guifontwide
  # - ‐ ─ ― ー 　 → ⇒
  # 1 i I T l | 0 o O θ Θ , . ; : _
  #
  g:vimrc_font_size = '13'
  g:vimrc_guifonts = {
    1: ['Cascadia_Code:h10.5,BIZ_UDゴシック:h11', 'BIZ_UDゴシック:h11'],
    2: ['Cascadia_Code:h10.5,UD_デジタル_教科書体_N:h11', 'UD_デジタル_教科書体_N:h11'],
    3: ['BIZ_UDゴシック:h__'],
    4: ['UD_デジタル_教科書体_N:h__'],
    5: ['Consolas:h__,ＭＳ_ゴシック:h__', 'ＭＳ_ゴシック:h__'],
  }

  def Vimrc_set_guifont(fonts: list<string>, size: string)
    execute printf('set guifont=%s', 
          \ fonts->get(0, '')->substitute('\%(:h\)\zs__', size, 'g'))
    execute printf('set guifontwide=%s',
          \ fonts->get(1, fonts->get(0, ''))->substitute('\%(:h\)\zs__', size, 'g'))
    execute 'set ambiwidth=double'
  enddef

  command! -nargs=? SetGuiFonts {
    var arg = '<args>'
    var fonts = get(g:, 'vimrc_guifonts', {})
    var i = arg->empty()
          \ ? fonts->items()->map((i, v) => v[0] .. "\t" .. v[1]->string())->sort()->inputlist()
          \ : arg->str2nr()

    if fonts->has_key(i)
      call Vimrc_set_guifont(fonts->get(i, []), get(g:, 'vimrc_font_size', '11'))
    endif
  }

  # zoom in / out and reset
  g:vimrc_zoom_guifont_original = []

  command! ZoomIn {
    if g:vimrc_zoom_guifont_original->empty()
      g:vimrc_zoom_guifont_original = [&guifont, &guifontwide]
    endif

    var SizeUp = (setfont) => setfont->substitute('\%(:h\)\zs\(\d\+\)', (m) => m[1]->str2nr() + 1, 'g')

    execute 'set guifont=' .. SizeUp(&guifont)
    execute 'set guifontwide=' .. SizeUp(&guifontwide)
  }

  command! ZoomOut {
    if g:vimrc_zoom_guifont_original->empty()
      g:vimrc_zoom_guifont_original = [&guifont, &guifontwide]
    endif

    var SizeDown = (setfont) => setfont->substitute('\%(:h\)\zs\(\d\+\)', (m) => max([1, m[1]->str2nr() - 1]), 'g')

    execute 'set guifont=' .. SizeDown(&guifont)
    execute 'set guifontwide=' .. SizeDown(&guifontwide)
  }

  command! ZoomReset {
    if !g:vimrc_zoom_guifont_original->empty()
      execute 'set guifont=' .. get(g:vimrc_zoom_guifont_original, 0, '')
      execute 'set guifontwide=' .. get(g:vimrc_zoom_guifont_original, 1, '')

      g:vimrc_zoom_guifont_original = []
    endif
  }

endif

