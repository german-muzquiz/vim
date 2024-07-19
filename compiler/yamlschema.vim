
if exists("current_compiler") | finish | endif
let current_compiler = "yamlschema"

let config_file = expand('~') . '/.vim/compiler/yamllint_rules.yml'
let checker_file = expand('~') . '/.vim/compiler/yaml_checkschema.py'

if exists("b:schema") 
    let &l:makeprg = 'python3 ' . checker_file . ' "' . b:schema . '" "%" & yamllint -c ' . config_file . ' --f parsable %'
else
    let &l:makeprg = 'yamllint -c ' . config_file . ' --f parsable %'
endif

let &l:errorformat =
    \ '%f:%l:\ %trror:\ %m,' .
    \ '%f:%l:%c:\ [%trror]\ %m,' .
    \ '%f:%l:%c:\ [%tarning]\ %m'

silent CompilerSet makeprg
silent CompilerSet errorformat
