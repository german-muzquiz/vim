
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal expandtab
setlocal autoindent

let b:schema = 'https://raw.githubusercontent.com/SchemaStore/schemastore/master/src/schemas/json/github-workflow.json'
compiler yamlschema

call tcomment#type#Define('yaml-gha', '# %s')
