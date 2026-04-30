vim9script

# ###############################
export def Map(chr: string, maps: list<list<string>>): string
  for m in maps
    var pattern = get(m, 0, '')
    var input = get(m, 1, '')

    if pattern->empty() || input->empty()
      continue
    endif

    if search(pattern, 'bcnW') > 0
      return input
    endif
  endfor

  return chr
enddef

