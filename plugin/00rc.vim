
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
set smartcase
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/.DS_Store,*/node_modules/*,*/target/*,*/*.jar,*/*.class,*/*.zip,*/*.tar,*/*.gz,*/*.war,*/bower_components/*
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=2
set pastetoggle=<F2>
set so=999
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
" Write all changes when leaving buffer
set autowriteall

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
let mapleader="\<Space>"
nnoremap <leader>, :noh<CR>
nnoremap <Leader>a <esc>ggVG<CR>
nnoremap <Leader>l gg=G
" Split window and move to it
nnoremap <Leader>w <C-w>v<C-w>l
"nnoremap <Leader>t :UpdateTags <bar> HighlightTags<CR>
"nnoremap <Leader>b :CtrlPBuffer<CR>
" Generate tags for current directory
nnoremap <Leader>t :!ctags -R --exclude=.git --exclude=target --exclude=node_modules --exclude=bower_components .<CR>

au FileType xml nnoremap <Leader>l :%s/></>\r</g<CR> gg=G
au FileType json setlocal equalprg=python\ -m\ json.tool\ 2>/dev/null


colorscheme monokai
set t_Co=256

" CtrlP plugin
let g:ctrlp_max_files = 100000
let g:ctrlp_max_depth = 100
"let g:ctrlp_cmd = 'CtrlPMRU'

" Smooth scroll!
noremap <C-d> <C-d>M
noremap <C-u> <C-u>M
noremap <PageUp> <PageUp>M
noremap <PageDown> <PageDown>M
vmap v <Plug>(expand_region_expand)


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
"autocmd FileType java setlocal omnifunc=javacomplete#Complete

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif


" Auto-tags
set tags=./tags;
"let g:easytags_dynamic_files = 1
"let g:easytags_events = ['BufWritePost']
"let g:easytags_file = '~/.vim/tags'
"let g:easytags_auto_highlight = 0
"let g:easytags_on_cursorhold = 0
"let g:easytags_auto_update = 0
"let g:easytags_async = 0



