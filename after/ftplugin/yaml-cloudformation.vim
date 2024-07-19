
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal expandtab
setlocal autoindent

let b:schema = 'https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json'
compiler yamlschema

call tcomment#type#Define('yaml-cloudformation', '# %s')
