vim9script

# ###############################
export var logs = []

export def Map(chr: string, maps: list<list<string>>): string
  logs = []

  for [i, m] in maps->items()
    var pattern = get(m, 0, '')
    var input = get(m, 1, '')

    if pattern->empty() || input->empty()
      continue
    endif

    if search(pattern, 'bcnW') > 0
      call logs->add(printf('OK : %d : %s', i, pattern))
      return input
    else
      call logs->add(printf('NG : %d : %s', i, pattern))
    endif
  endfor

  return chr
enddef

