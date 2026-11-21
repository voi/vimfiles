vim9script

import 'fuzzy_choice.vim'


# ###############################
#
def FuzzyChoice_action_open_buffer(command_format: string, winid: number, ctx: any, item: any)
  call popup_close(winid)
  execute printf(command_format, item->get('bufnr', 0))
enddef


#
var fuzzy_choice_handlers_buffer = {
  "\<CR>": function(FuzzyChoice_action_open_buffer, ['buffer %d']),
  "\<C-t>": function(FuzzyChoice_action_open_buffer, ['split | buffer %d | wincmd T']),
  "\<C-s>": function(FuzzyChoice_action_open_buffer, ['split | buffer %d']),
  "\<C-v>": function(FuzzyChoice_action_open_buffer, ['vsplit | buffer %d']),
  "\<C-d>": function(FuzzyChoice_action_open_buffer, ['bw %d'])
}


#
def FuzzyChoice_command_buffers()
  var icon = get(g:, 'fuzzy_choice_icon_buff', '📜')
  var items = range(1, bufnr('$'))
    ->filter((i, v) => buflisted(v) && bufexists(v))
    ->map((i, v) => {
      var bname = v->bufname()

      if v->getbufvar('&buftype', '')->empty()
        bname = printf('%s (%s)', bname->fnamemodify(':t'), bname->fnamemodify(':p:h:~'))
      endif

      return { text: printf('%4d %s %s', v, icon, bname), bufnr: v }
    })

  call fuzzy_choice.Do('Buffers', items, fuzzy_choice_handlers_buffer)
enddef


#
command! -nargs=0 FuzzyChoiceBuffers call FuzzyChoice_command_buffers()

