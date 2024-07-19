
let cp = '.'
if exists('b:project_key') && has_key(g:projects[b:project_key], 'compile_classpath')
    let cp_list = g:projects[b:project_key]['compile_classpath']
    let cp = join(cp_list, ':')
endif

let &l:makeprg = 'javac -cp ' . cp . ' %'
let &l:errorformat = '%E%f:%l: error: %m,%W%f:%l: warning: %m,%-Z%p^,%-C%.%#,%-G%.%#'

silent CompilerSet makeprg
silent CompilerSet errorformat
