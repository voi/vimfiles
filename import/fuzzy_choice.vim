vim9script


# ##############################################################
# fuzzy choice # {{{1
export class FuzzyChoice
  #
  static def _ResizePopup(winid: number, item_count: number)
    var height = ([item_count, [&lines, winheight(0)]->max() * 8 / 10]->min())
    var width = ([&columns, winwidth(0)]->max() * 9 / 10)

    call popup_move(winid, { minheight: height, maxheight: height, maxwidth: width })
  enddef


  #
  static def _UpdatePopup(winid: number, ctx: any)
    call popup_setoptions(winid, {
      title: printf(' %s (%d) %s%s %s%s ', ctx._name, ctx._active->len(),
        (ctx._pattern->empty() ? '' : '< '), ctx._pattern,
        (ctx._filter->empty() ? '' : '< '), ctx._filter)
    })
    call popup_settext(winid, ctx._active)
    call FuzzyChoice._ResizePopup(winid, ctx._active->len())
  enddef


  #
  static def _ActionFuzzy(winid: number, ctx: any)
    var chars = input('fuzzy: ')

    if empty(chars) | return | endif

    ctx._filter = chars
    ctx._active = ctx._active->matchfuzzy(chars, { key: 'text' })

    call FuzzyChoice._UpdatePopup(winid, ctx)
  enddef


  #
  static def _ActionMatch(winid: number, ctx: any)
    var text = input('include: ')

    if empty(text) | return | endif

    ctx._pattern = text
    ctx._active = ctx._active->filter(((i, v) => v->get('text', '') =~? text))

    call FuzzyChoice._UpdatePopup(winid, ctx)
  enddef


  #
  static def ActionReset(winid: number, ctx: any)
    ctx._filter = ''
    ctx._pattern = ''
    ctx._active = ctx._source->copy()

    call FuzzyChoice._UpdatePopup(winid, ctx)
  enddef


  #
  static def _ActionFuzzyIncremental(winid: number, key: string, ctx: any)
    ctx._filter ..= key
    ctx._active = ctx._active->matchfuzzy(ctx._filter, { key: 'text' })

    call FuzzyChoice._UpdatePopup(winid, ctx)
  enddef


  #
  static def _ActionFuzzyBack(winid: number, ctx: any)
    ctx._filter = ctx._filter->slice(0, -1)

    if ctx._filter->len() > 0
      ctx._active = ctx._source->matchfuzzy(ctx._filter, { key: 'text' })
    elseif ctx._pattern->len() > 0
      ctx._active = ctx._source->copy()->filter(((i, v) => v->get('text', '') =~? ctx._pattern))
    else
      ctx._active = ctx._source->copy()
    endif

    call FuzzyChoice._UpdatePopup(winid, ctx)
  enddef


  #
  static def _Action(winid: number, key: string, ctx: any): bool
    var item = ctx._active->get(line('.', winid) - 1, '')

    #
    if     key ==# "\<C-f>" | call FuzzyChoice._ActionFuzzy(winid, ctx)
    elseif key ==# "\<C-i>" | call FuzzyChoice._ActionMatch(winid, ctx)
    elseif key ==# "\<C-u>" | call FuzzyChoice.ActionReset(winid, ctx)
    #
    elseif key ==# "\<C-h>" || key ==# "\<BS>"
      call FuzzyChoice._ActionFuzzyBack(winid, ctx)
    #
    elseif key =~# '^[0-9A-Za-z_.@\-]$'
      call FuzzyChoice._ActionFuzzyIncremental(winid, key, ctx)
    #
    elseif ctx._actions->has_key(key)
      var after = ctx._actions->get(key, ((w, c, i) => 0))(winid, ctx, item)

      if after > 0
        call FuzzyChoice._UpdatePopup(winid, ctx)
      elseif after < 0
        call FuzzyChoice.ActionReset(winid, ctx)
      endif
    #
    else
      return popup_filter_menu(winid, key)
    endif

    return true
  enddef


  #
  static def Do(caption: string, items: list<any>, actions: dict<any> = {}, user_ctx: dict<any> = {})
    var ctx = {
       _name: caption, _source: items, _active: items->copy(),
       _actions: actions, _filter: '', _pattern: ''
    }->extend(user_ctx, 'keep')

    var winid = popup_menu(items, {
      title: printf(" %s (%d) ", caption, items->len()),
      filter: (winid, key) => FuzzyChoice._Action(winid, key, ctx),
      borderchars: get(g:, 'fuzzy_choice_borderchars', [])
    })

    call FuzzyChoice._ResizePopup(winid, items->len())
  enddef
endclass
# }}}

