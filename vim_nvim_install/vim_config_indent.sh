#!/bin/bash

# ==============================================
# Vim Config - Configurações de Indentação
# ==============================================

create_indent_config() {
    echo_color "blue" "📝 Criando configurações de indentação do Vim..."
    
    cat > ~/.vim/config/indent.vim << 'EOL'
" ==============================================
" Configurações de Indentação
" ==============================================

" Configurações de indentação
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent
set cindent

" Configurações de list
set list
set listchars=tab:>-,trail:-,extends:>,precedes:<,nbsp:+

" Configurações de wrap
set wrap
set linebreak
set breakindent
set breakindentopt=sbr
set showbreak=↳
EOL

    check_status "criar configurações de indentação do Vim"
} 