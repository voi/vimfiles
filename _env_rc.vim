vim9script

# vim: ft=vim
#
# add path for follow external process, if system path has not.
#   svn / git / fossil, ripgrep, TortoriseProc.exe, ctags, gnu global
#
# $PATH ..= ';' .. [
#   '/vscode/current/resources/app/node_modules/@vscode/ripgrep/bin'->expand(),
#   $ProgramFiles .. '/Microsoft Visual Studio/2022/Community/VC/Tools/Llvm/bin',
#   'C:\Program Files (x86)\Microsoft\Edge\Application'
# ]->join(';')

# set path for VSCode snippets folder.
# g:code_snippet_glob_pathes = '/vscode/data/user-data/User/snippets'
#   ->expand()->fnamemodify(':p')

# history file
# g:vimrc_plugin_popup_mru_pinned = '~/_vim_mru_pinned.txt'

# web browser on gf
# if has('win32')
#   g:smart_gf_web_browser_command = 'msedge.exe --profile-directory=Default --inprivate'
# endif

