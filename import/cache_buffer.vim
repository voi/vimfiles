vim9script


# ##############################################################
# cache buffer # {{{1
export class CacheBuffer
  #
  var bufnr: number
  var bufname: string
  var root: string

  def new(workdir: string)
    this.bufnr = bufadd(tempname())
    this.root = (workdir->empty() ? getcwd() : workdir)

    call this.bufnr->bufload()
    call setbufvar(this.bufnr, '&buftype', 'nofile')
    call setbufvar(this.bufnr, '&bufhidden', 'hide')
    call setbufvar(this.bufnr, '&swapfile', 0)
    call setbufvar(this.bufnr, 'path', this.root)
  enddef
endclass
# }}}

