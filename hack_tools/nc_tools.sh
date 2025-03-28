#!/bin/bash

# ==============================================
# Netcat (nc) Menu Tool
# ==============================================
# Ferramenta para manipulação de conexões TCP/UDP
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

# Função para verificar e instalar netcat
check_nc() {
    if ! command -v nc &> /dev/null; then
        echo_color "yellow" "🔄 Netcat não encontrado. Instalando..."
        apt-get update -y
        apt-get install -y netcat
        check_status "instalar Netcat"
    else
        echo_color "green" "✅ Netcat já está instalado"
    fi
}

# Função para executar scan de portas
scan_ports() {
    local target=$1
    local start_port=$2
    local end_port=$3
    local scan_type=$4
    
    echo_color "blue" "🔍 Iniciando scan de portas..."
    echo_color "cyan" "🎯 Alvo: $target"
    echo_color "yellow" "📊 Range: $start_port-$end_port"
    echo_color "magenta" "🔧 Tipo: $scan_type"
    echo ""
    
    case $scan_type in
        "TCP")
            for port in $(seq $start_port $end_port); do
                if nc -zv -w1 $target $port 2>&1; then
                    echo_color "green" "✅ Porta TCP $port está aberta"
                    # Tentar identificar o serviço
                    service=$(nc -w1 $target $port 2>&1 | head -n 1)
                    if [ ! -z "$service" ]; then
                        echo_color "cyan" "   Serviço: $service"
                    fi
                fi
            done
            ;;
        "UDP")
            for port in $(seq $start_port $end_port); do
                if nc -zuv -w1 $target $port 2>&1; then
                    echo_color "green" "✅ Porta UDP $port está aberta"
                fi
            done
            ;;
        "Banner")
            for port in $(seq $start_port $end_port); do
                if nc -zv -w1 $target $port 2>&1; then
                    echo_color "green" "✅ Porta $port está aberta"
                    echo_color "yellow" "📝 Banner:"
                    nc -w2 $target $port 2>&1
                    echo ""
                fi
            done
            ;;
    esac
    echo ""
}

# Função para criar servidor TCP
create_tcp_server() {
    local port=$1
    local mode=$2
    
    echo_color "blue" "🔄 Iniciando servidor TCP na porta $port"
    echo_color "yellow" "⚠️ Pressione Ctrl+C para parar o servidor"
    echo ""
    
    case $mode in
        "basic")
            nc -l -p $port
            ;;
        "verbose")
            nc -l -v -p $port
            ;;
        "keepalive")
            while true; do
                nc -l -p $port
                echo_color "yellow" "🔄 Reconectando..."
                sleep 1
            done
            ;;
    esac
}

# Função para criar servidor UDP
create_udp_server() {
    local port=$1
    local mode=$2
    
    echo_color "blue" "🔄 Iniciando servidor UDP na porta $port"
    echo_color "yellow" "⚠️ Pressione Ctrl+C para parar o servidor"
    echo ""
    
    case $mode in
        "basic")
            nc -ul -p $port
            ;;
        "verbose")
            nc -ul -v -p $port
            ;;
        "keepalive")
            while true; do
                nc -ul -p $port
                echo_color "yellow" "🔄 Reconectando..."
                sleep 1
            done
            ;;
    esac
}

# Função para transferência de arquivos
transfer_file() {
    local mode=$1
    local file=$2
    local port=$3
    local target=$4
    
    if [ "$mode" = "send" ]; then
        if [ ! -f "$file" ]; then
            echo_color "red" "❌ Arquivo não encontrado!"
            return 1
        fi
        
        echo_color "blue" "📤 Enviando arquivo: $file"
        echo_color "yellow" "⚠️ Aguarde o receptor se conectar..."
        echo_color "cyan" "📊 Tamanho: $(du -h "$file" | cut -f1)"
        
        # Enviar com barra de progresso
        pv "$file" | nc -l -p $port
    else
        echo_color "blue" "📥 Recebendo arquivo: $file"
        echo_color "yellow" "⚠️ Conectando ao transmissor..."
        
        # Receber com barra de progresso
        nc -w 3 $target $port | pv > "$file"
    fi
}

# Função para chat
chat() {
    local port=$1
    local protocol=$2
    local mode=$3
    
    echo_color "blue" "💬 Iniciando chat $protocol na porta $port"
    echo_color "yellow" "⚠️ Pressione Ctrl+C para sair"
    echo ""
    
    case $mode in
        "basic")
            if [ "$protocol" = "TCP" ]; then
                nc -l -p $port
            else
                nc -ul -p $port
            fi
            ;;
        "encrypted")
            if [ "$protocol" = "TCP" ]; then
                nc -l -p $port | openssl enc -aes-256-cbc -pass pass:chat123
            else
                nc -ul -p $port | openssl enc -aes-256-cbc -pass pass:chat123
            fi
            ;;
    esac
}

# Banner
echo_color "magenta" "=============================================="
echo_color "yellow" "🔌 Netcat Menu Tool - Versão 2.0 🔌"
echo_color "magenta" "=============================================="
echo_color "cyan" "Ferramenta para manipulação de conexões TCP/UDP"
echo_color "magenta" "=============================================="
echo ""

# Verificar permissões de root
if [ "$EUID" -ne 0 ]; then 
    echo_color "red" "❌ Este script precisa ser executado como root (sudo)"
    exit 1
fi

# Verificar e instalar netcat
check_nc

# Menu principal
while true; do
    echo_color "cyan" "📋 Menu Netcat:"
    echo "1) Scan de Portas (TCP)"
    echo "2) Scan de Portas (UDP)"
    echo "3) Scan de Banner"
    echo "4) Criar Servidor TCP (Básico)"
    echo "5) Criar Servidor TCP (Verbose)"
    echo "6) Criar Servidor TCP (Keep-Alive)"
    echo "7) Criar Servidor UDP (Básico)"
    echo "8) Criar Servidor UDP (Verbose)"
    echo "9) Criar Servidor UDP (Keep-Alive)"
    echo "10) Enviar Arquivo"
    echo "11) Receber Arquivo"
    echo "12) Chat TCP (Básico)"
    echo "13) Chat TCP (Criptografado)"
    echo "14) Chat UDP (Básico)"
    echo "15) Chat UDP (Criptografado)"
    echo "16) Teste de Conexão"
    echo "17) Scan de Portas Comuns"
    echo "0) Sair"
    echo ""
    
    read -p "Escolha uma opção (0-17): " option
    echo ""
    
    case $option in
        1|2|3)
            read -p "Digite o IP ou domínio alvo: " target
            if ! validate_ip "$target" && ! host "$target" &> /dev/null; then
                echo_color "red" "❌ IP ou domínio inválido!"
                continue
            fi
            
            read -p "Porta inicial: " start_port
            if ! validate_port "$start_port"; then
                echo_color "red" "❌ Porta inicial inválida!"
                continue
            fi
            
            read -p "Porta final: " end_port
            if ! validate_port "$end_port" || [ "$end_port" -lt "$start_port" ]; then
                echo_color "red" "❌ Porta final inválida!"
                continue
            fi
            
            case $option in
                1) scan_type="TCP" ;;
                2) scan_type="UDP" ;;
                3) scan_type="Banner" ;;
            esac
            scan_ports "$target" "$start_port" "$end_port" "$scan_type"
            ;;
            
        4|5|6)
            read -p "Digite a porta para o servidor TCP: " port
            if ! validate_port "$port"; then
                echo_color "red" "❌ Porta inválida!"
                continue
            fi
            
            case $option in
                4) mode="basic" ;;
                5) mode="verbose" ;;
                6) mode="keepalive" ;;
            esac
            create_tcp_server "$port" "$mode"
            ;;
            
        7|8|9)
            read -p "Digite a porta para o servidor UDP: " port
            if ! validate_port "$port"; then
                echo_color "red" "❌ Porta inválida!"
                continue
            fi
            
            case $option in
                7) mode="basic" ;;
                8) mode="verbose" ;;
                9) mode="keepalive" ;;
            esac
            create_udp_server "$port" "$mode"
            ;;
            
        10|11)
            read -p "Digite o IP ou domínio: " target
            if ! validate_ip "$target" && ! host "$target" &> /dev/null; then
                echo_color "red" "❌ IP ou domínio inválido!"
                continue
            fi
            
            read -p "Digite a porta: " port
            if ! validate_port "$port"; then
                echo_color "red" "❌ Porta inválida!"
                continue
            fi
            
            read -p "Digite o caminho do arquivo: " file
            if [ "$option" = "10" ]; then
                transfer_file "send" "$file" "$port"
            else
                transfer_file "receive" "$file" "$port" "$target"
            fi
            ;;
            
        12|13|14|15)
            read -p "Digite a porta para o chat: " port
            if ! validate_port "$port"; then
                echo_color "red" "❌ Porta inválida!"
                continue
            fi
            
            case $option in
                12) protocol="TCP"; mode="basic" ;;
                13) protocol="TCP"; mode="encrypted" ;;
                14) protocol="UDP"; mode="basic" ;;
                15) protocol="UDP"; mode="encrypted" ;;
            esac
            chat "$port" "$protocol" "$mode"
            ;;
            
        16)
            read -p "Digite o IP ou domínio para testar: " target
            if ! validate_ip "$target" && ! host "$target" &> /dev/null; then
                echo_color "red" "❌ IP ou domínio inválido!"
                continue
            fi
            
            read -p "Digite a porta: " port
            if ! validate_port "$port"; then
                echo_color "red" "❌ Porta inválida!"
                continue
            fi
            
            echo_color "blue" "🔍 Testando conexão com $target:$port"
            if nc -zv -w3 $target $port; then
                echo_color "green" "✅ Conexão bem sucedida!"
                echo_color "yellow" "📝 Informações do serviço:"
                nc -w2 $target $port 2>&1
            else
                echo_color "red" "❌ Conexão falhou!"
            fi
            ;;
            
        17)
            read -p "Digite o IP ou domínio alvo: " target
            if ! validate_ip "$target" && ! host "$target" &> /dev/null; then
                echo_color "red" "❌ IP ou domínio inválido!"
                continue
            fi
            
            echo_color "blue" "🔍 Iniciando scan de portas comuns..."
            common_ports="20,21,22,23,25,53,80,110,143,443,3306,3389,8080"
            for port in ${common_ports//,/ }; do
                if nc -zv -w1 $target $port 2>&1; then
                    echo_color "green" "✅ Porta $port está aberta"
                    echo_color "yellow" "📝 Serviço:"
                    nc -w2 $target $port 2>&1
                    echo ""
                fi
            done
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