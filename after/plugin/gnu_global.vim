vim9script

if executable('global')
  const global_util_out_buffer = tempname() .. '-gtags'
  const global_util_gtag_cmd_word = '   -q    --result=ctags-mod'
  const global_util_gtag_cmd_file = '-f -q    --result=ctags-mod'
  const global_util_gtag_cmd_inc  = '-P -q -a --result=ctags'
  const global_util_gtag_cmd_grep = '-g -q -a --result=ctags'
  const global_util_gtag_cmd_tags = '   -q -a --result=ctags'

  def GlobalUtil_make_cmd(base: string, alt: string, word: string): list<string>
    var bin_name = 'global'

    return [
      [bin_name, base, word]->join(' '),
      (alt->empty() ? [] : [bin_name, base, alt, word])->join(' ')
    ]
  enddef

  def GlobalUtil_get_output(cmd1: string, cmd2: string): number
    var bnr = bufadd(global_util_out_buffer)

    call bufload(bnr)

    call setbufvar(bnr, '&buftype', 'nofile')
    call setbufvar(bnr, '&bufhidden', 'hide')
    call setbufvar(bnr, '&swapfile', 0)

    execute 'silent botright :1split'
    execute 'silent buffer ' .. bnr

    redraw

    execute 'silent :%!' .. cmd1

    if !cmd2->empty()
      execute 'silent :$r !' .. cmd2
      execute 'silent :%sort u'
    endif

    execute 'silent wincmd c'

    return bnr
  enddef

  def GlobalUtil_list_tags(base: string, word: string, bang: string)
    var [cmd1, cmd2] = GlobalUtil_make_cmd(base, (bang->empty() ? '-r' : ''), word)
    var bnr = GlobalUtil_get_output(cmd1, cmd2)

    call setqflist([], 'r', { 'efm': "%f\t%l\t%m", 'lines': getbufline(bnr, 1, '$') })

    silent topleft cwindow 16
  enddef

  def GlobalUtil_tags_of_word(word: string, bang: string)
    GlobalUtil_list_tags(global_util_gtag_cmd_word, word, bang)
  enddef

  def GlobalUtil_tags_in_file(file: string, bang: string)
    GlobalUtil_list_tags(global_util_gtag_cmd_file, file, bang)

    call matchadd('Conceal', '^.\+|\d\+\%(\s*col\s*\d\+\)\?|')

    setl concealcursor=n
    setl conceallevel=3
  enddef

  def GlobalUtil_includeexpr(fname: string): string
    var [cmd1, cmd2] = GlobalUtil_make_cmd(global_util_gtag_cmd_inc, '', fname)
    var bnr = GlobalUtil_get_output(cmd1, cmd2)

    return getbufline(bnr, 1, '$')
  enddef

  def GlobalUtil_tagfunc(pattern: string, flag: string, info: any): list<any>
    var [cmd1, cmd2] = GlobalUtil_make_cmd(
      (flag ==# 'i' ? global_util_gtag_cmd_grep : global_util_gtag_cmd_tags), '', pattern)
    var bnr = GlobalUtil_get_output(cmd1, cmd2)

    # -t => efm: "%o\t%f\t%l"
    return getbufline(bnr, 1, '$')
      ->map((i, v) => {
        var a_ = v->split('\t')

        return { 'name': a_[0], 'filename': a_[1], 'cmd': a_[2] }
      })
  enddef

  command! -bang -nargs=1                GTags  call GlobalUtil_tags_of_word(<q-args>, '<bang>')
  command! -bang -nargs=1 -complete=file GFTags call GlobalUtil_tags_in_file(<q-args>, '<bang>')

  augroup global_util_vim_autocmd
    autocmd!
    autocmd FileType c,cpp setl path+=./;/
          \ includeexpr=GlobalUtil_includeexpr(v:fname)
          \ tagfunc=GlobalUtil_tagfunc
  augroup END
endif

