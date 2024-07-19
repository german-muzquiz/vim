
command! -nargs=? Tags call JumpToTag(<q-args>, 1)


function! JumpToTag(tagname, show_all)
  if empty(tagfiles())
    echohl WarningMsg
    echom 'No tag files'
    echohl None
    return
  endif

  let preview_script = expand('~') . '/.vim/plugin/tagpreview.sh'
  let l:preview_cmd = l:preview_script . ' {}'

  call s:prepare_to_update_tagstack(a:tagname)
  let l:list = s:taglist(a:tagname, a:show_all)
  call fzf#run({
  \ 'source':  l:list,
  \ 'options': ['--nth', '1..2', '-m', '-d', '\t', '--tiebreak=begin', '--preview', l:preview_cmd, '--select-1'],
  \ 'window': { 'width': 1.0, 'height': 0.5, 'border_color': '#ffff00'},
  \ 'sink':    function('s:sink')})
endfunction

function! s:taglist(tagname, show_all) abort  " {{{
  if a:show_all == 1
    let expr = '\C' . a:tagname
  else
    let expr = '^\C' . a:tagname . '$'
  endif

  if a:tagname ==# ""
      let expr = '.*'
  endif
  let taglist = taglist(expr, expand("%"))
  let taglist = s:filter_tags(taglist, a:show_all)
  return map(
  \   taglist,
  \   { _, tag -> s:format_tag(tag) }
  \ )
endfunction  " }}}

function! s:filter_tags(taglist, show_all = 0) abort  " {{{
    " get current line content
    let l:current_line = getline('.')
    " get current cursor position in the line
    let l:cursor_pos = col('.')
    let l:current_line = strpart(l:current_line, 0, l:cursor_pos - 1)
    " strip all content until the last whitespace from current_line
    let l:base = substitute(l:current_line, '.*\s', '', 'g')
    let l:base = substitute(l:base, '.*(', '', 'g')

    let l:filtered_list = []
    for m in a:taglist
        if ShouldFilterTag(m, 'Python', [], l:base, a:show_all)
            continue
        endif
        call add(l:filtered_list, m)
    endfor
    
    return l:filtered_list
    " let valid_files = TagsValidFiles()
    " " if the list of valid files is empty, return everything
    " if empty(valid_files)
    "     return a:taglist
    " endif
    " let l:filtered = []
    " for t in a:taglist
    "     " check if the filename contains any of the valid_files strings
    "     for v in l:valid_files
    "         if stridx(t['filename'], l:v) != -1
    "             call add(l:filtered, t)
    "         endif
    "     endfor
    " endfor
    " return l:filtered
endfunction  " }}}

function! s:format_tag(tag) abort  " {{{
    let extra = ""
    if has_key(a:tag, 'kind') != 0
        let extra = "kind:".a:tag['kind']
    endif
    if has_key(a:tag, 'scope') != 0
        let extra = l:extra . " ".a:tag['scope']
    endif
    if has_key(a:tag, 'inherits') != 0
        let extra = l:extra . " inherits:".a:tag['inherits']
    endif
    let l:filename = fnamemodify(a:tag.filename, ":~:.")
    let l:formatted_filename = s:update_file_name(filename)
    " trick so that the file name is not shown on picker popup
    let l:filename = "                                                                    " . l:filename
    return join([a:tag.name, l:formatted_filename, l:extra, l:filename . ":" . get(a:tag, "line")], "\t")
    " return join([a:tag.name, fnamemodify(a:tag.filename, ":~:.") . ":" . get(a:tag, "line"), trim(a:tag.cmd, '/^$')], "\t")
endfunction  " }}}


function! s:update_file_name(fn) abort  " {{{
  if stridx(a:fn, 'site-packages') > 0
    let suffix = a:fn[stridx(a:fn, 'site-packages/') + 14:]
    return '[' . strpart(suffix, 0, stridx(suffix, '/')) . ']' . strpart(suffix, stridx(suffix, '/'))
  else
    return a:fn
  endif
endfunction  " }}}


function! s:prepare_to_update_tagstack(tagname) abort  " {{{
  let bufnr = bufnr("%")
  let item  = #{ bufnr: bufnr, from: [bufnr, line("."), col("."), 0], tagname: a:tagname }
  let winid = win_getid()

  let stack = gettagstack(winid)

  if stack.length ==# stack.curidx
    let action = "r"
    let stack.items[stack.curidx - 1] = item
  elseif stack.length > stack.curidx
    let action = "r"

    if stack.curidx > 1
      let stack.items = add(stack.items[:stack.curidx - 2], item)
    else
      let stack.items = [item]
    endif
  else
    let action = "a"
    let stack.items = [item]
  endif

  let stack.curidx += 1

  let s:tagstack_info_cache = #{ winid: winid, stack: stack, action: action }
endfunction  " }}}


function! s:sink(item) abort  " {{{
  let parts    = split(a:item, "\t")
  let filepath = split(parts[-1], ":")[0]

  call s:update_tagstack()
  execute "edit " . filepath

  let line = split(parts[-1], ":")[1]
  silent execute line

  " zv: Show cursor even if in fold.
  " zz: Adjust cursor at center of window.
  normal! zvzz
endfunction  " }}}


function s:update_tagstack() abort  " {{{
  let info = s:tagstack_info_cache
  call settagstack(info.winid, info.stack, info.action)
  unlet s:tagstack_info_cache
endfunction  " }}}
