vim9script

const URL_PATTERN = '\v([[:alpha:]{2,}])(:\/\/[_0-9A-Za-z\/:%#\$&\?\(\)~\.=\+\-]+)'
const DEFAULT_OPENER = has('win32') ? 'start' : 'open'

def SmartGF_goto_url(source: string): bool
  if source =~# URL_PATTERN && source !~# '^file:\/\/'
    var url = source

    if &encoding !=# &termencoding
      url = source->iconv(&encoding, &termencoding)
    endif

    var browser = get(g:, 'smart_gf_web_browser_command', '')

    execute printf(':silent !%s %s "%s"', DEFAULT_OPENER, browser, url->escape('%'))

    return true
  else
    return false
  endif
enddef

def SmartGF_goto_path(source: string): bool
  if source =~# '[\\/]$'
    return false
  endif

  var path = source->substitute('^file:/\{1,3}', '', '')->fnamemodify(':p')

  if path =~# get(g:, 'smart_gf_executable_binary_pattern', '\v\.(exe|docx?|xls[xm]?|vsdx?|pdf)$')
    if path->filereadable()
      execute printf(':silent !%s "%s"', DEFAULT_OPENER, path)

      return true
    else
      return false
    endif
  else
    if !path->filereadable()
      if input('? file is not found, create it? (y) > ') !=? 'y'
        return false
      endif
    endif
  endif

  execute 'silent! tabnew' path

  return true
enddef

def SmartGF_get_matched_cfile(source: string, pattern: string): string
  var c_ = col('.')
  var i_ = 0
  var m_ = []

  while i_ < source->len()
    m_ = matchstrpos(source, pattern, i_)
    i_ = m_[2] + 1

    if m_[0]->empty() | break | endif
    if m_[1] <= c_ && c_ <= m_[2] | return m_[0] | endif
  endwhile

  return ''
enddef

def SmartGF_get_special_cfile(source: string): string
  var text = ''

  if &filetype ==# 'markdown'
    #
    text = SmartGF_get_matched_cfile(source, '\]\zs(<\%([^>]\|\\>\)\+>')

    if !text->empty() | return text->substitute('^(<\|>$', '', 'g') | endif

    #
    text = SmartGF_get_matched_cfile(source, '\]\zs("\%([^"]\|\\"\)\+"')

    if !text->empty() | return text->substitute('^("\|"$', '', 'g') | endif

    #
    text = SmartGF_get_matched_cfile(source, '\]\zs(\%([^)]\|\\)\)\+)')

    if !text->empty() | return text->substitute('^(\|)$', '', 'g') | endif
  endif

  return text
enddef

def SmartGF_goto(is_visual: bool)
  var text = ''

  if is_visual
    text = visualmode() ==# 'V' ? getline('.') :
          \ getregion(getpos("'<"), getpos("'>"))->join('')

  else
    text = SmartGF_get_special_cfile(getline('.'))

    if text->empty()
      text = expand('<cfile>')
    endif
  endif

  if !text->empty()
    if SmartGF_goto_url(text)  | return | endif
    if SmartGF_goto_path(text) | return | endif
  endif

  echomsg "can't go to:" text
enddef

nnoremap <silent> gf :call <SID>SmartGF_goto(v:false)<CR>
xnoremap <silent> gf :call <SID>SmartGF_goto(v:true)<CR>

