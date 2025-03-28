#!/bin/bash

# ==============================================
# SSH Tools Menu
# ==============================================
# Ferramentas úteis para administração SSH
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
    local packages=("openssh-client" "sshpass" "expect" "nmap" "netcat-openbsd" "netcat-traditional")
    
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

# Função para testar conexão SSH
test_ssh_connection() {
    local host=$1
    local port=$2
    local user=$3
    local password=$4
    
    echo_color "blue" "🔍 Testando conexão SSH..."
    echo_color "cyan" "🎯 Host: $host"
    echo_color "cyan" "🔑 Usuário: $user"
    echo ""
    
    if [ ! -z "$password" ]; then
        sshpass -p "$password" ssh -p "$port" -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$user@$host" "echo 'Conexão bem sucedida!'"
    else
        ssh -p "$port" -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$user@$host" "echo 'Conexão bem sucedida!'"
    fi
    
    if [ $? -eq 0 ]; then
        echo_color "green" "✅ Conexão SSH estabelecida com sucesso!"
    else
        echo_color "red" "❌ Falha na conexão SSH!"
    fi
}

# Função para testar credenciais SSH
test_ssh_credentials() {
    local host=$1
    local port=$2
    local user=$3
    local password=$4
    
    echo_color "blue" "🔍 Testando credenciais SSH..."
    echo_color "cyan" "🎯 Host: $host"
    echo_color "cyan" "🔑 Usuário: $user"
    echo ""
    
    if [ ! -z "$password" ]; then
        sshpass -p "$password" ssh -p "$port" -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$user@$host" "exit"
        if [ $? -eq 0 ]; then
            echo_color "green" "✅ Credenciais válidas!"
        else
            echo_color "red" "❌ Credenciais inválidas!"
        fi
    else
        echo_color "yellow" "⚠️ Nenhuma senha fornecida para teste"
    fi
}

# Função para gerar chave SSH
generate_ssh_key() {
    local type=$1
    local bits=$2
    local comment=$3
    
    echo_color "blue" "🔑 Gerando chave SSH..."
    echo_color "cyan" "📝 Tipo: $type"
    echo_color "cyan" "🔢 Bits: $bits"
    echo_color "cyan" "💬 Comentário: $comment"
    echo ""
    
    ssh-keygen -t "$type" -b "$bits" -C "$comment" -f ~/.ssh/id_"$type"_"$bits"
    check_status "gerar chave SSH"
}

# Função para copiar chave SSH
copy_ssh_key() {
    local host=$1
    local port=$2
    local user=$3
    local password=$4
    
    echo_color "blue" "📤 Copiando chave SSH..."
    echo_color "cyan" "🎯 Host: $host"
    echo_color "cyan" "🔑 Usuário: $user"
    echo ""
    
    if [ ! -z "$password" ]; then
        sshpass -p "$password" ssh-copy-id -p "$port" "$user@$host"
    else
        ssh-copy-id -p "$port" "$user@$host"
    fi
    
    check_status "copiar chave SSH"
}

# Função para executar comando remoto
execute_remote_command() {
    local host=$1
    local port=$2
    local user=$3
    local password=$4
    local command=$5
    
    echo_color "blue" "⚙️ Executando comando remoto..."
    echo_color "cyan" "🎯 Host: $host"
    echo_color "cyan" "🔑 Usuário: $user"
    echo_color "yellow" "📝 Comando: $command"
    echo ""
    
    if [ ! -z "$password" ]; then
        sshpass -p "$password" ssh -p "$port" "$user@$host" "$command"
    else
        ssh -p "$port" "$user@$host" "$command"
    fi
    
    check_status "executar comando remoto"
}

# Função para criar túnel SSH
create_ssh_tunnel() {
    local host=$1
    local port=$2
    local user=$3
    local password=$4
    local local_port=$5
    local remote_port=$6
    
    echo_color "blue" "🔄 Criando túnel SSH..."
    echo_color "cyan" "🎯 Host: $host"
    echo_color "cyan" "🔑 Usuário: $user"
    echo_color "yellow" "📊 Porta Local: $local_port"
    echo_color "yellow" "📊 Porta Remota: $remote_port"
    echo ""
    
    if [ ! -z "$password" ]; then
        sshpass -p "$password" ssh -p "$port" -L "$local_port":localhost:"$remote_port" "$user@$host"
    else
        ssh -p "$port" -L "$local_port":localhost:"$remote_port" "$user@$host"
    fi
}

# Função para transferir arquivo
transfer_file() {
    local mode=$1
    local source=$2
    local destination=$3
    local user=$4
    local host=$5
    local port=$6
    local password=$7
    
    echo_color "blue" "🔄 Iniciando transferência..."
    echo_color "cyan" "📤 Origem: $source"
    echo_color "cyan" "📥 Destino: $destination"
    echo ""
    
    if [ "$mode" = "send" ]; then
        if [ ! -f "$source" ] && [ ! -d "$source" ]; then
            echo_color "red" "❌ Arquivo ou diretório não encontrado!"
            return 1
        fi
        
        echo_color "cyan" "📊 Tamanho: $(du -sh "$source" | cut -f1)"
    fi
    
    if [ ! -z "$password" ]; then
        if [ "$mode" = "send" ]; then
            if [ -d "$source" ]; then
                sshpass -p "$password" scp -P "$port" -r "$source" "$user@$host:$destination"
            else
                sshpass -p "$password" scp -P "$port" "$source" "$user@$host:$destination"
            fi
        else
            sshpass -p "$password" scp -P "$port" "$user@$host:$source" "$destination"
        fi
    else
        if [ "$mode" = "send" ]; then
            if [ -d "$source" ]; then
                scp -P "$port" -r "$source" "$user@$host:$destination"
            else
                scp -P "$port" "$source" "$user@$host:$destination"
            fi
        else
            scp -P "$port" "$user@$host:$source" "$destination"
        fi
    fi
    
    check_status "transferir arquivo"
}

# Banner
echo_color "magenta" "=============================================="
echo_color "yellow" "🔑 SSH Tools Menu - Versão 1.0 🔑"
echo_color "magenta" "=============================================="
echo_color "cyan" "Ferramentas úteis para administração SSH"
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
    echo_color "cyan" "📋 Menu SSH Tools:"
    echo "1) Testar Conexão SSH"
    echo "2) Testar Credenciais SSH"
    echo "3) Gerar Chave SSH"
    echo "4) Copiar Chave SSH"
    echo "5) Executar Comando Remoto"
    echo "6) Criar Túnel SSH"
    echo "7) Enviar Arquivo/Diretório"
    echo "8) Receber Arquivo/Diretório"
    echo "9) Scan de Portas SSH"
    echo "10) Teste de Performance SSH"
    echo "11) Backup Remoto"
    echo "12) Monitoramento de Conexão"
    echo "13) Configuração de Host SSH"
    echo "14) Limpeza de Chaves SSH"
    echo "15) Teste de Banda SSH"
    echo "0) Sair"
    echo ""
    
    read -p "Escolha uma opção (0-15): " option
    echo ""
    
    case $option in
        1|2|5|6|7|8|9|10|11|12|13|14|15)
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
            
            read -p "Digite o usuário SSH: " user
            read -p "Digite a senha SSH (opcional): " password
            
            case $option in
                1)
                    test_ssh_connection "$host" "$port" "$user" "$password"
                    ;;
                2)
                    test_ssh_credentials "$host" "$port" "$user" "$password"
                    ;;
                5)
                    read -p "Digite o comando a executar: " command
                    execute_remote_command "$host" "$port" "$user" "$password" "$command"
                    ;;
                6)
                    read -p "Digite a porta local para o túnel: " local_port
                    read -p "Digite a porta remota para o túnel: " remote_port
                    create_ssh_tunnel "$host" "$port" "$user" "$password" "$local_port" "$remote_port"
                    ;;
                7|8)
                    case $option in
                        7)
                            read -p "Digite o caminho do arquivo/diretório local: " source
                            read -p "Digite o caminho de destino no servidor: " destination
                            transfer_file "send" "$source" "$destination" "$user" "$host" "$port" "$password"
                            ;;
                        8)
                            read -p "Digite o caminho do arquivo/diretório no servidor: " source
                            read -p "Digite o caminho de destino local: " destination
                            transfer_file "receive" "$source" "$destination" "$user" "$host" "$port" "$password"
                            ;;
                    esac
                    ;;
                9)
                    echo_color "blue" "🔍 Iniciando scan de portas SSH..."
                    nmap -p "$port" -sV "$host"
                    ;;
                10)
                    echo_color "blue" "⚡ Testando performance SSH..."
                    time ssh -p "$port" "$user@$host" "echo 'Teste de performance'"
                    ;;
                11)
                    read -p "Digite o diretório para backup: " backup_dir
                    echo_color "blue" "💾 Iniciando backup remoto..."
                    if [ ! -z "$password" ]; then
                        sshpass -p "$password" ssh -p "$port" "$user@$host" "tar czf - $backup_dir" > "backup_$(date +%Y%m%d_%H%M%S).tar.gz"
                    else
                        ssh -p "$port" "$user@$host" "tar czf - $backup_dir" > "backup_$(date +%Y%m%d_%H%M%S).tar.gz"
                    fi
                    check_status "realizar backup"
                    ;;
                12)
                    echo_color "blue" "📊 Monitorando conexão SSH..."
                    while true; do
                        if ping -c 1 "$host" &> /dev/null; then
                            echo_color "green" "✅ Conexão ativa - $(date)"
                        else
                            echo_color "red" "❌ Conexão perdida - $(date)"
                        fi
                        sleep 5
                    done
                    ;;
                13)
                    echo_color "blue" "⚙️ Configurando host SSH..."
                    echo "Host $host" >> ~/.ssh/config
                    echo "    HostName $host" >> ~/.ssh/config
                    echo "    User $user" >> ~/.ssh/config
                    echo "    Port $port" >> ~/.ssh/config
                    check_status "configurar host SSH"
                    ;;
                14)
                    echo_color "blue" "🧹 Limpando chaves SSH..."
                    rm -f ~/.ssh/known_hosts
                    check_status "limpar chaves SSH"
                    ;;
                15)
                    echo_color "blue" "📊 Testando banda SSH..."
                    if [ ! -z "$password" ]; then
                        sshpass -p "$password" ssh -p "$port" "$user@$host" "dd if=/dev/zero bs=1M count=100" | pv > /dev/null
                    else
                        ssh -p "$port" "$user@$host" "dd if=/dev/zero bs=1M count=100" | pv > /dev/null
                    fi
                    ;;
            esac
            ;;
            
        3)
            echo_color "blue" "🔑 Gerando nova chave SSH..."
            read -p "Digite o tipo de chave (rsa/ed25519): " key_type
            read -p "Digite o número de bits (2048/4096): " key_bits
            read -p "Digite um comentário para a chave: " key_comment
            generate_ssh_key "$key_type" "$key_bits" "$key_comment"
            ;;
            
        4)
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
            
            read -p "Digite o usuário SSH: " user
            read -p "Digite a senha SSH: " password
            copy_ssh_key "$host" "$port" "$user" "$password"
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
