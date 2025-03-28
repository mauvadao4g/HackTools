#!/bin/bash

# ==============================================
# Vim Config - Script de Instalação
# ==============================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Funções auxiliares
echo_color() {
    echo -e "${!1}${2}${NC}"
}

check_status() {
    if [ $? -eq 0 ]; then
        echo_color "GREEN" "✓ $1 concluído com sucesso!"
    else
        echo_color "RED" "✗ Erro ao $1"
        exit 1
    fi
}

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    echo "Por favor, execute como root"
    exit 1
fi

# Criar diretórios necessários
mkdir -p ~/.vim/{config,plugged,colors,syntax,indent,ftplugin,ftdetect,spell,doc,plugin,undodir}
check_status "criar diretórios do Vim"

# Instalar dependências
apt-get update
apt-get install -y git curl wget python3 python3-pip nodejs npm
check_status "instalar dependências"

# Instalar Vim e Neovim
add-apt-repository -y ppa:neovim-ppa/stable
apt-get update
apt-get install -y vim neovim
check_status "instalar Vim e Neovim"

# Instalar Vim-Plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
check_status "instalar Vim-Plug"

# Executar configuração principal
source vim_config_main.sh

echo "✨ Instalação concluída! Execute ':PlugInstall' no Vim para instalar os plugins." 