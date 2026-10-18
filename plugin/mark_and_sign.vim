vim9script

import 'fuzzy_choice.vim' as FuzzyChoice


class MarkAndSign
  #
  static var _local_mark_chars: string = 'abcdefghijklmnopqrstuvwxyz'
  static var _global_mark_chars: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'


  #
  static def _GetMarks(mark_chars: string): list<any>
    try
      return execute('marks ' .. mark_chars)
        ->split('\n')
        ->filter((i, v) => v =~# '^\s\+[[:alpha:]]\>' )
        ->map((i, v) => v->matchlist('^\s\+\([[:alpha:]]\)\s\+\(\d\+\)\s\+\(\d\+\)\s\+\(\S.*\)'))
        ->map((i, v) => ({ mark: v[1], line: v[2]->str2nr(), col: v[3]->str2nr(), path: v[4] }))
    catch
      return []
    endtry
  enddef


  #
  static def UpdateSign()
    #
    call sign_undefine()

    #
    for m in MarkAndSign._GetMarks((_local_mark_chars .. _global_mark_chars))
      var hi = (m.mark =~# '[a-z]' ? 'WarningMsg' : 'ErrorMsg')
      var path = (filereadable(m.path) ? m.path->fnamemodify(':p') : expand('%:p'))

      execute printf('sign define %d text=%s texthl=%s', m.line, m.mark, hi)
      execute printf('sign place %d line=%d name=%d file=%s', m.line, m.line, m.line, path)
    endfor

    #
    redraw!
  enddef


  #
  static def Toggle(is_local: bool)
    #
    var mark_chars = (is_local ? MarkAndSign._local_mark_chars : MarkAndSign._global_mark_chars)
    var marked = MarkAndSign._GetMarks(mark_chars)

    #
    var current_lnum = line('.')
    var current_mark = marked
      ->copy()
      ->filter((i, v) => v.line == current_lnum )

    if current_mark->empty()
      #
      var used_chars_regexp = printf('[%s]', marked->copy()->map((i, v) => v.mark)->join(''))
      var next_char = (mark_chars->substitute(used_chars_regexp, '', 'g'))[0 : 0]

      if next_char->len() > 0
        execute('mark ' .. next_char)
      endif

    else
      #
      execute('delmarks ' .. current_mark[0].mark)
    endif

    call MarkAndSign.UpdateSign()
  enddef


  #
  static def Clear(is_all: bool)
    execute printf('delmarks a-z %s', (is_all ? 'A-Z' : ''))

    call MarkAndSign.UpdateSign()
  enddef


  #
  static def PopupAction(winid: number, ctx: any, item: any)
    call popup_close(winid)

    execute 'normal `' .. item->get('mark', "'")
  enddef


  #
  static def Popup()
    var marked = MarkAndSign._GetMarks((MarkAndSign._local_mark_chars .. MarkAndSign._global_mark_chars))

    if marked->empty()
      echomsg '`a-zA-Z is not marked.'
    else
      for m in marked | m.text = printf(" %s %d\t%d %s", m.mark, m.line, m.col, m.path) | endfor

      var handlers = { "\<CR>": function(MarkAndSign.PopupAction) }

      call FuzzyChoice.Open('Marks', marked, handlers)
    endif
  enddef
endclass


#
augroup autocommands_marking_vim
  autocmd!
  autocmd BufEnter,CmdwinEnter * call MarkAndSign.UpdateSign()
augroup END


#
command! -bang MarkAndSignToggle call MarkAndSign.Toggle('<bang>'->empty())
command! -bang MarkAndSignClear  call MarkAndSign.Clear('<bang>'->empty())
command! -bang MarkAndSignPopup  call MarkAndSign.Popup()

