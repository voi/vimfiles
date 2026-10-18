vim9script

command! GoToFileEx {
  var path = ''

  if mode() =~# '[vV]'
    path = visualmode() ==# 'V' ? getline('.') :
          \ getregion(getpos("'<"), getpos("'>"))->join('')
  else
    path = expand('<cfile>')
  endif

  if path =~# '\v([[:alpha:]{2,}])(:\/\/[_0-9A-Za-z\/:%#\$&\?\(\)~\.=\+\-]+)'
    execute 'silent! normal gx'
  else
    var local_path = path->expand()->fnamemodify(':p')

    if isdirectory(local_path) ||
          \ path =~# get(g:, 'gf_ex_executable_binary_pattern', '\v\.(exe|pdf|ppt|mdb|(doc|xls|vsd)[xm]?)$')
      call dist#vim9#Open(local_path)
    else
      var cmd = get(g:, 'gf_ex_file_open_command', 'e')

      if path->expand()->fnamemodify(':p')->filereadable()
        execute 'silent!' cmd local_path
      else
        if input(path .. "\n? file is not found, create it? (y) > ") ==? 'y'
          execute 'silent!' cmd local_path
        else
          echomsg "can't go to:" local_path
        endif
      endif
    endif
  endif
}

nnoremap <silent> gf :GoToFileEx<CR>
xnoremap <silent> gf :GoToFileEx<CR>

