
runtime! syntax/markdown.vim

syn match userinput ">>> user >>>"
syn match assistantoutput "<<< assistant <<<"

hi link userinput       Include
hi link assistantoutput Identifier

let b:current_syntax = "ollamachat"
