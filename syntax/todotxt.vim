" vim:set sw=2:
" Vim syn file
if exists("b:current_syntax")
  finish
endif


""""""""""""""""""""""""""""""""""""""""""""
syn match todoTxtStart /^/ nextgroup=todoTxtPriority,todoTxtDate,todoTxtDone,todoTxtProject,todoTextContext,todoSpecialKeyValue display

"" Done
syn match todoTxtDone /x\s.*/ contains=todoTxtProject,todoTextContext,todoSpecialKeyValue,todoTxtSpKeyValueTrackingTime,todoTxtSpKeyValueTrackedTime,todoTxtSpKeyValueId

if has('gui_running')
  hi todoTxtDone  gui=strikethrough guifg=#999999
else
  hi link todoTxtDone SpecialKey
endif


"" Priority
syn match todoTxtPriority /([A-Z])/ skipwhite nextgroup=todoTxtDate contained

hi link todoTxtPriority Todo


"" Start/End DateTime
syn match todoTxtDate /\d\{4}-\d\{2}-\d\{2}/ contains=NONE contained

hi link todoTxtDate statement

"" Tags
syn match todoTxtTag /\s\zs\S\+/ contains=todoTxtProject,todoTextContext,todoSpecialKeyValue,todoTxtSpKeyValueTrackingTime,todoTxtSpKeyValueTrackedTime,todoTxtSpKeyValueId


"" Project Tag
syn match todoTxtProject /+[^[:blank:]]\+/ contains=NONE contained

hi link todoTxtProject DiffAdd


"" Context Tag
syn match todoTextContext /@[^[:blank:]]\+/ contains=NONE contained

hi link todoTextContext DiffChange


"" Special Key-Value
syn match todoSpecialKeyValue /\w\+:\S\+/ contains=todoTxtDate contained

hi link todoSpecialKeyValue DiffDelete


"" special key-value : tracking time
syn match todoTxtSpKeyValueTrackingTime /t:\d\{4}-\d\{2}-\d\{2}T\d\{2}:\d\{2}_/ conceal cchar=⌛


"" special key-value : tracked time
syn match todoTxtSpKeyValueTrackedTime /t:\d\{4}-\d\{2}-\d\{2}T\d\{2}:\d\{2}_\d\{2}:\d\{2}/ conceal cchar=⌚


"" special key-value : id
syn match todoTxtSpKeyValueId /id:\x\{1,16}/ conceal cchar=🆔


""""""""""""""""""""""""""""""""""""""""""""
let b:current_syntax = "todotxt"

