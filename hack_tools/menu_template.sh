#!/bin/bash

# ==============================================
# Template de Menu Interativo com Cores
# ==============================================
# Este template inclui:
# - Sistema de cores para mensagens
# - Verificação de dependências
# - Menu interativo
# - Funções reutilizáveis
# - Tratamento de erros
# ==============================================

# Função para exibir mensagens coloridas
# Cores disponíveis: red, green, yellow, blue, magenta, cyan
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
# Exemplo: check_dependency "nome_do_pacote" "comando_para_verificar"
check_dependency() {
    local package=$1
    local command=$2
    
    if ! command -v $command &> /dev/null; then
        echo_color "yellow" "🔄 $package não encontrado. Instalando..."
        apt-get update -y
        apt-get install -y $package
        check_status "instalar $package"
    else
        echo_color "green" "✅ $package já está instalado"
    fi
}

# Função para executar ações
# Exemplo: perform_action "Descrição" "comando"
perform_action() {
    local description=$1
    local command=$2
    
    echo_color "blue" "🔍 Iniciando: $description"
    echo_color "cyan" "⚙️ Comando: $command"
    echo ""
    
    eval $command
    echo ""
    echo_color "green" "✅ Ação concluída!"
}

# Banner do programa
echo_color "magenta" "==============================="
echo_color "yellow" "🔧 Nome do Seu Programa 🔧"
echo_color "magenta" "==============================="
echo ""

# Verificar permissões de root (descomente se necessário)
# if [ "$EUID" -ne 0 ]; then 
#     echo_color "red" "❌ Este script precisa ser executado como root (sudo)"
#     exit 1
# fi

# Verificar dependências necessárias
# check_dependency "nome_do_pacote" "comando"

# Menu principal
while true; do
    echo_color "cyan" "📋 Menu Principal:"
    echo "1) Opção 1"
    echo "2) Opção 2"
    echo "3) Opção 3"
    echo "4) Opção 4"
    echo "5) Opção 5"
    echo "6) Opção 6"
    echo "7) Opção 7"
    echo "8) Opção 8"
    echo "9) Opção 9"
    echo "0) Sair"
    echo ""
    
    read -p "Escolha uma opção (0-9): " option
    echo ""
    
    case $option in
        1)
            read -p "Digite o parâmetro necessário: " param1
            perform_action "Descrição da Opção 1" "comando1 $param1"
            ;;
        2)
            read -p "Digite o parâmetro necessário: " param2
            perform_action "Descrição da Opção 2" "comando2 $param2"
            ;;
        3)
            read -p "Digite o parâmetro necessário: " param3
            perform_action "Descrição da Opção 3" "comando3 $param3"
            ;;
        4)
            read -p "Digite o parâmetro necessário: " param4
            perform_action "Descrição da Opção 4" "comando4 $param4"
            ;;
        5)
            read -p "Digite o parâmetro necessário: " param5
            perform_action "Descrição da Opção 5" "comando5 $param5"
            ;;
        6)
            read -p "Digite o parâmetro necessário: " param6
            perform_action "Descrição da Opção 6" "comando6 $param6"
            ;;
        7)
            read -p "Digite o parâmetro necessário: " param7
            perform_action "Descrição da Opção 7" "comando7 $param7"
            ;;
        8)
            read -p "Digite o parâmetro necessário: " param8
            perform_action "Descrição da Opção 8" "comando8 $param8"
            ;;
        9)
            read -p "Digite o parâmetro necessário: " param9
            perform_action "Descrição da Opção 9" "comando9 $param9"
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

# ==============================================
# Instruções de Uso:
# 1. Renomeie o arquivo para o nome desejado
# 2. Modifique o banner com o nome do seu programa
# 3. Adicione as dependências necessárias usando check_dependency
# 4. Personalize as opções do menu
# 5. Implemente as ações específicas em cada case
# 6. Adicione ou remova opções conforme necessário
# 7. Ajuste as mensagens e cores conforme sua preferência
# ============================================== 