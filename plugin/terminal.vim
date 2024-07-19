
function! GetCurrentState()
    let terminals_visible = []
    let terminals_invisible = []
    let files_visible = []
    for b in getbufinfo()
        if b["hidden"] == 0 && b['loaded'] == 1 && b['listed'] == 1 " is buffer visible?
            if b['name'][0:len('quickterm') - 1] == 'quickterm' " is it a terminal?
                let terminals_visible = l:terminals_visible + [{'name': b['name'], 'bufnr': b['bufnr']}]
            else
                let files_visible = l:files_visible + [{'name': b['name'], 'bufnr': b['bufnr']}]
            endif
        else
            if b['name'][0:len('quickterm') - 1] == 'quickterm' " is it a terminal?
                let terminals_invisible = l:terminals_invisible + [{'name': b['name'], 'bufnr': b['bufnr']}] 
            endif
        endif
    endfor
    let active_buffer = bufname('')
    let terminal_maximized = len(l:terminals_visible) == 1 && len(l:files_visible) == 0
    let total_terminals = len(l:terminals_visible) + len(l:terminals_invisible)
    let only_terminals = len(l:files_visible) == 0

    " echo 'Terminals visible: ' . join(l:terminals_visible)
    " echo 'Active buffer: ' . l:active_buffer
    " echo 'Terminal maximized: ' . l:terminal_maximized
    " echo 'Terminals invisible: ' . join(l:terminals_invisible)
    " echo 'Total terminals: ' . l:total_terminals
    " echo 'Files visible: ' . join(l:files_visible)
    " echo 'Only terminals: ' . l:only_terminals

    return { 
    \   'terminals_visible': l:terminals_visible, 
    \   'active_buffer': l:active_buffer, 
    \   'terminal_maximized': l:terminal_maximized,
    \   'terminals_invisible': l:terminals_invisible,
    \   'total_terminals': l:total_terminals,
    \   'files_visible': l:files_visible,
    \   'only_terminals': l:only_terminals
    \}
endfunction


function! TerminalToggle()
    let current_state = GetCurrentState()

    if current_state['total_terminals'] == 0
        " start new terminal on lower pane
        let g:quickterm_state_before_show = l:current_state
        let g:quickterm = term_start('zsh', {'term_rows' : 20, 'term_name': 'quickterm', 'term_finish': 'close', 'term_kill': 'kill', 'exit_cb': 'TerminalExit'})
    elseif len(current_state['terminals_visible']) > 0
        " hide all terminals
        " echom 'Hiding terminals. Current state: ' . string(l:current_state)
        let g:quickterm_state_before_hide = l:current_state
        if current_state['only_terminals'] == 1
            " go back to previous file and maximize it
            execute ':b ' . g:quickterm_state_before_show['active_buffer']
            execute ':wincmd o'
        else
            " move to each terminal and hide it 
            for i in l:current_state['terminals_visible']
                execute ':b ' .. i['bufnr']
                execute ':hide'
            endfor
        endif
    elseif len(current_state['terminals_invisible']) > 0
        " show all invisible terminals
        execute ':wincmd o'
        let g:quickterm_state_before_show = l:current_state
        "echom 'Showing terminals. Current state: ' . string(l:current_state)
        if !exists("g:quickterm_state_before_hide")
            " if one terminal show maximized, more than one show in panes
            execute ':b ' . l:current_state['terminals_invisible'][0]['bufnr']
            if len(l:current_state['terminals_invisible']) > 1
                for i in l:current_state['terminals_invisible'][1:]
                    execute ':sb ' . i['bufnr']
                endfor
            endif
        else
            if g:quickterm_state_before_hide['only_terminals'] == 0
                " show terminal in pane
                execute ':sb ' . g:quickterm_state_before_hide['terminals_visible'][0]['bufnr']
                execute ':resize 20'
                if mode() == 'n'
                    normal i
                endif
            else
                " show all terminals and hide files
                execute ':b ' . g:quickterm_state_before_hide['terminals_visible'][0]['bufnr']
                if g:quickterm_state_before_hide['terminal_maximized'] == 0
                    if len(g:quickterm_state_before_hide['terminals_visible']) > 1
                        for i in g:quickterm_state_before_hide['terminals_visible'][1:]
                            execute ':sb ' . i['bufnr']
                        endfor
                    endif
                endif
            endif
        endif
    endif
endfunction

function! TerminalZoom()
    if bufname('')[0:len('quickterm') - 1] == 'quickterm'
        if mode() == 'n'
            echom 'normal mode not implemented'
        elseif mode() == 't'
            if winnr('$') != 1
                " Running in a pane, maximize
                let g:quickterm_maximized = 1
                let g:quickterm_prev_buf = bufnr('#')
                call feedkeys("\<C-w>o")
            else
                " Running full window, minimize
                let g:quickterm_maximized = 0
                execute ':b #'
                call TerminalToggle()
            endif
        endif
    else
        echom 'not in quickterm'
    endif
endfunction

function! TerminalSwitch()
    if bufname('') == 'quickterm'
        if mode() == 'n'
            echom 'normal mode not implemented'
        elseif mode() == 't'
            if winnr('$') != 1
            " Running in a pane, do nothing
            else
                " Running full window, switch to previous buffer
                execute ':b #'
            endif
        endif
    else
        echom 'not in quickterm'
    endif
endfunction

function! TerminalSplit(mode)
    if bufname('') == 'quickterm'
        if a:mode == 'horizontal'
            if winnr('$') == 1
                if !exists("g:quickterm_sp1")
                    let g:quickterm_sp1 = term_start('zsh', {'term_name': 'quickterm_sp1', 'term_finish': 'close', 'term_kill': 'kill', 'exit_cb': 'TerminalExitSp1'})
                    let g:quickterm_maximized = 0
                endif
            endif
        endif
    endif
endfunction

function TerminalExit(job, exit_status) abort
    if exists("g:quickterm")
        unlet g:quickterm
    endif
endfunction

function TerminalExitSp1(job, exit_status) abort
    if exists("g:quickterm_sp1")
        unlet g:quickterm_sp1
    endif
    if exists("g:quickterm")
        let g:quickterm_maximized = 1
    endif
endfunction
