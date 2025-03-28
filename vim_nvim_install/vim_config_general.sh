#!/bin/bash

# ==============================================
# Vim Config - Configurações Gerais
# ==============================================

create_general_config() {
    echo_color "blue" "📝 Criando configurações gerais do Vim..."
    
    cat > ~/.vim/config/general.vim << 'EOL'
" ==============================================
" Configurações Gerais
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

" Configurações de terminal
set termguicolors
set background=dark
set t_Co=256
EOL

    check_status "criar configurações gerais do Vim"
} 