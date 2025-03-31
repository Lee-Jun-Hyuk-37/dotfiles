set exrc
set secure
" let g:python3_host_prog = expand('dir to python')
" :echo g:python3_host_prog

let g:netrw_liststyle=3     " Explore tree type

inoremap jk <esc>
inoremap kj <esc>
noremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>gi
cnoreabbrev <expr> vs getcmdtype() == ':' && getcmdline() == 'vs' ? 'vs \| wincmd l' : 'vs'
cnoreabbrev <expr> sp getcmdtype() == ':' && getcmdline() == 'sp' ? 'sp \| wincmd j' : 'sp'

set mouse=a
set backspace=indent,eol,start

set nocompatible
set number
set norelativenumber
set showcmd
set showmode
set wildmenu
set title

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent
set smartindent
set smarttab

set ignorecase
set smartcase
set incsearch
set hlsearch

set noswapfile
set nobackup
set noundofile

set wrap
set scrolloff=5
set sidescrolloff=5

set clipboard=unnamed
filetype plugin indent on
syntax on

if has('termguicolors')
    set termguicolors
endif

colorscheme habamax
" colorscheme slate

set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,euc-kr

set shell=powershell.exe
set shellcmdflag=-NoLogo\ -NoProfile\ -Command
set shellquote=\"
set shellxquote=

"Plugin settings
call plug#begin('~/vimfiles/plugged')
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-commentary'
Plug 'dense-analysis/ale'
Plug 'mhinz/vim-signify'
call plug#end()

" ALE settings
let g:ale_linters_explicit = 1
let g:ale_fix_on_save = 1
let g:ale_completion_enabled = 1
let g:ale_virtualtext_cursor = 1
" flake8, black, pylsp need to be installed
" pip install flake8 black python-lsp-server
" check with :echo exepath('')
let g:ale_linters = {'python': ['flake8'],}
let g:ale_fixers = {'python': ['black'],}

" vim-signify settings
let g:signify_sign_add = '+'
let g:signify_sign_change = '~'
let g:signify_sign_delete = '-'

if exists('$WT_SESSION') || &term =~ 'xterm'
    let &t_EI = "\e[2 q"    " normal mode: block
    let &t_SI = "\e[6 q"    " insert mode: bar
endif
