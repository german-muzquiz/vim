function! HttpRun()
    let vars = s:load_vars()
    let request = s:get_request()
    if l:request == ""
        return
    endif

    " replace variables in request lines
    let lines = split(l:request, "\n")
    let resolved_request = ""
    for l:line in l:lines
        for [key, value] in items(l:vars)
            let l:line = substitute(l:line, '${' . l:key . '}', l:value, 'g')
        endfor
        let resolved_request = l:resolved_request . l:line . "\n"
    endfor

    " echom "Resolved request: " . l:resolved_request
    let l:first_line = split(l:resolved_request, "\n")[0]
    let l:header_line = substitute(l:first_line, '=>.*', '', 'g')
    if match(l:first_line, '=>') != -1
        let l:filter = substitute(l:first_line, '.*=>[ ]*', '', 'g')
        if l:filter == ""
            let l:jq = "jq"
        else
            let l:jq = "jq '" . l:filter . "'"
        endif
    else
        let l:jq = "jq"
    endif

    " extract headers from request, which are from second line up until the
    " first blank line
    let l:lines = split(l:resolved_request, "\n")
    if len(l:lines) < 2
        let l:headers = []
        let l:body = ''
    else
        let l:headers = l:lines[1:]
        let l:body = l:lines[1:]
        let l:i = 0
        for l:header in l:headers
            if l:header == ""
                call remove(l:headers, l:i, -1)
                call remove(l:body, 0, l:i)
                break
            endif
            let l:i = l:i + 1
        endfor
        if len(l:body) == len(l:lines[1:])
            let l:body = []
        endif
        let l:body = join(l:body, "")
    endif

    " build curl command
    let l:curl = 'curl -i -s -S -k -X ' . l:header_line
    for l:header in l:headers
        let l:curl = l:curl . ' -H "' . l:header . '"'
    endfor
    if l:body != ''
        let l:curl = l:curl . " -d '" . l:body . "'" 
    endif

    "echom 'Curl command: ' . l:curl

    " run async run
    let cmd = 'RES=$(' . l:curl . ') && echo "$RES" | awk ''/^[^a-zA-Z0-9]/{exit}1'' && echo "" &&  echo $RES | sed ''1,/^[^a-zA -Z0-9]/d'' | tr -d ''\n'' | ' . l:jq
    call asyncrun#run('', {'mode':'term', 'pos':'bottom', 'close': 0, 'focus': 0}, l:cmd)
endfunction

function! s:load_vars() abort
    " Read current file and extract all variable definitions. Variables take
    " the form 'var=value'. Ignore lines starting with #
    let file_contents = readfile(expand('%'))
    let vars = {}
    for line in file_contents
        if line =~ '^\s*#'
            continue
        endif
        let def = split(line, '#')
        if len(l:def) == 0
            continue
        endif
        let def = l:def[0]
        " if def doesn't match the form 'var=value', continue
        if len(split(l:def, '=')) != 2
            continue
        endif
        " trim start or end whitespace
        let key = split(l:def, '=')[0]
        let value = split(l:def, '=')[1]
        let key = substitute(l:key, '^\s*\(.\{-}\)\s*$', '\1', 'g')
        let value = substitute(l:value, '^\s*\(.\{-}\)\s*$', '\1', 'g')
        let vars[l:key] = l:value
    endfor

    " check if there is a variable that starts with TOKEN
    for key in keys(l:vars)
        if key =~ "^TOKEN"
            let token = s:get_token(l:vars[l:key])
            if l:token != ""
                let l:vars[l:key] = l:token
            endif
        endif
    endfor

    return l:vars
endfunction


function! s:get_request() abort
    let line = getline('.')
    " get first word of line
    let method = split(line)[0]
    " if not http method, abort
    if method != "GET" && method != "POST" && method != "PUT" && method != "DELETE" && method != "PATCH" && method != "HEAD" && method != "OPTIONS"
        echohl WarningMsg | echom "No HTTP method found on current line" | echohl None
        return ""
    endif

    " get all following line contents up until the next two consecutive empty lines
    let l:request = l:line
    let i = 1
    while getline(line('.') + l:i) != "" || getline(line('.') + l:i + 1) != ""
        let l:request = l:request . "\n" . getline(line('.') + l:i)
        let l:i = l:i + 1
    endwhile
    return l:request
endfunction


function! s:env(var) abort
    let value =  exists('*DotenvGet') ? DotenvGet(a:var) : eval('$'.a:var)
    return value
endfunction

function! s:get_token(creds_name)
    " if creds_name doesn't start with $, return it
    if a:creds_name[0] != '$'
        return a:creds_name
    endif
    let creds_name = substitute(a:creds_name, '\$', '', 'g')
    " load env vars
    :Dotenv ~/code/.env
    " check if there is a buffer variable for the given creds_name
    if exists('b:' . l:creds_name)
        return b:{l:creds_name}
    endif
    let creds = s:env(substitute(l:creds_name, '\$', '', 'g'))
    " split creds by pipe
    let user = split(creds, '|')[0]
    let pass = split(creds, '|')[1]
    let l:client_id = "1npe23mqnkn813bd541fhu0m4h"
    " if the creds_name ends with _PROD, use prod client id
    if l:creds_name =~ "_PROD"
        let l:client_id = "3ft44pepdh2g8mnuiavbdudqlr"
    endif
    let token = system("aws cognito-idp initiate-auth --auth-flow 'USER_PASSWORD_AUTH' --client-id '" . l:client_id . "' --auth-parameters 'USERNAME=" . l:user . ",PASSWORD=" . l:pass . "' --query 'AuthenticationResult.IdToken' --output text")
    if v:shell_error
        echohl WarningMsg | echom "Failed to get token: " . l:token | echohl None
        return ""
    endif
    " remove newline
    let token = substitute(l:token, '\n', '', 'g')
    let b:{l:creds_name} = l:token
    return l:token
endfunction

nnoremap <buffer> <leader>rf :call HttpRun()<cr>


function! RunJobAndGetOutput(command)
    let job_id = job_start(a:command, {'out_io': 'pipe'})
    let output = ''

    while job_status(job_id) == 'run'
        let chunk = ch_readraw(job_getchannel(job_id))
        let output .= chunk
    endwhile

    call job_stop(job_id)

    return output
endfunction
