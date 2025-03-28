#!/bin/bash

# ==============================================
# Vim Config - Parte 1: Configurações Básicas
# ==============================================

# Função para criar configuração básica do Vim
create_basic_config() {
    echo_color "blue" "📝 Criando configuração básica do Vim..."
    
    # Criar arquivo .vimrc
    cat > ~/.vimrc << 'EOL'
" ==============================================
" Configurações Básicas
" ==============================================

" Desabilitar compatibilidade com vi
set nocompatible

" Configurações de encoding
set encoding=utf-8
set fileencoding=utf-8
set termencoding=utf-8

" Configurações de interface
set number
set relativenumber
set cursorline
set cursorcolumn
set showmatch
set matchtime=2
set showmode
set showcmd
set laststatus=2
set ruler
set wildmenu
set wildmode=list:longest,full
set visualbell
set t_vb=
set mouse=a
set clipboard=unnamedplus

" Configurações de indentação
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent
set cindent

" Configurações de busca
set hlsearch
set incsearch
set ignorecase
set smartcase
set wrapscan

" Configurações de performance
set lazyredraw
set ttyfast
set timeoutlen=1000
set ttimeoutlen=0

" Configurações de backup
set nobackup
set nowritebackup
set noswapfile
set undofile
set undodir=~/.vim/undodir
set history=1000

" Configurações de spell check
set spell
set spelllang=en_us

" Configurações de split
set splitbelow
set splitright
set fillchars+=vert:\ 
set fillchars+=horiz:\ 

" Configurações de list
set list
set listchars=tab:>-,trail:-,extends:>,precedes:<,nbsp:+

" Configurações de scroll
set scrolloff=5
set sidescrolloff=5

" Configurações de wrap
set wrap
set linebreak
set breakindent
set breakindentopt=sbr
set showbreak=↳

" Configurações de fold
set foldenable
set foldmethod=indent
set foldlevel=99
set foldnestmax=10
set nofoldenable
set foldlevelstart=99

" Configurações de completion
set completeopt=menu,menuone,noselect
set pumheight=10
set pumwidth=30

" Configurações de terminal
set termguicolors
set background=dark
set t_Co=256

" Configurações de status line
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ %{strftime(\"%d/%m/%y\ -\ %H:%M\")}
EOL

    check_status "criar configuração básica do Vim"
} 