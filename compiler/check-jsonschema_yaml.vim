
if exists("current_compiler") | finish | endif
let current_compiler = "check-jsonschema"

let config_file = expand('~') . '/.vim/compiler/yamllint_rules.yml'

if exists("b:schema") 
    let &l:makeprg = 'check-jsonschema --verbose --schemafile "' . b:schema . '" % & yamllint -c ' . config_file . ' --f parsable %'
else
    let &l:makeprg = 'yamllint -c ' . config_file . ' --f parsable %'
endif

let &l:errorformat =
    \ '%f::%m,' .
    \ '%-G\\s%#,' .
    \ '%-G\\s\\s%.%#,' .
    \ '%-GSeveral%.%#,' .
    \ '%-GSchema%.%#,' .
    \ '%f:%l:%c:\ [%trror]\ %m,' .
    \ '%f:%l:%c:\ [%tarning]\ %m'

"https://check-jsonschema.readthedocs.io/en/latest/
"pip3 install check-jsonschema
silent CompilerSet makeprg
silent CompilerSet errorformat
