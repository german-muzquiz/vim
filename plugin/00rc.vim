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
set wildmode=longest:full
set completeopt=longest,preview,menuone

" Highlight search matches
set hlsearch

" Keybindings
" Show/hide tree
map <C-x> :NERDTreeToggle<CR>
" Select all
map <C-a> <esc>ggVG<CR>
map <C-l> gg=G
au FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null
au FileType json setlocal equalprg=python\ -m\ json.tool\ 2>/dev/null

set incsearch
set number

colorscheme monokai
set t_Co=256

" CtrlP plugin
let g:ctrlp_max_files = 100000
let g:ctrlp_max_depth = 100

set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/.DS_Store,*/node_modules/*,*/target/*,*/*.jar,*/*.class,*/*.zip,*/*.tar,*/*.gz,*/*.war,*/bower_components/*

set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=2

" Smooth scroll!
noremap <C-down> 1j1<C-e>
noremap <C-up> 1k1<C-y>
noremap <PageUp> <PageUp>Mgm
noremap <PageDown> <PageDown>Mgm

set nowrap
set sidescroll=1
set sidescrolloff=50

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" Search visually selected text
vnoremap // y/<C-R>"<CR>

" Remember last position in file
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

"set ignorecase
"set smartcase

set clipboard=unnamedplus

inoremap <expr> <C-n> pumvisible() ? '<C-n>' :
  \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'


"set complete+=k**/*.java

" Resize windows
map < <C-W><
map > <C-W>>
map + <C-W>+
map - <C-W>-

