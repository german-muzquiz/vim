set background=dark
syntax enable

" Expand tabs to spaces
filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab

" Show autocomplete options
set wildmenu

" Highlight search matches
set hlsearch

" Keybindings
" Show buffer list
map <C-e> :b<Space>
" Show/hide tree
map <C-x> :NERDTreeToggle<CR>
" Select all
map <C-a> <esc>ggVG<CR>
" Indent all
map <C-l> gg=G
" Xml format
map <C-k> :%s/></>\r</g<CR>

set incsearch
set number

colorscheme monokai
set t_Co=256

" CtrlP plugin
let g:ctrlp_max_files = 100000
let g:ctrlp_max_depth = 100

set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/.DS_Store,*/node_modules/*,*/target/*
