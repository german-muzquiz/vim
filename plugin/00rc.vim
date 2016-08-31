
" Pathogen
filetype off
execute pathogen#infect()
filetype plugin indent on

" Basic
set nocompatible
set modelines=0
syntax on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab
set softtabstop=4
set encoding=utf-8
set nowrap
set scrolloff=3
set sidescroll=1
set sidescrolloff=50
set autoindent
set showmode
set showcmd
set hidden
" Show autocomplete options
set wildmenu
set wildmode=longest:full
set completeopt=longest,preview,menuone
set cursorline
set ttyfast
set ruler
set laststatus=2
set relativenumber
set number
"set undofile
" Highlight search matches
set hlsearch
set incsearch
set ignorecase
set smartcase
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/.DS_Store,*/node_modules/*,*/target/*,*/*.jar,*/*.class,*/*.zip,*/*.tar,*/*.gz,*/*.war,*/bower_components/*
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=2
set pastetoggle=<F2>


" Remaps
nnoremap / /\v
vnoremap / /\v

nnoremap <leader><space> :noh<cr>
nnoremap <tab> %
vnoremap <tab> %
nnoremap <F1> :NERDTreeToggle<CR>


" Custom bindings
let mapleader=","
nnoremap <Leader>a <esc>ggVG<CR>
nnoremap <Leader>l gg=G
" Split window and move to it
nnoremap <Leader>w <C-w>v<C-w>l
" Resize windows
"nnoremap <Leader>< <C-W><
"nnoremap <Leader>> <C-W>>
"nnoremap <Leader>+ <C-W>+
"nnoremap <Leader>- <C-W>-

au FileType xml setlocal equalprg=xmllint\ --format\ --recover\ -\ 2>/dev/null
au FileType json setlocal equalprg=python\ -m\ json.tool\ 2>/dev/null


colorscheme monokai
set t_Co=256

" CtrlP plugin
let g:ctrlp_max_files = 100000
let g:ctrlp_max_depth = 100
"let g:ctrlp_cmd = 'CtrlPMRU'

" Smooth scroll!
noremap <C-down> 1j1<C-e>
noremap <C-up> 1k1<C-y>
noremap <PageUp> <PageUp>Mgm
noremap <PageDown> <PageDown>Mgm


" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" Search visually selected text
vnoremap // y/<C-R>"<CR>

" Remember last position in file
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

set clipboard=unnamedplus

inoremap <expr> <C-n> pumvisible() ? '<C-n>' :
  \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'


"set complete+=k**/*.java

" Resize windows

