" *****************************************************************************
"
function! TemplateRead_Complete(ArgLead, CmdLine, CursorPos) abort "{{{
  let pattern = ( &filetype ==# '' ) ? '*' : '*.' . &filetype
  let template_path = expand(get(g:, 'vimrc_template_path', '~/templates/'))

  return map(globpath(template_path, pattern, 0, 1),
      \ { idx, val -> fnamemodify(val, ':t') })
endfunction "}}}

function! s:TemplateRead_Command(files) abort "{{{
  let template_path = expand(get(g:, 'vimrc_template_path', '~/templates/'))
  let template_path = fnamemodify(template_path, ':p') . a:files

  execute 'keepalt .-1r ' . template_path
endfunction "}}}

function! s:TemplateRead_OnFileReadPost() abort "{{{
  call setline("'[", map(getline("'[", "']"),
      \ { idx, val -> substitute(val, '%[YmdaAHMS]', '\=strftime(submatch(0))', 'g') }))
endfunction "}}}

command! -nargs=1 -complete=customlist,TemplateRead_Complete ReadTemplate 
    \ call <SID>TemplateRead_Command(<f-args>)

augroup plugin-template-read-vim-event
  autocmd FileReadPost * call <SID>TemplateRead_OnFileReadPost()
augroup END

