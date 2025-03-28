#!/bin/bash

# ==============================================
# Instalação de Pacotes
# ==============================================
# Script para instalação automática de pacotes
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

# Função para atualizar o sistema
update_system() {
    echo_color "yellow" "🔄 Atualizando o sistema..."
    apt-get update -y
    check_status "atualizar repositórios"
    
    apt-get upgrade -y
    check_status "atualizar pacotes"
}

# Função para instalar pacotes
install_packages() {
    local packages=("$@")
    local total=${#packages[@]}
    local current=0
    
    echo_color "blue" "📦 Instalando $total pacotes..."
    
    for package in "${packages[@]}"; do
        ((current++))
        echo_color "cyan" "🔄 Instalando $package ($current/$total)..."
        
        if ! command -v "$package" &> /dev/null; then
            apt-get install -y "$package"
            check_status "instalar $package"
        else
            echo_color "green" "✅ $package já está instalado"
        fi
    done
}

# Função para instalar pacotes via snap
install_snap_packages() {
    local packages=("$@")
    local total=${#packages[@]}
    local current=0
    
    echo_color "blue" "📦 Instalando $total pacotes via snap..."
    
    for package in "${packages[@]}"; do
        ((current++))
        echo_color "cyan" "🔄 Instalando $package ($current/$total)..."
        
        if ! snap list | grep -q "^$package "; then
            snap install "$package"
            check_status "instalar $package via snap"
        else
            echo_color "green" "✅ $package já está instalado via snap"
        fi
    done
}

# Função para instalar pacotes via pip
install_pip_packages() {
    local packages=("$@")
    local total=${#packages[@]}
    local current=0
    
    echo_color "blue" "📦 Instalando $total pacotes via pip..."
    
    for package in "${packages[@]}"; do
        ((current++))
        echo_color "cyan" "🔄 Instalando $package ($current/$total)..."
        
        if ! pip3 show "$package" &> /dev/null; then
            pip3 install "$package"
            check_status "instalar $package via pip"
        else
            echo_color "green" "✅ $package já está instalado via pip"
        fi
    done
}

# Função para instalar pacotes via npm
install_npm_packages() {
    local packages=("$@")
    local total=${#packages[@]}
    local current=0
    
    echo_color "blue" "📦 Instalando $total pacotes via npm..."
    
    for package in "${packages[@]}"; do
        ((current++))
        echo_color "cyan" "🔄 Instalando $package ($current/$total)..."
        
        if ! npm list -g "$package" &> /dev/null; then
            npm install -g "$package"
            check_status "instalar $package via npm"
        else
            echo_color "green" "✅ $package já está instalado via npm"
        fi
    done
}

# Banner
echo_color "magenta" "=============================================="
echo_color "yellow" "🛠️  Instalação de Pacotes - Versão 1.0 🛠️"
echo_color "magenta" "=============================================="
echo_color "cyan" "Script para instalação automática de pacotes"
echo_color "magenta" "=============================================="
echo ""

# Verificar permissões de root
if [ "$EUID" -ne 0 ]; then 
    echo_color "red" "❌ Este script precisa ser executado como root (sudo)"
    exit 1
fi

# Array de pacotes para instalação
apt_packages=(
    "curl"
    "wget"
    "git"
    "vim"
    "htop"
    "net-tools"
    "nmap"
    "hydra"
    "gcc"
    "make"
    "python3"
    "python3-pip"
    "nodejs"
    "npm"
    "snapd"
    "build-essential"
    "software-properties-common"
    "unzip"
    "zip"
    "tar"
    "gzip"
    "bzip2"
    "rsync"
    "ssh"
    "openssh-server"
    "ufw"
    "fail2ban"
    "logwatch"
    "rkhunter"
    "lynis"
)

snap_packages=(
    "code"
    "spotify"
    "slack"
    "discord"
    "telegram-desktop"
    "chromium"
    "firefox"
)

pip_packages=(
    "requests"
    "beautifulsoup4"
    "selenium"
    "scrapy"
    "pandas"
    "numpy"
    "matplotlib"
    "flask"
    "django"
    "fastapi"
    "uvicorn"
    "pytest"
    "black"
    "flake8"
    "mypy"
)

npm_packages=(
    "typescript"
    "ts-node"
    "nodemon"
    "express"
    "react"
    "react-dom"
    "vue"
    "angular"
    "yarn"
    "pm2"
    "gulp"
    "webpack"
    "babel"
    "eslint"
    "prettier"
)

# Menu principal
while true; do
    echo_color "cyan" "📋 Menu de Instalação:"
    echo "1) Atualizar Sistema"
    echo "2) Instalar Pacotes APT"
    echo "3) Instalar Pacotes Snap"
    echo "4) Instalar Pacotes PIP"
    echo "5) Instalar Pacotes NPM"
    echo "6) Instalar Todos os Pacotes"
    echo "0) Sair"
    echo ""
    
    read -p "Escolha uma opção (0-6): " option
    echo ""
    
    case $option in
        1)
            update_system
            ;;
            
        2)
            install_packages "${apt_packages[@]}"
            ;;
            
        3)
            install_snap_packages "${snap_packages[@]}"
            ;;
            
        4)
            install_pip_packages "${pip_packages[@]}"
            ;;
            
        5)
            install_npm_packages "${npm_packages[@]}"
            ;;
            
        6)
            update_system
            install_packages "${apt_packages[@]}"
            install_snap_packages "${snap_packages[@]}"
            install_pip_packages "${pip_packages[@]}"
            install_npm_packages "${npm_packages[@]}"
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
