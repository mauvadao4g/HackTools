#!/bin/bash

# ==============================================
# SCP Menu Tool
# ==============================================
# Ferramenta para transferência segura de arquivos
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
        exit 1
    fi
}

# Função para verificar e instalar dependências
check_dependencies() {
    local packages=("openssh-client" "pv" "rsync")
    
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            echo_color "yellow" "🔄 Instalando $package..."
            apt-get update -y
            apt-get install -y $package
            check_status "instalar $package"
        else
            echo_color "green" "✅ $package já está instalado"
        fi
    done
}

# Função para validar IP
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        for octet in ${ip//./ }; do
            if [[ $octet -gt 255 ]]; then
                return 1
            fi
        done
        return 0
    fi
    return 1
}

# Função para validar porta
validate_port() {
    local port=$1
    if [[ $port =~ ^[0-9]+$ ]] && [ $port -ge 1 ] && [ $port -le 65535 ]; then
        return 0
    fi
    return 1
}

# Função para transferir arquivo
transfer_file() {
    local mode=$1
    local source=$2
    local destination=$3
    local user=$4
    local host=$5
    local port=$6
    local options=$7
    
    echo_color "blue" "🔄 Iniciando transferência..."
    echo_color "cyan" "📤 Origem: $source"
    echo_color "cyan" "📥 Destino: $destination"
    echo_color "yellow" "⚙️ Opções: $options"
    echo ""
    
    if [ "$mode" = "send" ]; then
        if [ ! -f "$source" ] && [ ! -d "$source" ]; then
            echo_color "red" "❌ Arquivo ou diretório não encontrado!"
            return 1
        fi
        
        echo_color "cyan" "📊 Tamanho: $(du -sh "$source" | cut -f1)"
        if [ -d "$source" ]; then
            echo_color "yellow" "📁 Modo: Diretório"
        else
            echo_color "yellow" "📄 Modo: Arquivo"
        fi
    fi
    
    if [ -z "$port" ]; then
        port="22"
    fi
    
    if [ -z "$options" ]; then
        options="-v"
    fi
    
    if [ "$mode" = "send" ]; then
        if [ -d "$source" ]; then
            scp $options -P $port -r "$source" "$user@$host:$destination"
        else
            scp $options -P $port "$source" "$user@$host:$destination"
        fi
    else
        scp $options -P $port "$user@$host:$source" "$destination"
    fi
    
    check_status "transferir arquivo"
}

# Função para sincronizar diretórios
sync_directories() {
    local source=$1
    local destination=$2
    local user=$3
    local host=$4
    local port=$5
    local options=$6
    
    echo_color "blue" "🔄 Iniciando sincronização..."
    echo_color "cyan" "📤 Origem: $source"
    echo_color "cyan" "📥 Destino: $destination"
    echo_color "yellow" "⚙️ Opções: $options"
    echo ""
    
    if [ ! -d "$source" ]; then
        echo_color "red" "❌ Diretório de origem não encontrado!"
        return 1
    fi
    
    echo_color "cyan" "📊 Tamanho: $(du -sh "$source" | cut -f1)"
    
    if [ -z "$port" ]; then
        port="22"
    fi
    
    if [ -z "$options" ]; then
        options="-avz --progress"
    fi
    
    rsync $options -e "ssh -p $port" "$source" "$user@$host:$destination"
    check_status "sincronizar diretórios"
}

# Banner
echo_color "magenta" "=============================================="
echo_color "yellow" "📤 SCP Menu Tool - Versão 1.0 📤"
echo_color "magenta" "=============================================="
echo_color "cyan" "Ferramenta para transferência segura de arquivos"
echo_color "magenta" "=============================================="
echo ""

# Verificar permissões de root
if [ "$EUID" -ne 0 ]; then 
    echo_color "red" "❌ Este script precisa ser executado como root (sudo)"
    exit 1
fi

# Verificar e instalar dependências
check_dependencies

# Menu principal
while true; do
    echo_color "cyan" "📋 Menu SCP:"
    echo "1) Enviar Arquivo"
    echo "2) Enviar Diretório"
    echo "3) Receber Arquivo"
    echo "4) Receber Diretório"
    echo "5) Sincronizar Diretórios (rsync)"
    echo "6) Enviar Arquivo com Compressão"
    echo "7) Receber Arquivo com Compressão"
    echo "8) Enviar Arquivo com Criptografia Forte"
    echo "9) Receber Arquivo com Criptografia Forte"
    echo "10) Enviar Arquivo com Barra de Progresso"
    echo "11) Receber Arquivo com Barra de Progresso"
    echo "12) Enviar Arquivo com Limite de Banda"
    echo "13) Receber Arquivo com Limite de Banda"
    echo "14) Enviar Arquivo com Retry"
    echo "15) Receber Arquivo com Retry"
    echo "0) Sair"
    echo ""
    
    read -p "Escolha uma opção (0-15): " option
    echo ""
    
    case $option in
        1|2|3|4|6|7|8|9|10|11|12|13|14|15)
            read -p "Digite o usuário remoto: " user
            read -p "Digite o IP ou domínio do servidor: " host
            if ! validate_ip "$host" && ! host "$host" &> /dev/null; then
                echo_color "red" "❌ IP ou domínio inválido!"
                continue
            fi
            
            read -p "Digite a porta SSH (pressione ENTER para padrão 22): " port
            if [ ! -z "$port" ] && ! validate_port "$port"; then
                echo_color "red" "❌ Porta inválida!"
                continue
            fi
            
            case $option in
                1|2|6|8|10|12|14)
                    read -p "Digite o caminho do arquivo/diretório local: " source
                    read -p "Digite o caminho de destino no servidor: " destination
                    ;;
                3|4|7|9|11|13|15)
                    read -p "Digite o caminho do arquivo/diretório no servidor: " source
                    read -p "Digite o caminho de destino local: " destination
                    ;;
            esac
            
            case $option in
                1|3)
                    transfer_file "$([ $option -eq 1 ] && echo 'send' || echo 'receive')" "$source" "$destination" "$user" "$host" "$port" "-v"
                    ;;
                2|4)
                    transfer_file "$([ $option -eq 2 ] && echo 'send' || echo 'receive')" "$source" "$destination" "$user" "$host" "$port" "-rv"
                    ;;
                6|7)
                    transfer_file "$([ $option -eq 6 ] && echo 'send' || echo 'receive')" "$source" "$destination" "$user" "$host" "$port" "-Cv"
                    ;;
                8|9)
                    transfer_file "$([ $option -eq 8 ] && echo 'send' || echo 'receive')" "$source" "$destination" "$user" "$host" "$port" "-c aes256-gcm@openssh.com -v"
                    ;;
                10|11)
                    transfer_file "$([ $option -eq 10 ] && echo 'send' || echo 'receive')" "$source" "$destination" "$user" "$host" "$port" "-v" | pv
                    ;;
                12|13)
                    read -p "Digite o limite de banda em KB/s: " bandwidth
                    transfer_file "$([ $option -eq 12 ] && echo 'send' || echo 'receive')" "$source" "$destination" "$user" "$host" "$port" "-l $bandwidth -v"
                    ;;
                14|15)
                    transfer_file "$([ $option -eq 14 ] && echo 'send' || echo 'receive')" "$source" "$destination" "$user" "$host" "$port" "-v -o ServerAliveInterval=60 -o ServerAliveCountMax=3"
                    ;;
            esac
            ;;
            
        5)
            read -p "Digite o usuário remoto: " user
            read -p "Digite o IP ou domínio do servidor: " host
            if ! validate_ip "$host" && ! host "$host" &> /dev/null; then
                echo_color "red" "❌ IP ou domínio inválido!"
                continue
            fi
            
            read -p "Digite a porta SSH (pressione ENTER para padrão 22): " port
            if [ ! -z "$port" ] && ! validate_port "$port"; then
                echo_color "red" "❌ Porta inválida!"
                continue
            fi
            
            read -p "Digite o caminho do diretório local: " source
            read -p "Digite o caminho do diretório no servidor: " destination
            
            sync_directories "$source" "$destination" "$user" "$host" "$port" "-avz --progress"
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