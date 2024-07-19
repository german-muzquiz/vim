
function! MyKubeDetect()
    " echo getline(1)
    if getline(1) =~# 'apiVersion:.*' || getline(2) =~# 'apiVersion:.*'
        :set filetype=yaml-kubernetes
    endif
endfunction

"Detect kubernetes files
autocmd BufRead *.yml,*.yaml :call MyKubeDetect()

