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

colorscheme monokai
set t_Co=256

" Show autocomplete options
set wildmenu

" Highlight search matches
set hlsearch

nnoremap <C-e> :b<Space>
nnoremap <C-a> :NERDTreeToggle<CR>

