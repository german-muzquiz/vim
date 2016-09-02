
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
set so=999
set clipboard=unnamedplus
set backupdir=~/.vim/backup
set directory=~/.vim/swap

if has('statusline')
  set laststatus=2
  " Broken down into easily includeable segments
  set statusline=\ %n\ %*             "buffer number
  set statusline+=%<%f\    " Filename
  set statusline+=%w%h%m%r " Options
  set statusline+=%{fugitive#statusline()} "  Git Hotness
  set statusline+=\ [%{&ff}/%Y]            " filetype
"  set statusline+=\ [%{getcwd()}]          " current dir
  set statusline+=%#warningmsg#
  set statusline+=%*
  set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
endif


" Remaps
nnoremap <F1> :NERDTreeToggle<CR>


" Custom bindings
let mapleader=","
nnoremap <leader><space> :noh<cr>
nnoremap <Leader>a <esc>ggVG<CR>
nnoremap <Leader>l gg=G
" Split window and move to it
nnoremap <Leader>w <C-w>v<C-w>l

au FileType xml nnoremap <Leader>l :%s/></>\r</g<CR> gg=G
au FileType json setlocal equalprg=python\ -m\ json.tool\ 2>/dev/null


colorscheme monokai
set t_Co=256

" CtrlP plugin
let g:ctrlp_max_files = 100000
let g:ctrlp_max_depth = 100
"let g:ctrlp_cmd = 'CtrlPMRU'

" Smooth scroll!
noremap <C-d> <C-d>Mgm
noremap <C-u> <C-u>Mgm
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


inoremap <expr> <C-n> pumvisible() ? '<C-n>' :
  \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'


"set complete+=k**/*.java

" Neocomplete stuff
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
let g:neocomplete#sources#omni#input_patterns.java = '\h\w*\.\w*'


