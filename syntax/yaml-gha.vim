
" Quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

runtime! syntax/yaml.vim
let b:current_syntax = "yaml-gha"
