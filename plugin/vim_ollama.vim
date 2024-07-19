" Wrapper for the ollama LLM.
" Inspired by https://github.com/madox2/vim-ai

command! -range -nargs=? OllamaChat <line1>,<line2>call vim_ollama#OllamaChatRun(<range>, <f-args>)

let g:vim_ollama_config = {
    \   'model': 'codellama:13b',
    \   'open_chat_command': 'below new | call vim_ollama#MakeScratchWindow()',
    \   'scratch_buffer_keep_open': 0,
    \   'code_syntax_enabled': 1,
    \   'selection_boundary': '#####',
    \   'paste_mode': 1,
    \ }
let s:scratch_buffer_name = ">>> Ollama chat"
let s:home = expand('<sfile>:h')
let s:adapter_sh = s:home . "/vim_ollama.sh"

" Start and answer the chat
" - is_selection - <range> parameter
" - config       - function scoped vim_ollama config
" - a:1          - optional instruction prompt
function! vim_ollama#OllamaChatRun(is_selection, ...) range
  let l:instruction = ""
  let l:selection = s:GetVisualSelection()
  " used for getting in Python script
  let l:is_selection = a:is_selection
  if &filetype != 'ollamachat'
    let l:chat_win_id = bufwinid(s:scratch_buffer_name)
    if l:chat_win_id != -1
      " TODO: look for first active chat buffer, in case .ollamachat file is used
      " reuse chat in active window
      call win_gotoid(l:chat_win_id)
    else
      " open new chat window
      let l:open_cmd = g:vim_ollama_config['open_chat_command']
      call s:OpenChatWindow(l:open_cmd)
    endif
  endif

  let l:prompt = ""
  if a:0 || a:is_selection
    let l:instruction = a:0 ? a:1 : ""
    let l:prompt = s:MakePrompt(l:selection, l:instruction, g:vim_ollama_config)
  endif

  let s:last_command = "chat"
  let s:last_config = g:vim_ollama_config
  let s:last_instruction = l:instruction
  let s:last_is_selection = a:is_selection

  call s:prepare_chat(l:prompt)
  call s:set_nopaste(g:vim_ollama_config)
endfunction

function! s:prepare_chat(prompt)
    let lines = getline(1, '$')
    let contains_user_prompt = match(lines, ">>> user") != -1
    if l:contains_user_prompt == 0
        " user role not found, put whole file content as an user prompt
        call append(0, ">>> user")
    endif
    normal G
    if search('(^>>> user|^>>> system|^<<< assistant).*', 'b') > 0
        " if line doesn't start with >>> user
        if getline('.')[0:len('>>> user') - 1] < 0
            " last role is not user, most likely completion was cancelled before
            call append(getline('$'), ">>> user")
        endif
    endif
    if a:prompt != ""
        call append(getline('$'), a:prompt)
    endif
endfunction

function! RunOllamaChat()
    call asyncrun#run('', {'cwd': s:home, 'mode': 'quickfix', 'strip': 1, 'scroll': 1}, s:adapter_sh .. ' "' .. expand('%:p') .. '"')
endfunction

function! s:set_nopaste(config)
  if a:config['paste_mode']
    setlocal nopaste
  endif
endfunction

function! s:MakePrompt(selection, instruction, config)
  let l:instruction = trim(a:instruction)
  let l:delimiter = l:instruction != "" && a:selection != "" ? ":\n" : ""
  let l:selection = s:MakeSelectionPrompt(a:selection, l:instruction, a:config)
  return join([l:instruction, l:delimiter, l:selection], "")
endfunction

function! s:MakeSelectionPrompt(selection, instruction, config)
  let l:selection = ""
  if a:instruction == ""
    let l:selection = a:selection
  elseif !empty(a:selection)
    let l:boundary = a:config['selection_boundary']
    if l:boundary != "" && match(a:selection, l:boundary) == -1
      " NOTE: surround selection with boundary (e.g. #####) in order to eliminate empty responses
      let l:selection = l:boundary . "\n" . a:selection . "\n" . l:boundary
    else
      let l:selection = a:selection
    endif
  endif
  return l:selection
endfunction

function! s:GetVisualSelection()
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    return ''
  endif
  " The exclusive mode means that the last character of the selection area is not included in the operation scope.
  let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][column_start - 1:]
  return join(lines, "\n")
endfunction

function! s:OpenChatWindow(open_cmd)
  execute a:open_cmd
endfunction

" Configures ai-chat scratch window.
" - scratch_buffer_keep_open = 0
"   - opens new ai-chat every time
" - scratch_buffer_keep_open = 1
"   - opens last ai-chat buffer
"   - keeps the buffer in the buffer list
function! vim_ollama#MakeScratchWindow()
  let l:keep_open = g:vim_ollama_config['scratch_buffer_keep_open']
  if l:keep_open && bufexists(s:scratch_buffer_name)
    " reuse chat buffer
    execute "buffer " . s:scratch_buffer_name
    return
  endif
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal ft=ollamachat
  if l:keep_open
    setlocal bufhidden=hide
  else
    setlocal bufhidden=wipe
  endif
  if bufexists(s:scratch_buffer_name)
    " spawn another window if chat already exist
    let l:index = 2
    while bufexists(s:scratch_buffer_name . " " . l:index)
      let l:index += 1
    endwhile
    execute "file " . s:scratch_buffer_name . " " . l:index
  else
    execute "file " . s:scratch_buffer_name
  endif
endfunction
