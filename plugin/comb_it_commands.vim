vim9script

import 'comb_it.vim'

# ###############################
#
command! -nargs=? -complete=dir CombItFiles {
  call comb_it.Filer('Files', <q-args>)
}


# ###############################
#
command! -nargs=0 CombItMru {
  var bookmark = get(g:, 'comb_it_vim_mrc_bookmark', '~/.vim_comb_it_mrc_bookmark.txt')
    ->expand()
    ->fnamemodify(':p')
  var items = (filereadable(bookmark) ? readfile(bookmark) : [])
    ->extend(v:oldfiles->copy())

  call comb_it.DoAsFiles('Mru', items)
}


# ###############################
#
def CombIt_action_open_buffer(command_format: string, winid: number, ctx: any, item: any)
  call popup_close(winid)
  execute printf(command_format, item->get('bufnr', 0))
enddef


#
var comb_it_handlers_buffer = {
  "\<CR>": function(CombIt_action_open_buffer, ['buffer %d']),
  "\<C-t>": function(CombIt_action_open_buffer, ['split | buffer %d | wincmd T']),
  "\<C-s>": function(CombIt_action_open_buffer, ['split | buffer %d']),
  "\<C-v>": function(CombIt_action_open_buffer, ['vsplit | buffer %d']),
  "\<C-d>": function(CombIt_action_open_buffer, ['bw %d'])
}


#
def CombIt_command_buffers()
  var icon = get(g:, 'comb_it_icon_buff', '📜')
  var items = range(1, bufnr('$'))
    ->filter((i, v) => buflisted(v) && bufexists(v))
    ->map((i, v) => {
      var bname = v->bufname()

      if v->getbufvar('&buftype', '')->empty()
        bname = printf('%s (%s)', bname->fnamemodify(':t'), bname->fnamemodify(':p:h:~'))
      endif

      return { text: printf('%4d %s %s', v, icon, bname), bufnr: v }
    })

  call comb_it.Do('Buffers', items, comb_it_handlers_buffer)
enddef


#
command! -nargs=0 CombItBuffers call CombIt_command_buffers()


# ###############################
#
def CombIt_action_window_enter(winid: number, ctx: any, item: any)
  call popup_close(winid)
  call item->get('winid', 0)->win_gotoid()
enddef


#
def CombIt_command_windows()
  var items = []
  var icon = get(g:, 'comb_it_icon_buff',  '📜')

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
  var handlers = { "\<CR>": function(CombIt_action_window_enter) }

  call comb_it.Do('Windows', items, handlers)
enddef


#
command! -nargs=0 CombItWindows call CombIt_command_windows()


# ###############################
#
def CombIt_action_lines_enter(winid: number, ctx: any, item: any)
  call popup_close(winid)
  call setpos('.', [item->get('bufnr', ''), item->get('linenr', ''), 1, 0])
enddef


#
command! -nargs=0 CombItLines {
  var bnr = bufnr('%')

  if bnr > 0
    var items = getbufline(bnr, 1, '$')
      ->map((i, v) => ({ text: v, bufnr: bnr, linenr: (i + 1) }) )
      ->filter((i, v) => v.text !~# '^\s*$')
    var handlers = { "\<CR>": function(CombIt_action_lines_enter) }

    call comb_it.Do('Lines', items, handlers)
  endif
}


# ###############################
#
var comb_it_glob_last_cache_buffer = tempname()


#
def CombIt_get_glob_cache(bang: string, root_dir: string): list<any>
  var root = (root_dir->empty() ? getcwd() : root_dir)
  var bnr = bufadd(comb_it_glob_last_cache_buffer)

  call bnr->bufload()

  if bang->empty()
    call setbufvar(bnr, '&buftype', 'nofile')
    call setbufvar(bnr, '&bufhidden', 'hide')
    call setbufvar(bnr, '&swapfile', 0)
    call setbufvar(bnr, 'path', root)

    #
    call deletebufline(bnr, 1, '$')
    call setbufline(bnr, 1, '      0')

    execute 'silent botright :1split'
    execute 'silent buffer ' .. bnr
    redraw

    #
    var ln = 1
    var dirs = [root]
    #
    var max_candidates = get(g:, 'comb_it_glob_max_candidates', 10000)
    var pattern_ignore_dir = get(g:, 'comb_it_glob_regex_ignore_dir', '\v^\.%(git|jj|svn|hg|bzr)$')
    var pattern_ignore_file = get(g:, 'comb_it_glob_regex_ignore_file', '\v^_FOSSIL_$')
    #
    var start_time = reltime()

    while !dirs->empty()
      var dir = dirs->remove(0)

      for entry in readdirex(dir)
        var fullname = dir->expand()->fnamemodify(':p') .. entry.name

        if (entry.type =~# '\v^(dir|linkd)$') && (entry.name !~# pattern_ignore_dir)
          call dirs->add(fullname)

        elseif (entry.type =~# '\v^(file|link)$') && (entry.name !~# pattern_ignore_file)
          ln += (appendbufline(bnr, ln, fullname) ? 1 : 0)
        endif

        if ln > max_candidates
          dirs = []
          break
        endif
      endfor

      call setbufline(bnr, 1, printf('>> %d : %s', ln, dir))
      redraw
    endwhile

    call deletebufline(bnr, 1)

    execute 'silent close'

    echomsg printf('glob / %d : %f : %s', ln, reltimefloat(reltime(start_time)), root->fnamemodify(':~'))
  endif

  return [bnr, root]
enddef


#
command! -nargs=? -complete=dir -bang CombItGlob {
  var [bnr, root] = CombIt_get_glob_cache('<bang>', <q-args>)

  call comb_it.DoAsFiles('Glob', getbufline(bnr, 1, '$'))
}


# ###############################
#
command! -nargs=? -complete=dir -bang CombItGlobCache {
  var [bnr, root] = CombIt_get_glob_cache('<bang>', <q-args>)

  execute 'silent botright :16split'
  execute 'silent buffer ' .. bnr
}

