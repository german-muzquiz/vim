
let pylint_config_file = expand('~') . '/.vim/compiler/.pylintrc'
let mypy_config_file = expand('~') . '/.vim/compiler/mypy.ini'
let pybin = python#get_python_executable()

let &l:makeprg = pybin . ' -m pylint --rcfile=' . pylint_config_file . ' --output-format=text --msg-template="{path}:{line}:{column}:{C}: [{symbol}] {msg}" --reports=n --score=n % & ' . pybin . ' -m mypy --show-column-numbers --no-namespace-packages --config-file ' . mypy_config_file
"let &l:makeprg = 'python3 -m pylint --rcfile=' . pylint_config_file . ' --output-format=text --msg-template="{path}:{line}:{column}:{C}: [{symbol}] {msg}" --reports=n --score=n --load-plugins pylint_pydantic,pylint_django --django-settings-module=organization_service.settings % & python3 -m mypy --show-column-numbers --no-namespace-packages --config-file ' . mypy_config_file
"let &l:makeprg = 'python3 -m pylint --rcfile=' . pylint_config_file . ' --output-format=text --msg-template="{path}:{line}:{column}:{C}: [{symbol}] {msg}" --reports=n --score=n --load-plugins pylint_pydantic,pylint_django --django-settings-module=smb_service.settings % & python3 -m mypy --show-column-numbers --no-namespace-packages --config-file ' . mypy_config_file
let &l:errorformat =
    \ '%f:%l:%c:\ %t%*[^:]:\ %m,' .
    \ '%f:%l:%c:\ %t: %m,' .
    \ '%f:%l:%c:%t: %m,' .
    \ '%f:%l: %m,' .
    \ '%f:(%l): %m, ' .
    \ '%-G************* Module %.%#,' .
    \ '%-GFound %.%#,' .
    \ '%-GSuccess:%.%#'

silent CompilerSet makeprg
silent CompilerSet errorformat
