vim9script


# ###############################
#
var fuzzy_choice_last_cache_buffer = tempname()


export def GetCache(root_dir: string, need_cache: bool, Cacher: func): list<any>
  var root = (root_dir->empty() ? getcwd() : root_dir)->expand()->fnamemodify(':p')
  var bnr = bufadd(fuzzy_choice_last_cache_buffer)

  call bnr->bufload()

  if need_cache
    call setbufvar(bnr, '&buftype', 'nofile')
    call setbufvar(bnr, '&bufhidden', 'hide')
    call setbufvar(bnr, '&swapfile', 0)
    call setbufvar(bnr, 'path', root)

    call Cacher(bnr, root)
  endif

  return [bnr, root]
enddef

