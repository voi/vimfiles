vim9script

import 'fuzzy_choice.vim'


# ###############################
#
command! -nargs=? -complete=dir FuzzyChoiceFiles {
  call fuzzy_choice.Filer('Files', <q-args>)
}


# ###############################
#
command! -nargs=0 FuzzyChoiceMru {
  var bookmark = get(g:, 'fuzzy_choice_vim_mru_bookmark', '~/.vim_fuzzy_choice_mru_bookmark.txt')
    ->expand()
    ->fnamemodify(':p')
  var items = (filereadable(bookmark) ? readfile(bookmark) : [])
    ->extend(v:oldfiles->copy())

  call fuzzy_choice.DoAsFiles('Mru', items)
}


# ###############################
#
def FuzzyChoice_action_open_buffer(command_format: string, winid: number, ctx: any, item: any)
  call popup_close(winid)
  execute printf(command_format, item->get('bufnr', 0))
enddef


#
var fuzzy_choice_handlers_buffer = {
  "\<CR>": function(FuzzyChoice_action_open_buffer, ['buffer %d']),
  "\<C-t>": function(FuzzyChoice_action_open_buffer, ['split | buffer %d | wincmd T']),
  "\<C-s>": function(FuzzyChoice_action_open_buffer, ['split | buffer %d']),
  "\<C-v>": function(FuzzyChoice_action_open_buffer, ['vsplit | buffer %d']),
  "\<C-d>": function(FuzzyChoice_action_open_buffer, ['bw %d'])
}


#
def FuzzyChoice_command_buffers()
  var icon = get(g:, 'fuzzy_choice_icon_buff', '📜')
  var items = range(1, bufnr('$'))
    ->filter((i, v) => buflisted(v) && bufexists(v))
    ->map((i, v) => {
      var bname = v->bufname()

      if v->getbufvar('&buftype', '')->empty()
        bname = printf('%s (%s)', bname->fnamemodify(':t'), bname->fnamemodify(':p:h:~'))
      endif

      return { text: printf('%4d %s %s', v, icon, bname), bufnr: v }
    })

  call fuzzy_choice.Do('Buffers', items, fuzzy_choice_handlers_buffer)
enddef


#
command! -nargs=0 FuzzyChoiceBuffers call FuzzyChoice_command_buffers()


# ###############################
#
def FuzzyChoice_action_window_enter(winid: number, ctx: any, item: any)
  call popup_close(winid)
  call item->get('winid', 0)->win_gotoid()
enddef


#
def FuzzyChoice_command_windows()
  var items = []
  var icon = get(g:, 'fuzzy_choice_icon_buff',  '📜')

  for tnr in range(1, tabpagenr('$'))
    for wnr in tnr->tabpagewinnr('$')->range()->map((i, v) => v + 1)
      var bnr = wnr->winbufnr()

      if !bnr->getbufvar('&buftype', '')->empty()
        continue
      endif

      var bname = bnr->bufname()
      var caption = printf('%s (%s)', bname->fnamemodify(':t'), bname->fnamemodify(':p:h'))

      call items->add({
        'text': printf("[%2d,%2d]%s %s", tnr, wnr, icon, caption),
        'winid': win_getid(wnr, tnr)
      })
    endfor
  endfor

  #
  var handlers = { "\<CR>": function(FuzzyChoice_action_window_enter) }

  call fuzzy_choice.Do('Windows', items, handlers)
enddef


#
command! -nargs=0 FuzzyChoiceWindows call FuzzyChoice_command_windows()


# ###############################
#
def FuzzyChoice_action_lines_enter(winid: number, ctx: any, item: any)
  call popup_close(winid)
  call setpos('.', [item->get('bufnr', ''), item->get('linenr', ''), 1, 0])
enddef


#
command! -nargs=0 FuzzyChoiceLines {
  var bnr = bufnr('%')

  if bnr > 0
    var items = getbufline(bnr, 1, '$')
      ->map((i, v) => ({ text: v, bufnr: bnr, linenr: (i + 1) }) )
      ->filter((i, v) => v.text !~# '^\s*$')
    var handlers = { "\<CR>": function(FuzzyChoice_action_lines_enter) }

    call fuzzy_choice.Do('Lines', items, handlers)
  endif
}


# ###############################
#
def FuzzyChoice_glob_make_cache(bnr: number, root: string)
  #
  call deletebufline(bnr, 1, '$')
  call setbufline(bnr, 1, '      0')

  execute 'silent botright :1split'
  execute 'silent buffer ' .. bnr
  redraw

  #
  var lnum = 1
  var dirs = [root]
  #
  var max_candidates = get(g:, 'fuzzy_choice_glob_max_candidates', 10000)
  var pattern_ignore_dir = get(g:, 'fuzzy_choice_glob_regex_ignore_dir', '\v^\.%(git|jj|svn|hg|bzr)$')
  var pattern_ignore_file = get(g:, 'fuzzy_choice_glob_regex_ignore_file', '\v^_FOSSIL_$')
  #
  var start_time = reltime()

  while !dirs->empty()
    var dir = dirs->remove(0)

    try
      for entry in readdirex(dir)
        var fullname = dir->expand()->fnamemodify(':p') .. entry.name

        if (entry.type =~# '\v^(dir|linkd)$') && (entry.name !~# pattern_ignore_dir)
          call dirs->add(fullname)

        elseif (entry.type =~# '\v^(file|link)$') && (entry.name !~# pattern_ignore_file)
          lnum += (0 == appendbufline(bnr, lnum, fullname) ? 1 : 0)
        endif

        if lnum > max_candidates
          dirs = []
          break
        endif
      endfor
    catch
      break
    endtry

    call setbufline(bnr, 1, printf('>> %d : %s', lnum, dir))
    redraw
  endwhile

  call deletebufline(bnr, 1)

  execute 'silent close'

  echomsg printf('fuzzy choice cache / %d : %f : %s',
    lnum, reltimefloat(reltime(start_time)), root->fnamemodify(':~'))
enddef


#
command! -nargs=? -complete=dir -bang FuzzyChoiceGlob {
  var [bnr, root] = fuzzy_choice.GetCache(<q-args>, '<bang>'->empty(), FuzzyChoice_glob_make_cache)

  call fuzzy_choice.DoAsFiles('Glob', getbufline(bnr, 1, '$'))
}


# ###############################
#
command! -nargs=? -complete=dir -bang FuzzyChoiceGlobCache {
  var [bnr, root] = fuzzy_choice.GetCache(<q-args>, '<bang>'->empty(), FuzzyChoice_glob_make_cache)

  execute 'silent botright :16split'
  execute 'silent buffer ' .. bnr
}

