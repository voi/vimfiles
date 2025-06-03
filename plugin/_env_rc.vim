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

