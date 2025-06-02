vim9script

def SmartInputModoki_open_bracket(chr_open: string, chr_close: string): string
  # (| => (|)
  if search('\%#', 'bcnW') > 0
    return chr_open .. chr_close .. "\<Left>"
  endif

  return chr_open
enddef

def SmartInputModoki_close_bracket(chr_open: string, chr_close: string): string
  # |) => )|
  var pattern = '\V' .. chr_open .. '\[^' .. chr_close .. ']\*\%#' .. chr_close

  if search(pattern, 'bcnW') > 0
    return "\<Right>"
  endif

  return chr_close
enddef

def SmartInputModoki_inside_space(): string
  var chr_in = "\<Space>"
  # [|] => [ | ]
  var pattern = '\V' .. (['[\%#]', '(\%#)', '{\%#}']->join('\|'))

  if search(pattern, 'bcnW') > 0
    return chr_in .. chr_in .. "\<Left>"
  endif

  return chr_in
enddef

def SmartInputModoki_inside_enter(): string
  var chr_in = "\<CR>"
  # {|} => {
  #            |
  #        }
  var pattern = '\V' .. (['[\%#]', '(\%#)', '{\%#}']->join('\|'))

  if search(pattern, 'bcnW') > 0
    return chr_in .. "\<Up>" .. "\<End>" .. chr_in
  endif

  return chr_in
enddef

def SmartInputModoki_backspace(): string
  var chr_in = "\<C-h>"
  # [|] => |
  # "|" => |
  # ( | ) => (|)
  var pattern = '\V' .. ([
    '[\%#]', '(\%#)', '{\%#}',
    '"\%#"', "'\\%#'",
    '[\s\%#\s]', '(\s\%#\s)', '{\s\%#\s}']->join('\|'))

  if search(pattern, 'bcnW') > 0
    return "\<Del>" .. chr_in
  endif

  # aaa,  | => aaa|
  if search('\V\<\[_A-Za-z]\w\*\>,\s\*\%#', 'bcnW') > 0
    return "\<C-o>" .. "dF,"
  endif

  return chr_in
enddef

def SmartInputModoki_quote(chr_in: string, chr_alt: string): string
  # "aaa|" => "aaa"|
  var pattern2 = '\V' .. chr_in .. '\[^' .. chr_in .. ']\*\%#' .. chr_in

  if search(pattern2, 'bcnW') > 0
    return "\<Right>"
  endif

  # "aaa|bbb" => "aaa'bbb"
  if !empty(chr_alt)
    var pattern1 = '\V' .. chr_alt .. '\[^' .. chr_alt .. ']\*'
      .. '\%#'
      .. '\[^' .. chr_alt .. ']\*' .. chr_alt

    if search(pattern1, 'bcnW') > 0
      return chr_in
    endif
  endif

  # 
  if search('\%#', 'bcnW') > 0
    return chr_in .. chr_in .. "\<Left>"
  endif

  return chr_in
enddef

inoremap <silent> <expr> [ SmartInputModoki_open_bracket('[', ']')
inoremap <silent> <expr> ( SmartInputModoki_open_bracket('(', ')')
inoremap <silent> <expr> { SmartInputModoki_open_bracket('{', '}')

inoremap <silent> <expr> ] SmartInputModoki_close_bracket('[', ']')
inoremap <silent> <expr> ) SmartInputModoki_close_bracket('(', ')')
inoremap <silent> <expr> } SmartInputModoki_close_bracket('{', '}')

inoremap <silent> <expr> <Space> SmartInputModoki_inside_space()
inoremap <silent> <expr> <CR>    SmartInputModoki_inside_enter()

inoremap <silent> <expr> <C-h> SmartInputModoki_backspace()

inoremap <silent> <expr> ' SmartInputModoki_quote("'", '"')
inoremap <silent> <expr> " SmartInputModoki_quote('"', "'")
inoremap <silent> <expr> ` SmartInputModoki_quote('`', '')

