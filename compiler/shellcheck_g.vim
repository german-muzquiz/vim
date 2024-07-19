
if exists("current_compiler") | finish | endif
let current_compiler = "shellcheck"

" works on mac
let &l:makeprg = 'shellcheck -f gcc '

silent CompilerSet makeprg
CompilerSet errorformat=
      \%f:%l:%c:\ %trror:\ %m,
      \%f:%l:%c:\ %tarning:\ %m,
      \%I%f:%l:%c:\ note:\ %m
