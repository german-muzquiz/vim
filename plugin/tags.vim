

function! tags#init_buffer(filename) abort
    let l:root = gutentags#get_project_root(a:filename)
    " Strip root path from filename
    let l:filename = substitute(a:filename, l:root, '', '')
    " Replace slashes with dashes
    let l:filename = substitute(l:filename, '/', '-', 'g')
    let b:gutentags_ctags_tagfile = l:filename . '-tags'
    return 1
endfunction

