
vim9script


# ##############################
var duplicate_check = {}

def ListUpHelpToc(buffer: dict<any>, lines: list<string>)
  for line in lines
    if line =~# 'get(g:,.*)'
      var gvgets = line->matchlist('get(g:,\s\+'
            \ .. '\(' .. "'[^']\\+'" .. '\|"[^"]\+"\),\s\+'
            \ .. '\(' .. "'[^']*'" .. '\|"[^"]*"\|[^)]\+\))')
      #
      var vname = gvgets->get(1, '')

      vname = vname->substitute("^'\\|'$", '', 'g')
      vname = vname->substitute('^"\|"$', '', 'g')

      #
      var vdefault = gvgets->get(2, '')

      if !vname->empty() && !duplicate_check->has_key(vname)
        #
        duplicate_check[vname] = 1

        call buffer.variables->add([vname, vdefault])
      endif

    elseif line =~# '\<command!\s'
      var cmddef = line->matchlist('^\s*command!\s\+\(\%(-\S\+\s\+\)*\)\([A-Z]\w\+\)')

      #
      var ccomp = cmddef->get(1, '')->matchlist('-complete=\(\w\+\)')->get(1, '')
      var cbang = cmddef->get(1, '')->matchstr('-bang')

      #
      var cname = cmddef->get(2, '')

      if !cname->empty() && !duplicate_check->has_key(cname)
        #
        duplicate_check[cname] = 1

        call buffer.commands->add([cname, ccomp, (cbang->empty() ? '' : '[!]')])
      endif
    endif
  endfor
enddef

var root = $MYVIMRC->fnamemodify(':h')
var toc = []


# ##############################################################
for script in [$MYVIMRC]
  var lines = readfile(script)
  var buffer = { fname: script->fnamemodify(':t'), variables: [], commands: [] }

  call ListUpHelpToc(buffer, lines)

  toc->add(buffer)
endfor


# ##############################################################
for script in globpath(root, 'import/*.vim', 0, 1)
  var lines = readfile(script)
  var buffer = { fname: script->fnamemodify(':t'), variables: [], commands: [] }

  call ListUpHelpToc(buffer, lines)

  toc->add(buffer)
endfor


# ##############################################################
for script in globpath(root, 'plugin/*.vim', 0, 1)
  var lines = readfile(script)
  var buffer = { fname: script->fnamemodify(':t'), variables: [], commands: [] }

  call ListUpHelpToc(buffer, lines)

  toc->add(buffer)
endfor


# ##############################################################
for script in globpath(root, 'syntax/markdown.vim', 0, 1)
  var lines = readfile(script)
  var buffer = { fname: script->fnamemodify(':t'), variables: [], commands: [] }

  call ListUpHelpToc(buffer, lines)

  toc->add(buffer)
endfor


# ##############################################################
var contents = [
  '*vimrc-help.txt* for my vimrc scripts   Last change: ' .. strftime('%Y-%m-%d'),
  '',
  '        command and various reference provided my vimrc',
  '',
  '',
  '==============================================================================',
  '',
  '1. global variables',
  '' ]

for item in toc
  var variables = item.variables

  if !variables->empty()
    contents->extend(['-------------------', item.fname, ''])

    for vinfo in variables
      var vdefault = vinfo->get(1)
      var vtype = '?'

      if vdefault =~# '^"' || vdefault =~# "^'" | vtype = 'string'
      elseif vdefault =~# '^[' | vtype = 'list'
      elseif vdefault =~# '^\d+$' | vtype = 'number'
      endif

      if vdefault =~# '^"[^"]\+"$' || vdefault =~# "^'[^']\\+'$" | vdefault = '`' .. vdefault .. '`'
      elseif vdefault =~# '^&' | vdefault = '|' .. vdefault .. '|'
      endif

      contents->extend([
        printf('*g:%s*', vinfo->get(0)),
        printf('%s%s (default %s)', repeat("\t", 6), vtype, vdefault),
        ''
      ])
    endfor
  endif
endfor

contents->extend([
  '==============================================================================',
  '2. command',
  '' ])

for item in toc
  var commands = item.commands

  if !commands->empty()
    contents->extend(['-------------------', item.fname, ''])

    for cinfo in commands
      var cname = cinfo->get(0)
      contents->extend([
        printf('%s:*%s*', repeat("\t", 6), cname),
        printf('%s%s', cname, cinfo->get(2)),
        ''
      ])
    endfor
  endif
endfor

contents->extend([
  '',
  'vim:tw=78:fo=tcq2:isk=!-~,^*,^\|,\":sw=8:ts=8:sts=8:ft=help:norl:et:'
])

call writefile(contents, $MYVIMRC->substitute('\<[._]\?vimrc$', 'vim-plugin-help.txt', ''))

