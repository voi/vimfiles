vim9script

# vim: ft=vim
#
# add path for follow external process, if system path has not.
#   svn / git / fossil, ripgrep, TortoriseProc.exe, ctags, gnu global
#
$PATH ..= ';' .. [
  '~/scoop/apps/vscode/current/resources/app/node_modules/@vscode/ripgrep/bin'->expand(),
  $ProgramFiles .. '/Microsoft Visual Studio/2022/Community/VC/Tools/Llvm/bin'
]->join(';')

# set path for VSCode snippets folder.
#
g:code_snippet_glob_pathes = '~/scoop/persist/vscode/data/user-data/User/snippets'
  ->expand()->fnamemodify(':p')

# icon character ( color emoji )
g:vimrc_statusline_icon_pwd = '📍'
g:vimrc_statusline_icon_ro  = '❎'
g:vimrc_statusline_icon_mod = '⚡'

g:vimrc_tabline_icon_dir = '📂:'
g:vimrc_tabline_icon_nor = '📝'
g:vimrc_tabline_icon_mod = '⚡'

g:popup_editee_icon_dir   = '📁'
g:popup_editee_icon_file  = '📝'
g:popup_editee_icon_empty = '🈳'
g:popup_editee_icon_buff  = '📜'
g:popup_editee_icon_wind  = '📑'

