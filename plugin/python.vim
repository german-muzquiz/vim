"-------------------------------------------------------------
" Common functions for python development
"-------------------------------------------------------------

" These files or folders indicate the root of a python project
let g:python_root_markers = ['.venv', 'pyproject.toml']

command! -nargs=? VenvCreate call python#create_venv()
command! -nargs=? VenvInstallRequirements call python#install_requirements()


" Initialize project variables and commands
function! python#project_load() abort
    if !exists('b:project_key')
        echohl WarningMsg | echom 'No project root found' | echohl None
        return
    endif
    let l:project_root = g:projects[b:project_key]['project_root']
    if !has_key(g:projects[b:project_key], 'project_types')
        let g:projects[b:project_key]['project_types'] = []
    endif
    if !has_key(g:projects[b:project_key], 'actions')
        let g:projects[b:project_key]['actions'] = []
    endif
    for marker in g:python_root_markers
        if filereadable(l:project_root . '/' . marker) || isdirectory(l:project_root . '/' . marker)
            call add(g:projects[b:project_key]['project_types'], 'python')
            call add(g:projects[b:project_key]['actions'], 'VenvCreate')
            call add(g:projects[b:project_key]['actions'], 'VenvInstallRequirements')
            break
        endif
    endfor
    if isdirectory(l:project_root . '/.venv')
        let g:projects[b:project_key]['virtualenv'] = l:project_root . '/.venv'
    endif
    call python#find_sources()
endfunction


" Find python sources folders
function! python#find_sources(project_key = '') abort
    if a:project_key == '' && !exists('b:project_key')
        echohl WarningMsg | echom 'No project root found' | echohl None
        return
    endif
    let l:project_key = a:project_key != '' ? a:project_key : b:project_key
    let l:project_root = g:projects[l:project_key]['project_root']

    let l:sources = []
    let l:init_folder = python#find_file_in_folder(l:project_root, '__init__.py', ['^\.', '/\.', '^__', '/__', '^test', '/test'])
    if l:init_folder != ''
        " remove last folder part
        let l:init_folder = fnamemodify(l:init_folder, ':h')
        call add(l:sources, l:init_folder)
    endif
    let g:projects[l:project_key]['python_src'] = l:sources
endfunction


" Recurively find the specified file in the given folder
function! python#find_file_in_folder(folder, filename, ignore_globs) abort
    if filereadable(a:folder . '/' . a:filename)
        return a:folder
    endif
    for folder in split(glob(a:folder . '/*'), '\n')
        " check if the folder matches one of the ignore globs
        for ignore_glob in a:ignore_globs
            if match(folder, ignore_glob) != -1
                continue
            endif
        endfor
        if isdirectory(folder)
            let result = python#find_file_in_folder(folder, a:filename, a:ignore_globs)
            if result != ''
                return l:result
            endif
        endif
    endfor
    return ''
endfunction


" Runs the given python file
function! python#run_file(filename) abort
    let l:pybin = python#get_python_executable()
    " extract the base name of the file
    let base = fnamemodify(a:filename, ':t:r')
    " if the file name starts with 'test', execute pytest
    if match(base, '^test') == 0
        call asyncrun#run('', {'mode':'term', 'pos':'bottom', 'close': 0}, l:pybin.' -m pytest -ra -v --tb=short --show-capture=log -vv '.a:filename)
    else
        call asyncrun#run('', {'mode':'term', 'pos':'bottom', 'close': 0}, l:pybin.' '.a:filename)
    endif
endfunction


" Return the path to the python executable for this project
function! python#get_python_executable(project_key = '') abort
    if a:project_key == '' && !exists('b:project_key')
        if executable('python3')
            return 'python3'
        endif
        if executable('python')
            return 'python'
        endif
        throw 'No python executable found'
    endif
    if a:project_key == ''
        let l:project_key = b:project_key
    else
        let l:project_key = a:project_key
    endif
    if has_key(g:projects[l:project_key], 'virtualenv')
        let l:project_virtualenv = g:projects[l:project_key]['virtualenv']
        if executable(l:project_virtualenv . '/bin/python3')
            return l:project_virtualenv . '/bin/python3'
        endif
        if executable(l:project_virtualenv . '/bin/python')
            return l:project_virtualenv . '/bin/python'
        endif
    endif
    if executable('python3')
        return 'python3'
    endif
    if executable('python')
        return 'python'
    endif
    throw 'No python executable found'
endfunction


" Function to activate a virtualenv in the embedded interpreter for
" omnicomplete and other things like that.
function! VirtualEnvActivate(path)
    if exists('b:gervirtualenv_path') || exists('b:gervirtualenv_dontask')
        return
    endif

    " Create the virtualenv if it doesn't exist
    if a:path == ''
        let path = asyncrun#get_root('%') . '/.venv'
    else
        let path = a:path
    endif

    " Activate the virtualenv
    let activate_this = l:path . '/bin/activate'
    if getftype(l:path) == "dir" && filereadable(activate_this)
        let b:gervirtualenv_path = l:path
        python3 << EOF
import os
import sys
import subprocess
import re
import vim

activate_this = vim.eval('l:activate_this')

def update_os_environ(line: str) -> None:
    env_var, env_val = line.split("=", 1)
    os.environ[env_var] = env_val


pipe = subprocess.Popen(". %s; env" % activate_this, stdout=subprocess.PIPE, shell=True)
output = pipe.communicate()[0].decode("utf8").splitlines()

# This variable serves the purpose of compiling multi-line env variables
prev_line = None

for line in output:
    if re.match(r"^[A-Za-z_%]+=.+", line):
        if prev_line:
            update_os_environ(prev_line)

        prev_line = line
    else:
        prev_line += "\n" + line

# One last check for prev_line
if prev_line:
    update_os_environ(prev_line)
EOF
    else
        if exists('b:gervirtualenv_path')
            unlet b:gervirtualenv_path
        endif
        echom '"' . l:path . '" is not a virtualenv!'
    endif
endfunction

" Install requirements.txt in the existing virtualenv
function! python#install_requirements(project_key = '', requirements_file = '')
    if a:project_key == '' && !exists('b:project_key')
        if !exists('b:virtualenv')
            echo 'No virtualenv created'
            return
        endif
        let l:venv = b:virtualenv
        let workdir = asyncrun#get_root('%')
    else
        if a:project_key != ''
            let l:project_key = a:project_key
        else
            let l:project_key = b:project_key
        endif
        if !has_key(g:projects[l:project_key], 'virtualenv')
            echo 'No virtualenv created'
            return
        endif
        let l:venv = g:projects[l:project_key]['virtualenv']
        let workdir = g:projects[l:project_key]['project_root']
    endif
    if a:requirements_file != ''
        let l:requirements_file = a:requirements_file
    else
        let l:requirements_file = l:workdir . '/requirements.txt'
    endif
    echo 'Installing requirements from ' . l:requirements_file
    " check if requirements.txt exists and is a file
    if getftype(l:requirements_file) != "file" || !filereadable(l:requirements_file)
        echo 'No requirements.txt found in ' . l:requirements_file
        return
    endif
    let pybin = l:venv . '/bin/python'
    call asyncrun#run('', {'mode':'term', 'pos':'bottom', 'close': 0, 'post': ''}, l:pybin . ' -m pip install -r ' . l:requirements_file . ' -U && echo "Requirements installed!"')
endfunction


" Create a new virtualenv
function! python#create_venv()
    if !exists('b:project_key')
        let workdir = asyncrun#get_root('%')
        let path = l:workdir . '/.venv'
        let b:virtualenv = l:path
        let l:project_key = ''
    else
        let workdir = g:projects[b:project_key]['project_root']
        let path = l:workdir . '/.venv'
        let g:projects[b:project_key]['virtualenv'] = l:path
        let l:project_key = b:project_key
    endif
    " Ask user if we should create the virtualenv
    if getftype(l:path) == "dir"
        echo "Virtualenv already exists in " . l:path
        return
    endif
    echo "Create virtualenv in " . l:path . "?"
    let options = ['1. Yes', '2. No']
    let choice = inputlist(options)
    if choice == 0 || choice == 2
        return
    endif
    let pybin = python#get_python_executable()
    let cmd = l:pybin . ' -m venv ' . l:path . ' && ' . l:path . '/bin/pip install --upgrade pip pylint pydantic pylint_pydantic pylint-django mypy types-requests && echo "Virtualenv created!"'
    call asyncrun#run('', {'mode':'term', 'pos':'bottom', 'close': 0, 'cwd': l:workdir, 'post':'call python#install_requirements("' . l:project_key . '")'}, l:cmd)
endfunction


" Generate the tags file for the given filename, including its imported
" hierarchy
function! python#generate_tags(filename) abort
    let l:files = python#get_imported_hierarchy(a:filename)
    let l:cmd = 'ctags --tag-relative=yes --fields=+ailmneSEKRZz --python-kinds=-IY -f /tmp/supertags '

    for l:f in l:files
        let l:cmd = l:cmd . ' ' . l:f . ' '
    endfor

    let l:cmd = l:cmd . a:filename
    let l:output = system(l:cmd)
    echom 'Output: ' . l:output
endfunction


" Return the file hierarchy being imported from the given filename
function! python#get_imported_hierarchy(filename) abort
    let l:pybin = python#get_python_executable()
    let site_packages = system(l:pybin . ' -c "import site; print(site.getsitepackages()[0])"')
    " check if the command succeeded
    if v:shell_error
        echoerr 'Error getting site-packages directory: ' . l:site_packages
        return
    endif
    let src_roots = [trim(l:site_packages)]
    if exists('b:project_key')
        for l:r in g:projects[b:project_key]['python_src']
            let src_roots = add(src_roots, l:r)
        endfor
    endif

    let l:module_files = s:imports_from_file(a:filename, src_roots)

    return l:module_files
endfunction


function! s:imports_from_file(filename, src_roots, found_files = []) abort
    let l:all_files = a:found_files
    let l:modules = s:get_module_names(a:filename)
    let l:new_module_files = []
    for l:module in l:modules
        let l:module_file = s:module_name_to_file(l:module, a:src_roots)
        if !empty(l:module_file) && index(l:all_files, l:module_file) == -1
            call add(l:new_module_files, l:module_file)
            call add(l:all_files, l:module_file)
        endif
    endfor

    " recursively find imports in other files
    for l:module_file in l:new_module_files
        call s:imports_from_file(l:module_file, a:src_roots, l:all_files)
        " call extend(l:module_files, s:imports_from_file(l:module_file, a:src_roots, l:module_files))
    endfor

    return l:all_files
endfunction


" Return a list of module names extracted from import statements in the given file
function! s:get_module_names(filename)
    let l:file_contents = readfile(a:filename)
    let l:module_names = []
    let l:multiline_import = 0
    for l:line in l:file_contents
        if l:line =~# '^import '
            " delete import prefix with any number of whitespaces
            let l:line = substitute(l:line, "^import ", '', 'g')
            call add(l:module_names, l:line)
        elseif l:line =~# '^from '
            let l:line = substitute(l:line, "^from ", '', 'g')
            " include module names from next lines if we find an opening paren
            if l:line =~# "[^#].*\("
                if l:line !~# "\)$"
                    let l:multiline_import = 1
                endif
                let l:line = substitute(l:line, " import.*", '', 'g')
                call add(l:module_names, l:line)
            else
                let l:line = substitute(l:line, " import.*", '', 'g')
                call add(l:module_names, l:line)
            endif
        elseif l:multiline_import
            if l:line =~# "\)$"
                let l:multiline_import = 0
            endif
        elseif l:line =~# "\)$"
            let l:multiline_import = 0
        endif
    endfor
    return l:module_names
endfunction


" Return the file name that defines the given module
function! s:module_name_to_file(module_name, root_dirs) abort
    " convert the python module name into a file name
    " replace single dots with slash and double dots with ../
    let filename = substitute(a:module_name, '\.', '/', 'g')
    let filename = substitute(l:filename, '//', '../', 'g')

    for l:root_dir in a:root_dirs
        if l:root_dir != ''
            let l:found = python#find_file(l:filename, l:root_dir)
            if l:found != ''
                return l:found
            endif
        endif
    endfor

    return ''
endfunction


" Find the given python file in the given directory
function! python#find_file(python_file, dir) abort
    let filename_py = a:dir . '/' . a:python_file. '.py'
    " normalize the path
    let filename_py = fnamemodify(l:filename_py, ':p')
    if filereadable(l:filename_py)
        return l:filename_py
    endif
    let filename_ini = a:dir . '/' . a:python_file. '/__init__.py'
    " normalize the path
    let filename_ini = fnamemodify(l:filename_ini, ':p')
    if filereadable(l:filename_ini)
        return l:filename_ini
    endif
    return ''
endfunction
