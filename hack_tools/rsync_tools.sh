#!/bin/bash

# ==============================================
# RSYNC Tools Menu
# ==============================================
# Ferramentas para sincronização de arquivos
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

# Função para verificar e instalar rsync
check_rsync() {
    if ! command -v rsync &> /dev/null; then
        echo_color "yellow" "🔄 Instalando rsync..."
        apt-get update -y
        apt-get install -y rsync
        check_status "instalar rsync"
    else
        echo_color "green" "✅ rsync já está instalado"
    fi
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

# Função para sincronização local
sync_local() {
    local source=$1
    local destination=$2
    local options=$3
    
    echo_color "blue" "🔄 Iniciando sincronização local..."
    echo_color "cyan" "📤 Origem: $source"
    echo_color "cyan" "📥 Destino: $destination"
    echo_color "yellow" "⚙️ Opções: $options"
    echo ""
    
    if [ ! -d "$source" ]; then
        echo_color "red" "❌ Diretório de origem não encontrado!"
        return 1
    fi
    
    echo_color "cyan" "📊 Tamanho: $(du -sh "$source" | cut -f1)"
    
    rsync $options "$source" "$destination"
    check_status "sincronizar diretórios"
}

# Função para sincronização remota
sync_remote() {
    local source=$1
    local destination=$2
    local user=$3
    local host=$4
    local port=$5
    local options=$6
    
    echo_color "blue" "🔄 Iniciando sincronização remota..."
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
    
    rsync $options -e "ssh -p $port" "$source" "$user@$host:$destination"
    check_status "sincronizar diretórios"
}

# Função para backup
create_backup() {
    local source=$1
    local destination=$2
    local options=$3
    
    echo_color "blue" "💾 Criando backup..."
    echo_color "cyan" "📤 Origem: $source"
    echo_color "cyan" "📥 Destino: $destination"
    echo_color "yellow" "⚙️ Opções: $options"
    echo ""
    
    if [ ! -d "$source" ]; then
        echo_color "red" "❌ Diretório de origem não encontrado!"
        return 1
    fi
    
    echo_color "cyan" "📊 Tamanho: $(du -sh "$source" | cut -f1)"
    
    rsync $options "$source" "$destination"
    check_status "criar backup"
}

# Banner
echo_color "magenta" "=============================================="
echo_color "yellow" "🔄 RSYNC Tools Menu - Versão 1.0 🔄"
echo_color "magenta" "=============================================="
echo_color "cyan" "Ferramentas para sincronização de arquivos"
echo_color "magenta" "=============================================="
echo ""

# Verificar permissões de root
if [ "$EUID" -ne 0 ]; then 
    echo_color "red" "❌ Este script precisa ser executado como root (sudo)"
    exit 1
fi

# Verificar e instalar rsync
check_rsync

# Menu principal
while true; do
    echo_color "cyan" "📋 Menu RSYNC:"
    echo "1) Sincronização Local (Básica)"
    echo "2) Sincronização Local (Com Compressão)"
    echo "3) Sincronização Local (Com Exclusão)"
    echo "4) Sincronização Local (Com Permissões)"
    echo "5) Sincronização Remota (Básica)"
    echo "6) Sincronização Remota (Com Compressão)"
    echo "7) Sincronização Remota (Com Exclusão)"
    echo "8) Sincronização Remota (Com Permissões)"
    echo "9) Backup Local (Com Timestamp)"
    echo "10) Backup Remoto (Com Timestamp)"
    echo "11) Sincronização com Limite de Banda"
    echo "12) Sincronização com Retry"
    echo "13) Sincronização com Verificação"
    echo "14) Sincronização com Log"
    echo "15) Sincronização com Exclusão de Arquivos Temporários"
    echo "0) Sair"
    echo ""
    
    read -p "Escolha uma opção (0-15): " option
    echo ""
    
    case $option in
        1|2|3|4)
            read -p "Digite o diretório de origem: " source
            read -p "Digite o diretório de destino: " destination
            
            case $option in
                1)
                    sync_local "$source" "$destination" "-av --progress"
                    ;;
                2)
                    sync_local "$source" "$destination" "-avz --progress"
                    ;;
                3)
                    read -p "Digite o padrão de exclusão (ex: *.tmp): " exclude
                    sync_local "$source" "$destination" "-av --progress --exclude='$exclude'"
                    ;;
                4)
                    sync_local "$source" "$destination" "-av --progress --perms --owner --group"
                    ;;
            esac
            ;;
            
        5|6|7|8)
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
            
            read -p "Digite o diretório de origem: " source
            read -p "Digite o diretório de destino: " destination
            
            case $option in
                5)
                    sync_remote "$source" "$destination" "$user" "$host" "$port" "-av --progress"
                    ;;
                6)
                    sync_remote "$source" "$destination" "$user" "$host" "$port" "-avz --progress"
                    ;;
                7)
                    read -p "Digite o padrão de exclusão (ex: *.tmp): " exclude
                    sync_remote "$source" "$destination" "$user" "$host" "$port" "-av --progress --exclude='$exclude'"
                    ;;
                8)
                    sync_remote "$source" "$destination" "$user" "$host" "$port" "-av --progress --perms --owner --group"
                    ;;
            esac
            ;;
            
        9|10)
            read -p "Digite o diretório de origem: " source
            read -p "Digite o diretório de destino: " destination
            
            timestamp=$(date +%Y%m%d_%H%M%S)
            backup_dest="$destination/backup_$timestamp"
            
            case $option in
                9)
                    create_backup "$source" "$backup_dest" "-av --progress"
                    ;;
                10)
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
                    
                    sync_remote "$source" "$backup_dest" "$user" "$host" "$port" "-av --progress"
                    ;;
            esac
            ;;
            
        11)
            read -p "Digite o diretório de origem: " source
            read -p "Digite o diretório de destino: " destination
            read -p "Digite o limite de banda em KB/s: " bandwidth
            
            sync_local "$source" "$destination" "-av --progress --bwlimit=$bandwidth"
            ;;
            
        12)
            read -p "Digite o diretório de origem: " source
            read -p "Digite o diretório de destino: " destination
            
            sync_local "$source" "$destination" "-av --progress --retries=3 --timeout=60"
            ;;
            
        13)
            read -p "Digite o diretório de origem: " source
            read -p "Digite o diretório de destino: " destination
            
            sync_local "$source" "$destination" "-av --progress --checksum"
            ;;
            
        14)
            read -p "Digite o diretório de origem: " source
            read -p "Digite o diretório de destino: " destination
            read -p "Digite o caminho do arquivo de log: " log_file
            
            sync_local "$source" "$destination" "-av --progress --log-file=$log_file"
            ;;
            
        15)
            read -p "Digite o diretório de origem: " source
            read -p "Digite o diretório de destino: " destination
            
            sync_local "$source" "$destination" "-av --progress --exclude='*.tmp' --exclude='*.temp' --exclude='*.swp' --exclude='*~'"
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