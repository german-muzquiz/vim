
runtime syntax/markdown.vim

syn match line_comment "#.*$"
syn match method_get "^GET \".*\""
syn match method_post "^POST \".*\""
syn match method_put "^PUT \".*\""
syn match method_patch "^PATCH \".*\""
syn match method_delete "^DELETE \".*\""
syn match method_head "^HEAD \".*\""
syn match method_options "^OPTIONS \".*\""
syn match filter "=>.*$"
syn match header "^[^ ].*: .*$"

hi link line_comment       Comment
hi link method_get        Identifier
hi link method_post        Identifier
hi link method_patch        Identifier
hi link method_put        Identifier
hi link method_delete        Identifier
hi link method_head        Identifier
hi link method_options        Identifier
hi link filter             Include
hi link header             Function

let b:current_syntax = "http"
