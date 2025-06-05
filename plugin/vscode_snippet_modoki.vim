vim9script

# { "language" or "_" : { snip.prefix: snip.body } }
var VSCodeSnippet_snippets = {}

def VSCodeSnippet_ParseTextOrList(snip: dict<any>, prop_name: string): list<string>
  var scope = get(snip, prop_name, '')

  if     scope->type() ==# v:t_string | return [scope]
  elseif scope->type() ==# v:t_list   | return scope
  else
    return []
  endif
enddef

def VSCodeSnippet_LoadSnippet(file_path: string, default_scope: string)
  try
    var source = readfile(file_path)
      ->filter((i, v) => v !~# '^\s*\/\/.*$')
      ->join(' ')
      ->json_decode()

    if source->type() !=# v:t_dict
      return
    endif

    # *.code-snippets
    # # { "name": { "scope": ["", ], "prefix":["",], "body": ["",], "description": "" } }
    for [name, snip] in source->items()->filter((i, v) => v[1]->type() ==# v:t_dict)
      var body = VSCodeSnippet_ParseTextOrList(snip, 'body')

      for scope in get(snip, 'scope', default_scope)->split(',')
        var snippets = get(VSCodeSnippet_snippets, scope, {})

        for prefix in VSCodeSnippet_ParseTextOrList(snip, 'prefix')
          snippets[prefix] = body
        endfor

        VSCodeSnippet_snippets[scope] = snippets
      endfor
    endfor
  catch
    echomsg v:exception
  endtry
enddef

def VSCodeSnippet_initialize(force: bool)
  if force
    VSCodeSnippet_snippets = {}
  endif

  if VSCodeSnippet_snippets->empty()
    var pathes = get(g:, 'code_snippet_glob_pathes', &rtp)

    for file_path in globpath(pathes, '*.json', 0, 1)
      call VSCodeSnippet_LoadSnippet(file_path, file_path->fnamemodify(':t:r'))
    endfor

    for file_path in globpath(pathes, '*.code-snippets', 0, 1)
      call VSCodeSnippet_LoadSnippet(file_path, '_')
    endfor
  endif
enddef

def VSCodeSnippet_ExpandVarious(various: string): string
  if     various ==# 'TM_SELECTED_TEXT'         | return @0
  elseif various ==# 'TM_CURRENT_LINE'          | return getline('.')
  elseif various ==# 'TM_CURRENT_WORD'          | return expand('<cword>')
  elseif various ==# 'TM_LINE_INDEX'            | return (line('.') - 1)->string()
  elseif various ==# 'TM_LINE_NUMBER'           | return line('.')->string()
  elseif various ==# 'TM_FILENAME'              | return expand('%:t')
  elseif various ==# 'TM_FILENAME_BASE'         | return expand('%:t:r')
  elseif various ==# 'TM_DIRECTORY'             | return expand('%:p:h')
  elseif various ==# 'TM_FILEPATH'              | return expand('%:p')
  elseif various ==# 'RELATIVE_FILEPATH'        | return expand('%:p')
  elseif various ==# 'CLIPBOARD'                | return @*
  elseif various ==# 'WORKSPACE_NAME'           | return expand('%:p')
  elseif various ==# 'WORKSPACE_FOLDER'         | return expand('%:p:h')
  elseif various ==# 'CURRENT_YEAR'             | return strftime('%Y')
  elseif various ==# 'CURRENT_YEAR_SHORT'       | return strftime('%y')
  elseif various ==# 'CURRENT_MONTH'            | return strftime('%m')
  elseif various ==# 'CURRENT_MONTH_NAME'       | return strftime('%B')
  elseif various ==# 'CURRENT_MONTH_NAME_SHORT' | return strftime('%b')
  elseif various ==# 'CURRENT_DATE'             | return strftime('%d')
  elseif various ==# 'CURRENT_DAY_NAME'         | return strftime('%A')
  elseif various ==# 'CURRENT_DAY_NAME_SHORT'   | return strftime('%a')
  elseif various ==# 'CURRENT_HOUR'             | return strftime('%H')
  elseif various ==# 'CURRENT_MINUTE'           | return strftime('%M')
  elseif various ==# 'CURRENT_SECOND'           | return strftime('%S')
  elseif various ==# 'CURRENT_SECONDS_UNIX'     | return strftime('%s')
  else
    return ''
  endif
enddef

def VSCodeSnippet_MakeBody(prefix: string): list<string>
  var candidates = {}
    ->extend(get(VSCodeSnippet_snippets, getbufvar('%', '&filetype'), {}))
    ->extend(get(VSCodeSnippet_snippets, '_', {}))
  var body = get(candidates, prefix, [])

  if body->type() ==# v:t_list
    body = body->filter((i, v) => v->type() ==# v:t_string)
  elseif body->type() ==# v:t_string
    body = [body]
  else
    body = []
  endif

  return body
    ->map((i, v) => v->substitute('\%(\\\)\@<!$\d\+', '', 'g'))
    ->map((i, v) => v->substitute('\%(\\\)\@<!${\d\+}', '', 'g'))
    ->map((i, v) => v->substitute('\%(\\\)\@<!${\d\+|\([^|}]\+\)|}', '\1', 'g'))
    ->map((i, v) => v->substitute('\%(\\\)\@<!${\d\+:\([^}]\+\)}', '\1', 'g'))
    ->map((i, v) => v->substitute('\%(\\\)\@<!$\([A-Z_]\+\)', '\=VSCodeSnippet_ExpandVarious(submatch(1))', 'g'))
    ->map((i, v) => v->substitute('\%(\\\)\@<!${\([^}]\+\)}', '\=VSCodeSnippet_ExpandVarious(submatch(1))', 'g'))
    ->map((i, v) => v->substitute('\\\$', '$', 'g'))
enddef

#    0123456789A12**|3456789B1234567
#     ↓
#    # replace holder to return-code.
#    0123456789A12
#    3456789B1234567
#     ↓
#    # append snippet lines.
#    0123456789A12
#    {snippet line1}
#    {snippet line2}
#    {snippet line3}
#    3456789B1234567
#     ↓
#    # join start / end line.
#    0123456789A12{snippet line1}
#    {snippet line2}
#    {snippet line3}3456789B1234567
def VSCodeSnippet_insert(word: string, holder: string)
  call VSCodeSnippet_initialize(VSCodeSnippet_snippets->empty())

  var body = VSCodeSnippet_MakeBody(word)
  var lnum = line('.')

  if !body->empty()
    execute ':' .. lnum .. 's/' .. holder .. '/\r/'

    call body->appendbufline(bufnr('%'), lnum)

    execute ':' .. (lnum + body->len()) .. 'join!'
    execute ':' .. lnum .. 'join!'
  endif
enddef

def VSCodeSnippet_complete(argload: string, cmdline: string, cursorpos: number): any
  call VSCodeSnippet_initialize(VSCodeSnippet_snippets->empty())

  return []
    ->extend(get(VSCodeSnippet_snippets, getbufvar('%', '&filetype'), {})->keys())
    ->extend(get(VSCodeSnippet_snippets, '_', {})->keys())
    ->filter((i, v) => v =~# argload)
enddef

command! -nargs=0 VSCodeSnippetInitialize call VSCodeSnippet_initialize(true)

command! -nargs=1 -complete=customlist,VSCodeSnippet_complete VSCodeSnippetInsert 
      \ call VSCodeSnippet_insert(<q-args>, '\%#')
command! -range -nargs=1 -complete=customlist,VSCodeSnippet_complete VSCodeSnippetReplace 
      \ call VSCodeSnippet_insert(<q-args>, '\%V.*\%V.')

