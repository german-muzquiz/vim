
command! -nargs=0 AsyncTaskFzf call s:fzf_task()

" function to execute Rg with the word under cursor as a parameter
function! GrepWord()
    " call ripgrep with the current root dir 
    let root = fzf#shellescape(asyncrun#get_root('%'))
    " remove the prefix of root relative to the current working directory
    let root = substitute(root, getcwd() . '/', '', '')
    call fzf#vim#grep("rg -w --column --line-number --no-heading --color=always --case-sensitive -- ".fzf#shellescape(expand("<cword>")) . " " . l:root, fzf#vim#with_preview(), 0)
endfunction


function! s:fzf_sink(what)
	let p1 = stridx(a:what, '<')
	if p1 >= 0
		let name = strpart(a:what, 0, p1)
		let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
        let name = fnameescape(name)
		if name != ''
            execute ':AsyncTask ' . l:name
		endif
	endif
endfunction

function! s:fzf_task()
	let rows = asynctasks#source(&columns * 48 / 100)
	let source = []
	for row in rows
		let name = row[0]
		let source += [name . '  ' . row[1] . '  : ' . row[2]]
	endfor
	let opts = { 'source': source, 'sink': function('s:fzf_sink'),
				\ 'options': [], 'window': { 'width': 0.8, 'height': 0.4, 'border_color': '#ffff00' } }
	call fzf#run(opts)
endfunction
