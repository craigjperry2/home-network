autocmd!
set nocompatible
set relativenumber
syntax enable
set encoding=utf-8
scriptencoding utf-8
set fileencodings=utf-8,latin
set nobackup
set nohlsearch
set showcmd
set scrolloff=5
set expandtab
set background=light

set inccommand=split

" Don't redraw while executing macros
set lazyredraw

set smarttab
filetype plugin indent on
set tabstop=2
set shiftwidth=2
set ai
set nowrap
set backspace=start,eol,indent

" Finding files - Search down into subfolders
set path+=**
set wildignore+=*/node_modules/*

" Turn off paste mode when leaving insert
autocmd InsertLeave * set nopaste

" Toggle paste mode
nnoremap <F2> :set invpaste paste?<CR>

" Add asterisks in block comments
set formatoptions+=r

let mapleader=" "

set cursorline

" Restore last cursor position on re-opening a file & scroll to middle of screen
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g'\""
  \ |   exe "normal! zz"
  \ | endif

au BufNewFile,BufRead *.es6 setf javascript
au BufNewFile,BufRead *.tsx setf typescriptreact
au BufNewFile,BufRead *.md set filetype=markdown
au BufNewFile,BufRead *.mdx set filetype=markdown

set suffixesadd=.js,.es,.jsx,.json,.css,.less,.sass,.styl,.py,.md
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2

" fzf plugin
nnoremap <leader>zr :Rg
nnoremap <leader>zl :Lines<CR>
nnoremap <leader>zm :Marks<CR>
nnoremap <leader>zf :Files<CR>
nnoremap <leader>zb :Buffers<CR>
nnoremap <leader>zg :GFiles<CR>
nnoremap <leader>zt :Tags<CR>
nnoremap <leader>zh :History:<CR>
nnoremap <leader>z/ :History/<CR>

" Splits, used with C-w H/K to rearrange them
set splitright
set splitbelow
nnoremap <leader>- :new<CR>
nnoremap <leader>\| :vnew<CR>

" Resize windows
nmap <C-S-left> <C-w><
nmap <C-S-right> <C-w>>
nmap <C-S-up> <C-w>+
nmap <C-S-down> <C-w>-

" Buffer management
nnoremap <leader>bl :ls<CR>:buffer<Space>
nnoremap <leader>bj :bj<CR>
nnoremap <leader>bk :bk<CR>
nnoremap <leader>bd :bd<CR>

nmap te :tabedit
nmap <S-Tab> :tabprev<Return>
nmap <Tab> :tabnext<Return>

" Map Y like D, C etc. behave (to end of line)
nnoremap Y  y$

" Move lines up or down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv
