
"-----------------------------------------------------------
" Plugin to work with projects in vim. Calls language
" specific functions depending on the file type.
"-----------------------------------------------------------

command! -nargs=0 ProjectInfo call project#get_info()
command! -nargs=0 ProjectReload call project#load(1)

" Load project support when opening a file
autocmd BufRead * call project#load()

" setup vim airline status bar
call airline#parts#define_accent('ProjectInfo', 'none')
call airline#parts#define_function('ProjectInfo', 'project#get_statusline_info')
let g:airline_section_x = airline#section#create(['ProjectInfo'])


" Initialize project variables. Called when opening a file, so it must be
" fast and silent.
function! project#load(reload = 0) abort
    if exists('b:project_key') && a:reload == 0
        return
    endif

    " configure root markers
    let g:asyncrun_rootmarks = ['.svn', '.git', '.hg', '.root', '.project', '.idea']
    call extend(g:asyncrun_rootmarks, g:python_root_markers)
    call extend(g:asyncrun_rootmarks, g:java_root_markers)

    " get root
    let root = project#get_root()
    if root == ''
        return
    endif

    " build global project variable name
    let cleaned_root = substitute(root, '/', '_', 'g')
    let cleaned_root = substitute(cleaned_root, '-', '_', 'g')
    let cleaned_root = substitute(cleaned_root, '\.', '_', 'g')

    if !exists('g:projects')
        let g:projects = {}
    endif

    let b:project_key = l:cleaned_root

    " check if the project is already loaded
    if has_key(g:projects, l:cleaned_root) && a:reload == 0
        return
    endif

    " set project variables
    let project_name = fnamemodify(root, ':t')
    let g:projects[l:cleaned_root] = {'project_root': l:root}
    let g:projects[l:cleaned_root]['project_name'] =  l:project_name
    let g:projects[l:cleaned_root]['project_types'] = []
    call python#project_load()
    call java#project_load()
endfunction


" Gets the project root of the current file. If no root marker is found,
" returns ''
function! project#get_root(ignored = 0) abort
    let root = asyncrun#get_root('%')
    if root == expand('%:p:h')
        let marker_exists = 0
        " check if any of the project root markers exist
        for marker in g:asyncrun_rootmarks
            if filereadable(root . '/' . marker) || isdirectory(root . '/' . marker)
                let marker_exists = 1
                break
            endif
        endfor
        if !l:marker_exists
            return ''
        endif
    endif
    return l:root
endfunction


function! project#get_statusline_info() abort
    let ft = substitute(&filetype, 'filetype=', '', 'g')
    if exists('b:project_key')
        return '[' . g:projects[b:project_key]['project_name'] . '] ' . l:ft
    else
        return l:ft
    endif
endfunction


function! project#get_info() abort
    if !exists('b:project_key')
        echom 'No project root found'
        return
    endif
    let l:variables = g:projects[b:project_key]
    for [key, value] in items(l:variables)
        echo l:key . ': ' . string(l:value)
    endfor
endfunction
