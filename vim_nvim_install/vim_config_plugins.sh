#!/bin/bash

# ==============================================
# Vim Config - Configurações de Plugins
# ==============================================

create_plugin_config() {
    echo_color "blue" "📝 Criando configurações de plugins do Vim..."
    
    cat > ~/.vim/config/plugins.vim << 'EOL'
" ==============================================
" Configurações de Plugins
" ==============================================

" Inicializar plugin manager
call plug#begin('~/.vim/plugged')

" Temas
Plug 'morhetz/gruvbox'
Plug 'dracula/vim'
Plug 'joshdick/onedark.vim'
Plug 'sainnhe/everforest'

" Interface
Plug 'vim-airline/vim-airline'
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'

" Produtividade
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'easymotion/vim-easymotion'
Plug 'jiangmiao/auto-pairs'
Plug 'mattn/emmet-vim'
Plug 'dense-analysis/ale'
Plug 'neoclide/coc.nvim'

call plug#end()
EOL

    check_status "criar configurações de plugins do Vim"
} 