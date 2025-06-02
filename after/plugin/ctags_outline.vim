vim9script

if executable('ctags')
  const ctags_outline_lang_opt_map = {
    cpp: 'c++ --kinds-c++=dfghsuxcn',
    cs:  'c#  --kinds-c#=cdEfgimnpst',
    vim: 'vim --kinds-vim=acfmv'
  }
  const ctags_outline_in_buffer = tempname() .. '-in-ctags'
  const ctags_outline_out_buffer = tempname() .. '-out-ctags'

  def CtagsOutline_get_output(): number
    #
    # execute 'w! ' .. ctags_outline_in_buffer
    #
    var source = []
    var is_continuous = v:false
    var is_skip_lines = v:false

    for line in getbufline('%', 1, '$')
      if !is_continuous
        is_skip_lines = (line =~# '^\s*#\w\+' && line !~# '^\s\*#define\s\w\+')
      endif

      call source->add((is_skip_lines ? '' : line))

      is_continuous = (line =~# '\s\+\\\s*$')
    endfor

    call writefile(source, ctags_outline_in_buffer)

    #
    # ctags -n -f - --language-force=c++ reftag.c
    # x   reftag.c        /^struct TYPE { int x, y; };$/;"        m       struct:TYPE     typeref:typename:int    file:
    var cmd1 = [
      'ctags -n -f - --sort=no --fields=SsKz --with-list-header=no',
      '--language-force=' .. ctags_outline_lang_opt_map->get(&filetype, &filetype),
      ctags_outline_in_buffer
    ]->join(' ')

    #
    var bnr = bufadd(ctags_outline_out_buffer)

    call bufload(bnr)
    call setbufvar(bnr, '&buftype', 'nofile')
    call setbufvar(bnr, '&bufhidden', 'hide')
    call setbufvar(bnr, '&swapfile', 0)

    execute 'silent botright :1split'
    execute 'silent buffer ' .. bnr

    redraw

    execute 'silent :%!' .. cmd1
    execute 'silent wincmd c'

    return bnr
  enddef

  def Ctags_outline_show()
    var bnr0 = bufnr('%')
    var bnr = CtagsOutline_get_output()
    var contents = []

    for line in getbufline(bnr, 1, '$')
      var taginfo = line->substitute('[\n\r]$', '', '')->split('\t')
      var name = taginfo->get(0, '')
      var lnum = taginfo->get(2, '')->substitute(';"', '', '')->str2nr()
      var signature = ''
      var kind = ''

      for field in taginfo[3 : ]
        if     field =~# '^kind:'      | kind = field->substitute('^\w\+:', ' : ', '')
        elseif field =~# '^signature:' | signature = field->substitute('^\w\+:', ' ', '')
        endif
      endfor

      call contents->add({
        'bufnr': bnr0,
        'filename': bufname(bnr0),
        'lnum': lnum,
        'text': name .. signature .. kind
      })
    endfor

    call contents->sort((i1, i2) => i1.lnum - i2.lnum )
    call setqflist([], 'r', { 'items': contents, 'title': 'ctags ' .. bufname(bnr0) })

    silent topleft cwindow 16

    call matchadd('Conceal', '^.\+|\d\+\%(\s*col\s*\d\+\)\?|')
    call matchadd('Ignore', '\.\.')
    call matchadd('SpecialKey', '(.*)\ze\%( : \w\+\)$')
    call matchadd('Define', ' : \w\+$')
    call matchadd('SpecialKey', '__anon\w\+')

    setl concealcursor=n
    setl conceallevel=3
  enddef

  command! CtagsOutline call Ctags_outline_show()
endif

