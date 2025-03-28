#!/bin/bash

# ==============================================
# Vim Config - Configurações de Backup e Histórico
# ==============================================

create_backup_config() {
    echo_color "blue" "📝 Criando configurações de backup e histórico do Vim..."
    
    cat > ~/.vim/config/backup.vim << 'EOL'
" ==============================================
" Configurações de Backup e Histórico
" ==============================================

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
EOL

    check_status "criar configurações de backup e histórico do Vim"
} 