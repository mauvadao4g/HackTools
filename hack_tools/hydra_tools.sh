#!/bin/bash

# ==============================================
# Hydra Tools Menu
# ==============================================
# Ferramentas para teste de força bruta
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

# Função para verificar e instalar hydra
check_hydra() {
    if ! command -v hydra &> /dev/null; then
        echo_color "yellow" "🔄 Instalando hydra..."
        apt-get update -y
        apt-get install -y hydra
        check_status "instalar hydra"
    else
        echo_color "green" "✅ hydra já está instalado"
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

# Função para verificar arquivo de wordlist
check_wordlist() {
    local wordlist=$1
    if [ ! -f "$wordlist" ]; then
        echo_color "red" "❌ Wordlist não encontrada!"
        return 1
    fi
    echo_color "green" "✅ Wordlist encontrada: $(wc -l < "$wordlist") linhas"
    return 0
}

# Função para teste de força bruta
brute_force() {
    local service=$1
    local target=$2
    local port=$3
    local user=$4
    local wordlist=$5
    local options=$6
    
    echo_color "blue" "🔍 Iniciando teste de força bruta..."
    echo_color "cyan" "🎯 Serviço: $service"
    echo_color "cyan" "🎯 Alvo: $target"
    echo_color "cyan" "🔢 Porta: $port"
    echo_color "cyan" "👤 Usuário: $user"
    echo_color "yellow" "📚 Wordlist: $wordlist"
    echo_color "yellow" "⚙️ Opções: $options"
    echo ""
    
    hydra -l "$user" -P "$wordlist" $options "$target" "$service"
    check_status "realizar teste de força bruta"
}

# Função para teste de força bruta com lista de usuários
brute_force_userlist() {
    local service=$1
    local target=$2
    local port=$3
    local userlist=$4
    local passlist=$5
    local options=$6
    
    echo_color "blue" "🔍 Iniciando teste de força bruta com lista de usuários..."
    echo_color "cyan" "🎯 Serviço: $service"
    echo_color "cyan" "🎯 Alvo: $target"
    echo_color "cyan" "🔢 Porta: $port"
    echo_color "cyan" "👥 Lista de Usuários: $userlist"
    echo_color "cyan" "🔑 Lista de Senhas: $passlist"
    echo_color "yellow" "⚙️ Opções: $options"
    echo ""
    
    hydra -L "$userlist" -P "$passlist" $options "$target" "$service"
    check_status "realizar teste de força bruta"
}

# Banner
echo_color "magenta" "=============================================="
echo_color "yellow" "🔑 Hydra Tools Menu - Versão 1.0 🔑"
echo_color "magenta" "=============================================="
echo_color "cyan" "Ferramentas para teste de força bruta"
echo_color "magenta" "=============================================="
echo ""

# Verificar permissões de root
if [ "$EUID" -ne 0 ]; then 
    echo_color "red" "❌ Este script precisa ser executado como root (sudo)"
    exit 1
fi

# Verificar e instalar hydra
check_hydra

# Menu principal
while true; do
    echo_color "cyan" "📋 Menu Hydra:"
    echo "1) Teste SSH (Senha)"
    echo "2) Teste SSH (Lista de Usuários)"
    echo "3) Teste FTP"
    echo "4) Teste HTTP Basic Auth"
    echo "5) Teste MySQL"
    echo "6) Teste PostgreSQL"
    echo "7) Teste SMB"
    echo "8) Teste RDP"
    echo "9) Teste Telnet"
    echo "10) Teste POP3"
    echo "11) Teste SMTP"
    echo "12) Teste IMAP"
    echo "13) Teste VNC"
    echo "14) Teste com Timeout Personalizado"
    echo "15) Teste com Threads Personalizadas"
    echo "0) Sair"
    echo ""
    
    read -p "Escolha uma opção (0-15): " option
    echo ""
    
    case $option in
        1|2|3|4|5|6|7|8|9|10|11|12|13)
            read -p "Digite o IP ou domínio alvo: " target
            if ! validate_ip "$target" && ! host "$target" &> /dev/null; then
                echo_color "red" "❌ IP ou domínio inválido!"
                continue
            fi
            
            read -p "Digite a porta (pressione ENTER para padrão do serviço): " port
            if [ ! -z "$port" ] && ! validate_port "$port"; then
                echo_color "red" "❌ Porta inválida!"
                continue
            fi
            
            read -p "Digite o caminho da wordlist: " wordlist
            if ! check_wordlist "$wordlist"; then
                continue
            fi
            
            case $option in
                1)
                    read -p "Digite o usuário: " user
                    brute_force "ssh" "$target" "$port" "$user" "$wordlist" "-t 4 -V"
                    ;;
                2)
                    read -p "Digite o caminho da lista de usuários: " userlist
                    if ! check_wordlist "$userlist"; then
                        continue
                    fi
                    brute_force_userlist "ssh" "$target" "$port" "$userlist" "$wordlist" "-t 4 -V"
                    ;;
                3)
                    read -p "Digite o usuário: " user
                    brute_force "ftp" "$target" "$port" "$user" "$wordlist" "-V"
                    ;;
                4)
                    read -p "Digite o usuário: " user
                    brute_force "http-get" "$target" "$port" "$user" "$wordlist" "-V"
                    ;;
                5)
                    read -p "Digite o usuário: " user
                    brute_force "mysql" "$target" "$port" "$user" "$wordlist" "-V"
                    ;;
                6)
                    read -p "Digite o usuário: " user
                    brute_force "postgresql" "$target" "$port" "$user" "$wordlist" "-V"
                    ;;
                7)
                    read -p "Digite o usuário: " user
                    brute_force "smb" "$target" "$port" "$user" "$wordlist" "-V"
                    ;;
                8)
                    read -p "Digite o usuário: " user
                    brute_force "rdp" "$target" "$port" "$user" "$wordlist" "-V"
                    ;;
                9)
                    read -p "Digite o usuário: " user
                    brute_force "telnet" "$target" "$port" "$user" "$wordlist" "-V"
                    ;;
                10)
                    read -p "Digite o usuário: " user
                    brute_force "pop3" "$target" "$port" "$user" "$wordlist" "-V"
                    ;;
                11)
                    read -p "Digite o usuário: " user
                    brute_force "smtp" "$target" "$port" "$user" "$wordlist" "-V"
                    ;;
                12)
                    read -p "Digite o usuário: " user
                    brute_force "imap" "$target" "$port" "$user" "$wordlist" "-V"
                    ;;
                13)
                    read -p "Digite o usuário: " user
                    brute_force "vnc" "$target" "$port" "$user" "$wordlist" "-V"
                    ;;
            esac
            ;;
            
        14)
            read -p "Digite o IP ou domínio alvo: " target
            if ! validate_ip "$target" && ! host "$target" &> /dev/null; then
                echo_color "red" "❌ IP ou domínio inválido!"
                continue
            fi
            
            read -p "Digite o serviço: " service
            read -p "Digite a porta: " port
            if ! validate_port "$port"; then
                echo_color "red" "❌ Porta inválida!"
                continue
            fi
            
            read -p "Digite o usuário: " user
            read -p "Digite o caminho da wordlist: " wordlist
            if ! check_wordlist "$wordlist"; then
                continue
            fi
            
            read -p "Digite o timeout em segundos: " timeout
            brute_force "$service" "$target" "$port" "$user" "$wordlist" "-w $timeout -V"
            ;;
            
        15)
            read -p "Digite o IP ou domínio alvo: " target
            if ! validate_ip "$target" && ! host "$target" &> /dev/null; then
                echo_color "red" "❌ IP ou domínio inválido!"
                continue
            fi
            
            read -p "Digite o serviço: " service
            read -p "Digite a porta: " port
            if ! validate_port "$port"; then
                echo_color "red" "❌ Porta inválida!"
                continue
            fi
            
            read -p "Digite o usuário: " user
            read -p "Digite o caminho da wordlist: " wordlist
            if ! check_wordlist "$wordlist"; then
                continue
            fi
            
            read -p "Digite o número de threads: " threads
            brute_force "$service" "$target" "$port" "$user" "$wordlist" "-t $threads -V"
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