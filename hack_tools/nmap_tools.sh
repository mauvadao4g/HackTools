#!/bin/bash

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

# Função para verificar se um comando foi executado com sucesso
check_status() {
    if [ $? -eq 0 ]; then
        echo_color "green" "✅ $1"
    else
        echo_color "red" "❌ Erro ao $1"
        exit 1
    fi
}

# Função para verificar e instalar o Nmap
check_nmap() {
    if ! command -v nmap &> /dev/null; then
        echo_color "yellow" "🔄 Nmap não encontrado. Instalando..."
        apt-get update -y
        apt-get install -y nmap
        check_status "instalar Nmap"
    else
        echo_color "green" "✅ Nmap já está instalado"
    fi
}

# Função para realizar scan
perform_scan() {
    local target=$1
    local scan_type=$2
    local options=$3
    
    echo_color "blue" "🔍 Iniciando scan: $scan_type"
    echo_color "cyan" "🎯 Alvo: $target"
    echo_color "yellow" "⚙️ Opções: $options"
    echo ""
    
    nmap $options $target
    echo ""
    echo_color "green" "✅ Scan concluído!"
}

# Banner
echo_color "magenta" "==============================="
echo_color "yellow" "🔍 Nmap Scanner Tool 🔍"
echo_color "magenta" "==============================="
echo ""

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    echo_color "red" "❌ Este script precisa ser executado como root (sudo)"
    exit 1
fi

# Verificar e instalar Nmap
check_nmap

# Menu principal
while true; do
    echo_color "cyan" "📋 Menu de Scans:"
    echo "1) Scan Básico (Ping Scan)"
    echo "2) Scan de Portas Comuns"
    echo "3) Scan Completo"
    echo "4) Scan de Serviços"
    echo "5) Scan de Vulnerabilidades"
    echo "6) Scan de Sistema Operacional"
    echo "7) Scan de Firewall"
    echo "8) Scan de UDP"
    echo "9) Scan Personalizado"
    echo "0) Sair"
    echo ""
    
    read -p "Escolha uma opção (0-9): " option
    echo ""
    
    case $option in
        1)
            read -p "Digite o IP ou domínio alvo: " target
            perform_scan "$target" "Ping Scan" "-sn"
            ;;
        2)
            read -p "Digite o IP ou domínio alvo: " target
            perform_scan "$target" "Portas Comuns" "-F"
            ;;
        3)
            read -p "Digite o IP ou domínio alvo: " target
            perform_scan "$target" "Scan Completo" "-sS -sV -sC -A -O"
            ;;
        4)
            read -p "Digite o IP ou domínio alvo: " target
            perform_scan "$target" "Scan de Serviços" "-sV"
            ;;
        5)
            read -p "Digite o IP ou domínio alvo: " target
            perform_scan "$target" "Scan de Vulnerabilidades" "--script vuln"
            ;;
        6)
            read -p "Digite o IP ou domínio alvo: " target
            perform_scan "$target" "Scan de Sistema Operacional" "-O"
            ;;
        7)
            read -p "Digite o IP ou domínio alvo: " target
            perform_scan "$target" "Scan de Firewall" "--script firewall-bypass"
            ;;
        8)
            read -p "Digite o IP ou domínio alvo: " target
            perform_scan "$target" "Scan UDP" "-sU"
            ;;
        9)
            read -p "Digite o IP ou domínio alvo: " target
            read -p "Digite as opções personalizadas do Nmap: " custom_options
            perform_scan "$target" "Scan Personalizado" "$custom_options"
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
