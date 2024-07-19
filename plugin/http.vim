
command! Http call s:curl()

function! s:curl()
    echom getline(".")
endfunction
