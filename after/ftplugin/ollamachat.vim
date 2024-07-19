
"read file periodically from disk
setlocal autoread | au CursorHold * checktime 

function! s:call_ollama()
    let s:script_home = $HOME . '/.vim/after/ftplugin'
    let s:adapter_sh = s:script_home . "/vim_ollama.sh"
    call asyncrun#run('', {'cwd': s:script_home, 'mode': 'quickfix', 'strip': 1, 'scroll': 1, 'post': 'redraw | echom "Done"'}, s:adapter_sh .. ' "' .. expand('%:p') .. '"')
endfunction

augroup OllamaChat
    autocmd! * <buffer>
    autocmd BufWritePost <buffer> call s:call_ollama()
augroup END
