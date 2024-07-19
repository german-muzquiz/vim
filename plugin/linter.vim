"----------------------------------------------------------------------------
" Plugin for running linters against files and showing results
" in quickfix window, gutter and status line.
"----------------------------------------------------------------------------

" If there is a makeprg (linter) command set, use on every save
autocmd BufWritePost * call MyMake()

" Define gutter symbols for warnings and errors
call sign_define([{'name': 'error', 'text': 'E>', 'texthl': 'ErrorMsg'}, {'name': 'warning', 'text': 'W>', 'texthl': 'WarningMsg'}])

" Define command Make to run vim's make asynchorously
"command! -bang -nargs=* -complete=file Make AsyncRun -strip -program=make -scroll=0 @ <args>

" Define status line content
call airline#parts#define_function('lintererr', 'LinterErrors')
call airline#parts#define_function('linterwarn', 'LinterWarnings')
let g:airline_section_error = airline#section#create(['', 'lintererr'])
let g:airline_section_warning = airline#section#create(['', 'linterwarn'])

" Run makeprg only if it is defined
function! MyMake()
    if &makeprg != 'make'
        call asyncrun#run('', {'strip': 1, 'program': 'make', 'scroll': 0}, '%')
    endif
endfunction

" Update gutter with warnings and errors with the contents of the quickfix list
function! s:signUpdate()
    call sign_unplace('gerlinter', {'buffer': bufnr('')})
    for i in getqflist()
        if i.bufnr == bufnr('') && i.type != 'n'
            let type = i.type == 'e' ? 'error' : 'warning'
            call sign_place(0, 'gerlinter', l:type, i.bufnr, {'lnum': i.lnum})
        endif
    endfor
endfunction

" Return the string to show in status line for errors
function! LinterErrors()
    call s:signUpdate()
    return s:lintercommon('e', '', 'E:')
endfunction

" Return the string to show in status line for warnings
function! LinterWarnings()
    return s:lintercommon('', 'e', 'W:')
endfunction

function! s:lintercommon(type, nottype, prefix)
    let items = 0
    for i in getqflist()
        if i.bufnr == bufnr('') && i.type != 'n'
            if a:nottype != ''
                if i.type != a:nottype
                    let items += 1
                endif
            else
                if i.type == a:type 
                    let items += 1
                endif
            endif
        endif
    endfor
    if items > 0
        return a:prefix . '' . items
    else
        return ''
    endif
endfunction
