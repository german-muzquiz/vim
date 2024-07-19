" Custom auto completion

" :help complete-functions
function! MyCompletePython(findstart, base)
    if a:findstart
        " locate the start of the word
        let line = getline('.')
        let start = col('.') - 1
        while start > 0 && (line[start - 1] =~ '\a' || line[start - 1] =~ '\d' || line[start - 1] == '_' || line[start - 1] == '-' || line[start - 1] == '.')
            let start -= 1
        endwhile
        return start
    else
        " find classes matching a:base
        " echom 'Original base: '.a:base

        let kinds_to_skip = s:get_kinds_to_skip(a:base)
        let my_base = s:adjust_base(a:base)
        " echom 'Adjusted base: '.l:my_base
        let taglist = s:get_tags(l:my_base)
        " limit results before filtering
        let l:taglist = l:taglist[:200]
    
        let l:filtered_list = []
        for m in l:taglist
            if ShouldFilterTag(m, 'Python', l:kinds_to_skip, a:base, 0)
                continue
            endif
            call add(l:filtered_list, m)
        endfor

        " sort by tags whose filename don't contain site-packages first
        call sort(l:filtered_list, function('s:sort_by_filename'))

        " limit results after filtering and sorting
        let l:filtered_list = l:filtered_list[:40]

        " Record what matches − we pass this to complete() later
        let l:res = []

        " Iterate matches
        for m in l:filtered_list
            " Fill information about each item (:help complete-items)
            let my_item = {
                \ 'word': s:format_word(a:base, l:my_base, l:m['name']),
                \ 'abbr': l:m['name'],
                \ 'info': s:format_info(l:m),
                \ 'kind': l:m['kind'],
                \ 'menu': s:format_menu(l:m, 'site-packages'),
                \ 'icase': 1,
                \ 'dup': 1
            \ }

            call add(l:res, l:my_item)
        endfor

        "echom 'res: '.string(l:res)
        return l:res
    endif
endfun

function! s:adjust_base(base)
    " if the base contains a dot, only find matches after the last dot
    if ! empty(matchstr(a:base, '\.'))
        let my_base = a:base
        while stridx(l:my_base, '.') > 0
            let my_base = l:my_base[stridx(l:my_base, '.') + 1:]
        endwhile
        return l:my_base
    else
        return trim(a:base)
    endif
endfunction

function! ShouldFilterTag(tag, language, kinds_to_skip, full_base, show_all)
    " tags include the language name, filter by the right language
    if has_key(a:tag, 'language') == 0
        return v:false
    endif
    if a:tag['language'] != a:language
        return v:true
    endif

    if a:show_all == 1
        return v:false
    endif

    " if language is python case insensitive
    let l:starts_with_module_name = v:false
    if a:language == 'Python' || a:language == 'python'
        " get the list of module names in the current file
        let module_names = s:get_module_names_python(expand("%:p"))
        " check if the full_base starts with a module name
        let l:base_prefix = substitute(a:full_base, "^.*[=(\[]", '', '')
        let l:base_prefix = substitute(l:base_prefix, "\\..*$", '', '')
        if index(module_names, l:base_prefix) != -1
            let l:starts_with_module_name = v:true
        endif
    endif

    if a:full_base == '' || empty(matchstr(a:full_base, '\.'))
        " if the full base doesn't have a dot, filter out tags that have a scope
        if has_key(a:tag, 'scope') != 0
            return v:true
        endif
    else
        " filter out tags that don't have a scope
        if has_key(a:tag, 'scope') == 0 && l:starts_with_module_name == v:false
            return v:true
        endif
    endif

    " filter out tags that don't have access:public, if the filename is not
    " the current file
    if a:tag['filename'] != expand('%:p')
        if has_key(a:tag, 'access') != 0
            if a:tag['access'] != 'public'
                return v:true
            endif
        endif
    endif

    for k in a:kinds_to_skip
        if a:tag['kind'] == k
            return v:true
        endif
    endfor

    return v:false
endfun

function! s:get_kinds_to_skip(base)
    return []
endfunction

function! s:get_tags(base)
    " get results from the tags files
    let expr = '^\C'.a:base
    if a:base == ''
        let expr = '^.*$'
    endif
    let taglist = taglist(expr, expand("%"))
    return l:taglist
endfunction

function! s:sort_by_filename(a, b)
    " tags whose filename doesn't contain 'site-packages' should go first
    if stridx(a:b['filename'], 'site-packages') > 0
        return -1
    endif
    if stridx(a:a['filename'], 'site-packages') > 0
        return 1
    endif
    return 0
endfunction

function! TagsValidFiles()
    " Check if file type is Python
    if &filetype != 'python'
        return []
    endif
    " Inspect the import of the current python file, and return
    " a list of possible file names were the imports are declared
    let l:filename = expand("%:p")
    let l:file_contents = readfile(l:filename)
    " Read all the lines matching 'import .*' or 'from .* import .*'
    let l:valid_files = []
    for l:line in l:file_contents
        if l:line =~# '^import '
            " delete import prefix
            let l:line = substitute(l:line, '^import ', '', 'g')
            " replace dots for /
            let l:line = substitute(l:line, '\.', '/', 'g')
            " add .py extension
            let l:line_py = l:line . '.py'
            let l:line_init = l:line . '/__init__.py'
            call add(l:valid_files, l:line_py)
            call add(l:valid_files, l:line_init)
        elseif l:line =~# '^from '
            let l:line = substitute(l:line, '^from ', '', 'g')
            let l:line = substitute(l:line, ' import .*', '', 'g')
            let l:line = substitute(l:line, '\.', '/', 'g')
            " add .py extension
            let l:line_py = l:line . '.py'
            let l:line_init = l:line . '/__init__.py'
            call add(l:valid_files, l:line_py)
            call add(l:valid_files, l:line_init)
        endif
    endfor
    " Add current file
    call add(l:valid_files, expand("%:t"))
    return l:valid_files
endfunction

function! s:get_module_names_python(filename)
    " return a list of module names extracted from import statements in the
    " given file
    let l:file_contents = readfile(a:filename)
    let l:module_names = []
    let l:multiline_import = 0
    for l:line in l:file_contents
        if l:line =~# '^import '
            " delete import prefix with any number of whitespaces
            let l:line = substitute(l:line, "^import ", '', 'g')
            call add(l:module_names, l:line)
        elseif l:line =~# '^from '
            let l:line = substitute(l:line, "^from ", '', 'g')
            let l:line = substitute(l:line, "^.* import ", '', 'g')
            " include module names from next lines if we find an opening paren
            if l:line =~# "^\("
                let l:line = substitute(l:line, "^\(", '', 'g')
                let l:modules = split(substitute(l:line, "\)$", '', 'g'), ',')
                " trim whitespaces
                let l:modules = map(l:modules, { _, v -> trim(v) })
                call extend(l:module_names, l:modules)
                if l:line !~# "\)$"
                    let l:multiline_import = 1
                endif
            else
                let l:modules = split(l:line, ',')
                " trim whitespaces
                let l:modules = map(l:modules, { _, v -> trim(v) })
                call extend(l:module_names, l:modules)
            endif
        elseif l:multiline_import
            let l:modules = split(l:line, ',')
            " trim whitespaces
            let l:modules = map(l:modules, { _, v -> trim(v) })
            " remove elements that match a closing paren
            call filter(l:modules, { _, v -> v !~# "\)$" })
            call extend(l:module_names, l:modules)
            if l:line =~# "\)$"
                let l:multiline_import = 0
            endif
        elseif l:line =~# "\)$"
            let l:multiline_import = 0
        endif
    endfor
    return l:module_names
endfunction

function! GetTagsByFileNamePython(filename)
    let tags_file = &tags
    let tags_file = split(l:tags_file, ',')[0]
    let site_packages = system('python -c "import site; print(site.getsitepackages()[0])"')
    " trim newline
    let site_packages = trim(l:site_packages)
    let l:base_dir = fnamemodify(a:filename, ':h')

    " read file lines
    let l:file_lines = readfile(a:filename)
    
    " filter lines starting with 'import' or 'from'
    let l:filtered = []
    for l:line in l:file_lines
        if l:line =~# '^import ' || l:line =~# '^from '
            " delete import or from prefix
            let l:line = substitute(l:line, '^import ', '', 'g')
            let l:line = substitute(l:line, '^from ', '', 'g')
            " delete everything after the first whitespace
            let l:line = substitute(l:line, '\s.*', '', 'g')
            call add(l:filtered, l:line)
        endif
    endfor

    " echom 'Imports: ' . join(l:filtered, ', ')

    let l:module_files = []
    for l:module in l:filtered
        let l:module_file = s:find_module_file(l:module, l:site_packages, l:base_dir, l:tags_file)
        " echom 'Module: ' . l:module . ' -> ' . l:module_file
        if !empty(l:module_file)
            call add(l:module_files, l:module_file)
        endif
    endfor

    " let matching_tags = []

    " " Read the tags file line by line
    " if filereadable(tags_file)
    "     let lines = readfile(tags_file)
    "     for line in lines
    "         " Split each line by tab
    "         let parts = split(line, "\t")
    "         if len(parts) >= 3
    "             let tagname = parts[0]
    "             let filepath = parts[1]
    "             let taginfo = parts[2]
    "
    "             " Check if the filepath matches the filename we're looking for
    "             if stridx(fnamemodify(filepath, ':t'), a:filename) != -1
    "                 call add(matching_tags, {'tagname': tagname, 'filepath': filepath, 'taginfo': taginfo})
    "             endif
    "         endif
    "     endfor
    " endif
    "
    " return matching_tags
endfunction

function! s:find_module_file(module_name, site_packages_dir, base_dir, tags_file)
    " convert the python module name into a file name
    " replace single dots with slash and double dots with ../
    let filename = substitute(a:module_name, '\.', '/', 'g')
    let filename = substitute(filename, '//', '../', 'g')
    " append the site-packages directory to the filename
    let filename_base = a:site_packages_dir . '/' . filename
    " append .py extension
    let filename_ext = filename_base . '.py'

    " check if file exists
    if filereadable(filename_ext)
        return filename_ext
    endif

    let filename_init = filename_base . '/__init__.py'
    if filereadable(filename_init)
        return filename_init
    endif

    " resolve relative imports
    let filename_local = a:base_dir . '/' . l:filename. '.py'
    " normalize the path
    let filename_local = fnamemodify(filename_local, ':p')
    if filereadable(filename_local)
        return filename_local
    endif

    let filename_local_ini = a:base_dir . '/' . l:filename. '/__init__.py'
    " normalize the path
    let filename_local_ini = fnamemodify(filename_local_ini, ':p')
    if filereadable(filename_local_ini)
        return filename_local_ini
    endif

    " run grep command on the tags file to find the first match of filename
    let filename_local = l:filename . '.py'
    let cmd = 'grep -m 1 "' . filename_local . '" ' . a:tags_file . " | grep -v " . a:site_packages_dir . " | awk '{print $2}'"
    let result = system(cmd)
    " if match found, return it
    if l:result !=# ''
        return l:result
    endif
    let filename_local = l:filename . '/__init__.py'
    let cmd = 'grep -m 1 "' . filename_local . '" ' . a:tags_file . " | grep -v " . a:site_packages_dir . " | awk '{print $2}'"
    return system(cmd)
endfunction

function! s:format_word(original_base, adjusted_base, tag_name)
    if trim(a:original_base) != trim(a:adjusted_base)
        if a:adjusted_base == ''
            let prefix = a:original_base
        else
            let prefix = a:original_base[:stridx(a:original_base, a:adjusted_base)-1]
        endif
        return l:prefix . a:tag_name
    else
        return a:tag_name
    endif
endfunction

function! s:format_info(tag)
    " Get adjusted file name
    if a:tag['filename'][0:len(getcwd())-1] ==# getcwd()
        let my_fn = a:tag['filename'][len(getcwd())+1:]
    else
        let my_fn = a:tag['filename']
    endif

    " execute shell command and get result string
    " let cmd = expand('~') . '/.vim/plugin/tagpreview.sh' . ' "1 ' . a:tag['filename'] . ':' . a:tag['line'] . '"'
    " let result = system(l:cmd)

    if a:tag['line'] > 10
        let start = a:tag['line'] - 10
        let end = a:tag['line'] + 10
        let preview_line = 11
    else
        let start = 1
        let end = a:tag['line'] + 10
        let preview_line = a:tag['line']
    endif
    let cmd = 'sed -n "' . l:start . ',' . l:end . 'p" "' . a:tag['filename'] . '" | sed  "' . l:preview_line . 's/^/=> /"'
    let result = system(l:cmd)
    return 'File: ' . l:my_fn . "\n\n" . result
endfunction

function! s:format_menu(tag, library_indicator)
    let l:scope = get(a:tag, 'scope', '')
    " if the tag belongs to a library show the library name, 
    " otherwise show the python file name
    if stridx(a:tag['filename'], a:library_indicator) > 0
        let suffix = a:tag['filename'][stridx(a:tag['filename'], a:library_indicator . '/') + len(a:library_indicator) + 1:]
        return l:scope . ' [' . strpart(l:suffix, 0, stridx(l:suffix, '/')) . ']'
    else
        return l:scope . ' (' .split(a:tag['filename'], '/')[-1] . ')'
    endif
endfunction
