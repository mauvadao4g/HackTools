#!/bin/bash

# ==============================================
# Vim Config - Configurações de Busca
# ==============================================

create_search_config() {
    echo_color "blue" "📝 Criando configurações de busca do Vim..."
    
    cat > ~/.vim/config/search.vim << 'EOL'
" ==============================================
" Configurações de Busca
" ==============================================

" Configurações de busca
set hlsearch
set incsearch
set ignorecase
set smartcase
set wrapscan

" Configurações de scroll
set scrolloff=5
set sidescrolloff=5

" Configurações de performance
set lazyredraw
set ttyfast
set timeoutlen=1000
set ttimeoutlen=0
EOL

    check_status "criar configurações de busca do Vim"
} 