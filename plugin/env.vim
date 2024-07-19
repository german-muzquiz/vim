
function! env#load_env() abort
    let root = fzf#shellescape(asyncrun#get_root('%'))
endfunction
