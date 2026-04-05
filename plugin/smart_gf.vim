vim9script

command! GoToFileEx {
  var path = ''

  if mode() =~# '[vV]'
    path = visualmode() ==# 'V' ? getline('.') :
          \ getregion(getpos("'<"), getpos("'>"))->join('')
  else
    path = expand('<cfile>')
  endif

  if path =~# get(g:, 'smart_gf_executable_binary_pattern', '\v\.(exe|pdf|ppt|mdb|(doc|xls|vsd)[xm]?)$') ||
        \ path =~# '\v([[:alpha:]{2,}])(:\/\/[_0-9A-Za-z\/:%#\$&\?\(\)~\.=\+\-]+)'
    execute 'silent! normal gx'
  else
    if path->filereadable()
      execute 'silent! tabnew' path
    else
      if input('? file is not found, create it? (y) > ') ==? 'y'
        execute 'silent! tabnew' path
      else
        echomsg "can't go to:" path
      endif
    endif
  endif
}

nnoremap <silent> gf :GoToFileEx<CR>
xnoremap <silent> gf :GoToFileEx<CR>

