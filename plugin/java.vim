"-------------------------------------------------------------
" Common functions for java development
"-------------------------------------------------------------

" These files or folders indicate the root of a java project
let g:java_root_markers = ['build.xml', 'build.gradle', 'pom.xml']

"
" Initialize project variables and commands
function! java#project_load() abort
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
    if filereadable(l:project_root . "/build.gradle")
        call add(g:projects[b:project_key]['project_types'], 'gradle')
        command! -nargs=? GradleBuild call java#gradle_build()
        call add(g:projects[b:project_key]['actions'], 'GradleBuild')
    endif
    if filereadable(l:project_root . "/pom.xml")
        call add(g:projects[b:project_key]['project_types'], 'maven')
    endif
    if filereadable(l:project_root . "/build.xml")
        call add(g:projects[b:project_key]['project_types'], 'ant')
    endif
    call java#load_classpath()
endfunction


" Sets the project variable g:projects[name][classpath] to the resolved classpath taken from gradle.
function! java#load_classpath(force_resolve = 0, interactive = 0, project_key = '') abort
    if !exists('b:project_key') && a:project_key == ''
        if a:interactive == 1
            echohl WarningMsg | echom 'No project root found' | echohl None
        endif
        return
    endif
    let l:project_key = a:project_key != '' ? a:project_key : b:project_key
    if has_key(g:projects[l:project_key], 'compile_classpath') && !a:force_resolve
        return
    endif
    if index(g:projects[l:project_key]['project_types'], 'gradle') != -1
        call s:load_classpath_gradle(a:interactive)
    endif
endfunction


function! s:load_classpath_gradle(interactive = 0) abort
    let l:project_root = g:projects[b:project_key]['project_root']
    if !has_key(g:projects[b:project_key], 'last_build')
        if a:interactive == 1
            echohl WarningMsg | echom 'No gradle build has run yet' | echohl None
            return
        endif
        return
    endif

    let cmd = l:project_root . "/gradlew --build-file " . l:project_root . "/build.gradle -q dependencies --configuration compileClasspath | grep -e '[\\+]---' | sed 's|.*+--- ||g; s|.*\\--- ||g; s| (.)||g; s|:[0-9].* -> \(.*\)|:\1|; s| -> |:|'"
    let cp = systemlist(l:cmd)
    let repo_home = expand('~') . '/.gradle/caches/modules-2/files-2.1'

    " build full file path in gradle cache for each entry in the classpath
    let resolved = []
    for i in range(len(cp))
        let l:parts = split(cp[i], ':')
        let l:group = l:parts[0]
        let l:artifact = l:parts[1]
        let l:version = l:parts[2]
        let cmd = 'find ' . l:repo_home . '/' . l:group . '/' . l:artifact . '/' . l:version . ' -name "*.jar"'
        let l:path = system(l:cmd)
        if !v:shell_error && l:path != ''
            " add only if not duplicate
            if index(resolved, l:path) == -1
                call add(resolved, trim(l:path))
            endif
        endif
    endfor

    let g:projects[b:project_key]['compile_classpath'] = l:resolved
endfunction


function! java#gradle_build() abort
    if !exists('b:project_key')
        echohl WarningMsg | echom 'No project root found' | echohl None
        return
    endif
    let l:project_root = g:projects[b:project_key]['project_root']
    if filereadable(l:project_root . "/gradlew")
        let l:cmd = './gradlew'
        let l:post = 'call java#gradle_post_build("' . b:project_key . '")'
        call asyncrun#run('', {'mode':'term', 'pos':'bottom', 'close': 0, 'focus': 0, 'cwd': l:project_root, 'post': l:post}, l:cmd)
    else
        echohl WarningMsg | echom 'No gradlew file found in ' . l:project_root | echohl None
    endif
endfunction


function! java#gradle_post_build(project_key) abort
    let g:projects[a:project_key]["last_build"] = 1
    call java#load_classpath(1, 0, a:project_key)
    compiler myjavac
endfunction
