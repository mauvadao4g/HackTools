#!/bin/bash

# ==============================================
# Vim Tools Menu
# ==============================================
# Script para instalação e configuração do Vim/Neovim
# ==============================================

# Função para exibir mensagens coloridas
echo_color() {
    local color=$1
    local message=$2
    case $color in
        "red") echo -e "\033[1;31m$message\033[0m" ;;
        "green") echo -e "\033[1;32m$message\033[0m" ;;
        "yellow") echo -e "\033[1;33m$message\033[0m" ;;
        "blue") echo -e "\033[1;34m$message\033[0m" ;;
        "magenta") echo -e "\033[1;35m$message\033[0m" ;;
        "cyan") echo -e "\033[1;36m$message\033[0m" ;;
        *) echo -e "$message" ;;
    esac
}

# Função para verificar status de comandos
check_status() {
    if [ $? -eq 0 ]; then
        echo_color "green" "✅ $1"
    else
        echo_color "red" "❌ Erro ao $1"
        # exit 1
    fi
}

# Função para instalar dependências
install_dependencies() {
    echo_color "blue" "📦 Instalando dependências..."
    
    # Dependências básicas
    apt-get install -y \
        git \
        curl \
        wget \
        build-essential \
        python3 \
        python3-pip \
        nodejs \
        npm \
        ripgrep \
        fd-find \
        ctags \
        universal-ctags \
        silversearcher-ag \
        fzf \
        bat \
        exa \
        delta \
        check_status "instalar dependências básicas"
    
    # Instalar plugins Python
    pip3 install pynvim
    check_status "instalar pynvim"
    
    # Instalar plugins Node.js
    npm install -g neovim
    check_status "instalar neovim via npm"
}

# Função para instalar Vim e Neovim
install_vim() {
    echo_color "blue" "📝 Instalando Vim e Neovim..."
    
    # Adicionar repositório do Neovim
    add-apt-repository -y ppa:neovim-ppa/stable
    apt-get update
    
    # Instalar Vim e Neovim
    apt-get install -y vim neovim
    check_status "instalar Vim e Neovim"
}

# Função para instalar Vim-Plug
install_vim_plug() {
    echo_color "blue" "🔌 Instalando Vim-Plug..."
    
    # Instalar Vim-Plug para Vim
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    check_status "instalar Vim-Plug para Vim"
    
    # Instalar Vim-Plug para Neovim
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    check_status "instalar Vim-Plug para Neovim"
}

# Função para criar diretórios necessários
create_directories() {
    echo_color "blue" "📁 Criando diretórios..."
    
    # Diretórios para Vim
    mkdir -p ~/.vim/{plugged,colors,syntax,ftplugin,indent,autoload}
    mkdir -p ~/.vim/snippets/{html,css,javascript,php,python,bash}
    
    # Diretórios para Neovim
    mkdir -p ~/.config/nvim/{plugged,colors,syntax,ftplugin,indent,autoload}
    mkdir -p ~/.config/nvim/snippets/{html,css,javascript,php,python,bash}
    
    check_status "criar diretórios"
}

# Função para instalar temas
install_themes() {
    echo_color "blue" "🎨 Instalando temas..."
    
    # Temas populares
    themes=(
        "morhetz/gruvbox"
        "dracula/vim"
        "joshdick/onedark.vim"
        "arcticicestudio/nord-vim"
        "sainnhe/sonokai"
        "sainnhe/everforest"
        "sainnhe/edge"
        "sainnhe/gruvbox-material"
        "sainnhe/forest-night"
        "sainnhe/aurora"
        "sainnhe/space-vim-dark"
        "sainnhe/space-vim-light"
        "sainnhe/lightline_sonokai"
        "sainnhe/lightline_everforest"
        "sainnhe/lightline_edge"
        "sainnhe/lightline_gruvbox_material"
        "sainnhe/lightline_forest_night"
        "sainnhe/lightline_aurora"
        "sainnhe/lightline_space_vim_dark"
        "sainnhe/lightline_space_vim_light"
    )
    
    for theme in "${themes[@]}"; do
        echo_color "cyan" "🔄 Instalando tema: $theme"
        git clone "https://github.com/$theme.git" ~/.vim/plugged/$(basename $theme)
        git clone "https://github.com/$theme.git" ~/.config/nvim/plugged/$(basename $theme)
    done
    
    check_status "instalar temas"
}

# Função para instalar plugins
install_plugins() {
    echo_color "blue" "🔌 Instalando plugins..."
    
    # Plugins para desenvolvimento web
    web_plugins=(
        "mattn/emmet-vim"
        "pangloss/vim-javascript"
        "leafgarland/typescript-vim"
        "peitalin/vim-jsx-typescript"
        "styled-components/vim-styled-components"
        "jparise/vim-graphql"
        "posva/vim-vue"
        "dense-analysis/ale"
        "neoclide/coc.nvim"
        "neoclide/coc-tsserver"
        "neoclide/coc-html"
        "neoclide/coc-css"
        "neoclide/coc-json"
        "neoclide/coc-yaml"
        "neoclide/coc-markdownlint"
        "neoclide/coc-eslint"
        "neoclide/coc-prettier"
        "neoclide/coc-emoji"
        "neoclide/coc-git"
        "neoclide/coc-snippets"
    )
    
    # Plugins para desenvolvimento bash
    bash_plugins=(
        "vim-scripts/bash-support.vim"
        "vim-scripts/bashdb"
        "vim-scripts/ShellCheck"
        "vim-scripts/bash-completion"
        "vim-scripts/bash-syntax"
        "vim-scripts/bash-folding"
        "vim-scripts/bash-indent"
        "vim-scripts/bash-snippets"
    )
    
    # Plugins gerais
    general_plugins=(
        "junegunn/fzf.vim"
        "junegunn/vim-easy-align"
        "junegunn/goyo.vim"
        "junegunn/limelight.vim"
        "junegunn/vim-peekaboo"
        "junegunn/vim-slash"
        "junegunn/vim-after-object"
        "junegunn/vim-pseudocl"
        "junegunn/vim-oblique"
        "junegunn/vim-fnr"
        "junegunn/vim-rsi"
        "junegunn/vim-emoji"
        "junegunn/vim-journal"
        "junegunn/vim-pseudocl"
        "junegunn/vim-pseudocl"
        "junegunn/vim-pseudocl"
        "junegunn/vim-pseudocl"
        "junegunn/vim-pseudocl"
        "junegunn/vim-pseudocl"
        "junegunn/vim-pseudocl"
    )
    
    # Instalar plugins
    for plugin in "${web_plugins[@]}" "${bash_plugins[@]}" "${general_plugins[@]}"; do
        echo_color "cyan" "🔄 Instalando plugin: $plugin"
        git clone "https://github.com/$plugin.git" ~/.vim/plugged/$(basename $plugin)
        git clone "https://github.com/$plugin.git" ~/.config/nvim/plugged/$(basename $plugin)
    done
    
    check_status "instalar plugins"
}

# Banner
echo_color "magenta" "=============================================="
echo_color "yellow" "📝 Vim Tools Menu - Versão 1.0 📝"
echo_color "magenta" "=============================================="
echo_color "cyan" "Script para instalação e configuração do Vim/Neovim"
echo_color "magenta" "=============================================="
echo ""

# Verificar permissões de root
if [ "$EUID" -ne 0 ]; then 
    echo_color "red" "❌ Este script precisa ser executado como root (sudo)"
    # exit 1
fi

# Menu principal
while true; do
    echo_color "cyan" "📋 Menu Vim Tools:"
    echo "1) Instalar Dependências"
    echo "2) Instalar Vim e Neovim"
    echo "3) Instalar Vim-Plug"
    echo "4) Criar Diretórios"
    echo "5) Instalar Temas"
    echo "6) Instalar Plugins"
    echo "7) Instalar Tudo"
    echo "0) Sair"
    echo ""
    
    read -p "Escolha uma opção (0-7): " option
    echo ""
    
    case $option in
        1)
            install_dependencies
            ;;
            
        2)
            install_vim
            ;;
            
        3)
            install_vim_plug
            ;;
            
        4)
            create_directories
            ;;
            
        5)
            install_themes
            ;;
            
        6)
            install_plugins
            ;;
            
        7)
            install_dependencies
            install_vim
            install_vim_plug
            create_directories
            install_themes
            install_plugins
            ;;
            
        0)
            echo_color "green" "👋 Até logo!"
            exit 0
            ;;
            
        *)
            echo_color "red" "❌ Opção inválida!"
            ;;
    esac
    
    echo ""
    read -p "Pressione ENTER para continuar..."
    clear
done 
