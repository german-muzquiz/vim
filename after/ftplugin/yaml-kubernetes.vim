
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal expandtab
setlocal autoindent

let b:schema = 'https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.22.4-standalone-strict/all.json'
compiler yamlschema

call tcomment#type#Define('yaml-kubernetes', '# %s')
