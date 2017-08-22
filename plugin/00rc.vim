
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
" Highlight search matches
set hlsearch
set incsearch
set smartcase
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/.DS_Store,*/node_modules/*,*/target/*,*/*.jar,*/*.class,*/*.zip,*/*.tar,*/*.gz,*/*.war,*/bower_components/*,*/dist/*
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=2
set pastetoggle=<F3>
set so=999
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
" Write all changes when leaving buffer
set autowriteall
set path+=**
set tags=./tags;
set synmaxcol=120
colorscheme monokai
set t_Co=256


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


" Custom bindings
let mapleader="\<Space>"
" Hide search highlights
nnoremap <leader>, :noh<CR>
" Select all
nnoremap <Leader>a <esc>ggVG<CR>
" Format all
nnoremap <Leader>l :syntax off<CR> gg=G :syntax on<CR>
" Split window and move to it
nnoremap <Leader>w <C-w>v<C-w>l
" Generate tags for current directory
nnoremap <Leader>t :!ctags -R --exclude=.git --exclude=target --exclude=node_modules --exclude=bower_components --exclude=dist --fields=+l --c-kinds=+ --c++-kinds=+p --extra=+q .<CR>
" Grep all project
nnoremap <Leader>f :grep -R --exclude-dir=target --exclude-dir=node_modules --exclude-dir=bower_components --exclude-dir=.git --exclude-dir=dist --exclude=tags "" .
" Go back to previous buffer
nnoremap <Leader>6 :b#<CR>

" au FileType xml nnoremap <Leader>l :%s/&lt;/</g<CR> :%s/&gt;/>/g<CR> :%s/></>\r</g<CR> :syntax off<CR> gg=G :syntax on<CR>
au FileType xml nnoremap <Leader>l :%s/></>\r</g<CR> :syntax off<CR> gg=G :syntax on<CR>
au FileType json setlocal equalprg=python\ -m\ json.tool\ 2>/dev/null


" Smooth scroll!
noremap <C-d> <C-d>M
noremap <C-u> <C-u>M
noremap <PageUp> <PageUp>M
noremap <PageDown> <PageDown>M
vmap v <Plug>(expand_region_expand)

nnoremap <silent> }c :cnext<CR>
nnoremap <silent> {c :cprevious<CR>
nnoremap <silent> }t :tnext<CR>
nnoremap <silent> {t :tprevious<CR>

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


" Neocomplete configuration
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


" Syntastic configuration
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_enable_signs = 1
let g:syntastic_typescript_checkers = ['tsuquyomi'] " You shouldn't use 'tsc' checker.
let g:syntastic_java_checkers = ['javac']
let g:syntastic_java_javac_config_file_enabled = 1
let g:syntastic_java_maven_options = '-o'
let g:syntastic_scala_checkers = []
let g:tsuquyomi_disable_quickfix = 1
"let g:tsuquyomi_disable_default_mappings = 0
source ~/.vim/bundle/syntastic/plugin/syntastic.vim
source ~/.vim/bundle/syntastic/syntax_checkers/java/javac.vim


" xmledit configuration
let g:closetag_filenames = "*.html,*.xhtml,*.phtml, *.xml"


" NERDTree configuration
let NERDTreeWinSize=45
nnoremap <F1> :NERDTreeToggle<CR>
nnoremap <F2> :NERDTreeFind<CR>

