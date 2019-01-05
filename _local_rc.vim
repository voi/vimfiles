" *****************************************************************************
"
augroup vimrc_local_cpp_include_guard 
  autocmd FileType c,cpp  command! -buffer IncGuard 
      \ let fn = toupper( expand( '%:r' )) | 
      \ call append( line('.'), [ 
      \     '#ifndef INC_' . fn . '_H_', 
      \     '#define INC_' . fn . '_H_', 
      \     '', 
      \     '', 
      \     '#endif // INC_' . fn . '_H_',
      \     ''
      \ ])
augroup END 
