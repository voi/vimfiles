vim9script

import 'fuzzy_choice_path.vim'
import 'cache_buffer.vim'
type FuzzyChoicePath = fuzzy_choice_path.FuzzyChoicePath
type CacheBuffer = cache_buffer.CacheBuffer


# ###############################
# fuzzy choice glob # {{{1
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
var glob_cache = []

def FuzzyChoice_glob(arguments: list<string>)
  var dir = arguments->get(0, '')

  if glob_cache->empty() || !'<bang>'->empty() || dir !=# glob_cache->get(0, '')
    var cb = CacheBuffer.new(dir)

    glob_cache = [cb.bufnr, cb.root]
  endif

  #
  call FuzzyChoice_glob_make_cache(glob_cache[0], glob_cache[1])

  var items = getbufline(glob_cache[0], 1, '$')

  if items->empty()
    echomsg 'FuzzyChoiceGlob : no candidates.'
  else
    call FuzzyChoicePath.Do('Glob', items)
  endif
enddef

command! -nargs=? -complete=dir -bang FuzzyChoiceGlob call FuzzyChoice_glob([<f-args>])
# }}}

