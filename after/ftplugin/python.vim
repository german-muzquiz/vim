setlocal completeopt=popup,menuone,noinsert,noselect,preview
setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal expandtab
setlocal autoindent
setlocal completefunc=MyCompletePython
setlocal textwidth=120 "used to get autoformat respect width defined in pylint

" Load the project before setting the compiler
call project#load()
compiler pylintmypy

" Mapping for running the current file
nnoremap <buffer> <leader>rf :call python#run_file(expand('%'))<cr>
