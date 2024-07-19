
" Open entry and go back to quickfix list immediately
" nnoremap <silent> <buffer> o <CR><C-w>p
" nnoremap <silent> <buffer> j j<CR><C-w>p
" nnoremap <silent> <buffer> k k<CR><C-w>p


function! AdjustWindowHeight(minheight, maxheight)
  exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction

call AdjustWindowHeight(10, 10)


