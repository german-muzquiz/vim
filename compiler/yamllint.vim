
if exists("current_compiler") | finish | endif
let current_compiler = "yamllint"

let config_file = expand('~') . '/.vim/compiler/yamllint_rules.yml'
let &l:makeprg = 'yamllint -c ' . config_file . ' --f parsable %'
let &l:errorformat =
    \ '%f:%l:%c:\ [%trror]\ %m,' .
    \ '%f:%l:%c:\ [%tarning]\ %m'

"https://yamllint.readthedocs.io/en/stable/index.html
"brew install yamllint
silent CompilerSet makeprg
silent CompilerSet errorformat
