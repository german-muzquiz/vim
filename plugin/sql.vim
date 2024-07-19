
command! -nargs=0 SqlRun call sql#run(1)

" Run the current file against a selected database
function! sql#run(force_select_env = 1) abort
    if !exists('b:db_conn_string') || a:force_select_env == 1
        call sql#load_env()
        return
    endif

    " set results window to two thirds of the window height
    let ph = (winheight(0) / 3) * 2
    execute "setlocal previewheight=" . ph

    " execute the DB command with the connection string
    execute "%DB " . b:db_conn_string
endfunction

function! sql#load_env() abort
    if exists('b:conn_strings')
        unlet b:conn_strings
    endif
    if exists('b:db_conn_string')
        unlet b:db_conn_string
    endif
    " recursively find a .env file from the directory of the current file
    let root = expand('%:p:h')
    while root !=# '/'
        if filereadable(root . "/.env")
            " check if there are connection strings in the .env file
            let l:conn_strings = s:load_conn_strings(root . "/.env")
            if len(l:conn_strings) > 0
                let b:conn_strings = l:conn_strings
                break
            endif
        endif
        let root = fnamemodify(root, ':h')
    endwhile
    if len(b:conn_strings) == 0
        echohl WarningMsg | echom 'No "DB_CONN_STRING_*" variables found in any .env file in the current or parent directories' | echohl None
        return
    endif
    let options = []
    " remove the prefix from the keys
    for key in keys(b:conn_strings)
        let key = substitute(l:key, '^DB_CONN_STRING_', '', 'g')
        call add(l:options, key)
    endfor
    call fzf#run({
        \ 'source':  l:options,
        \ 'options': ['--nth', '1..2', '-m', '-d', '\t', '--tiebreak=begin', '--select-1'],
        \ 'window': { 'width': 0.3, 'height': 0.3, 'border_color': '#ffff00', 'border_label': 'Select a connection string' },
        \ 'sink':    function('s:sink')})
endfunction

function! s:load_conn_strings(file) abort
    let l:conn_strings = {}
    for line in readfile(a:file)
        if line =~ "^DB_CONN_STRING_"
            let key = split(line, '=')[0]
            let value = split(line, '=')[1]
            let key = substitute(l:key, '^\s*\(.\{-}\)\s*$', '\1', 'g')
            let value = substitute(l:value, '^\s*\(.\{-}\)\s*$', '\1', 'g')
            let l:conn_strings[l:key] = l:value
        endif
    endfor
    return l:conn_strings
endfunction

function! s:sink(item) abort
    let b:db_conn_string = b:conn_strings['DB_CONN_STRING_' . a:item]
    call sql#run(0)
endfunction
