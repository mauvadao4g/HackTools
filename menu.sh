#!/bin/bash

# ==============================================
# Menu Principal - Ferramentas de Desenvolvimento
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

# Função para listar scripts em um diretório
list_scripts() {
    local dir=$1
    local prefix=$2
    local scripts=()
    local i=1

    # Verifica se o diretório existe
    if [ ! -d "$dir" ]; then
        echo_color "RED" "Diretório $dir não encontrado!"
        return 1
    fi

    # Lista todos os scripts .sh no diretório
    for script in "$dir"/*.sh; do
        if [ -f "$script" ]; then
            scripts+=("$script")
            echo_color "YELLOW" "$prefix$i. $(basename "$script")"
            ((i++))
        fi
    done

    # Se não houver scripts, mostra mensagem
    if [ ${#scripts[@]} -eq 0 ]; then
        echo_color "RED" "Nenhum script encontrado em $dir"
        return 1
    fi

    # Adiciona opção para voltar
    echo_color "YELLOW" "$prefix$i. Voltar ao Menu Principal"
    echo
    echo_color "BLUE" "Escolha uma opção: "

    # Retorna o número total de scripts (sem contar a opção de voltar)
    echo "$((i-1))" > /dev/null
    return 0
}

# Função para executar um script
execute_script() {
    local script=$1
    echo_color "BLUE" "Executando $script..."
    if [ -f "$script" ]; then
        sudo "$script"
    else
        echo_color "RED" "Script não encontrado: $script"
    fi
    read -p "Pressione ENTER para continuar..."
}

# Função para mostrar o banner
show_banner() {
    clear
    echo_color "BLUE" "=============================================="
    echo_color "BLUE" "     Ferramentas de Desenvolvimento"
    echo_color "BLUE" "=============================================="
    echo
}

# Função para mostrar o menu principal
show_menu() {
    echo_color "YELLOW" "1. Scripts do Vim/Neovim"
    echo_color "YELLOW" "2. Scripts de Hacking"
    echo_color "YELLOW" "3. Sair"
    echo
    echo_color "BLUE" "Escolha uma opção: "
}

# Loop principal do menu
while true; do
    show_banner
    show_menu
    read -r option

    case $option in
        1)
            while true; do
                clear
                echo_color "BLUE" "=============================================="
                echo_color "BLUE" "     Scripts do Vim/Neovim"
                echo_color "BLUE" "=============================================="
                echo
                
                # Lista scripts do Vim/Neovim
                if list_scripts "vim_nvim_install" ""; then
                    read -r vim_option
                    
                    # Verifica se a opção é válida
                    if [[ "$vim_option" =~ ^[0-9]+$ ]]; then
                        num_scripts=$(ls vim_nvim_install/*.sh 2>/dev/null | wc -l)
                        if [ "$vim_option" -eq "$((num_scripts + 1))" ]; then
                            break
                        elif [ "$vim_option" -le "$num_scripts" ]; then
                            # Executa o script selecionado
                            script_path=$(ls vim_nvim_install/*.sh | sed -n "${vim_option}p")
                            execute_script "$script_path"
                        else
                            echo_color "RED" "Opção inválida!"
                            read -p "Pressione ENTER para continuar..."
                        fi
                    else
                        echo_color "RED" "Opção inválida!"
                        read -p "Pressione ENTER para continuar..."
                    fi
                else
                    read -p "Pressione ENTER para continuar..."
                fi
            done
            ;;
        2)
            while true; do
                clear
                echo_color "BLUE" "=============================================="
                echo_color "BLUE" "     Scripts de Hacking"
                echo_color "BLUE" "=============================================="
                echo
                
                # Lista scripts de Hacking
                if list_scripts "hack_tools" ""; then
                    read -r hack_option
                    
                    # Verifica se a opção é válida
                    if [[ "$hack_option" =~ ^[0-9]+$ ]]; then
                        num_scripts=$(ls hack_tools/*.sh 2>/dev/null | wc -l)
                        if [ "$hack_option" -eq "$((num_scripts + 1))" ]; then
                            break
                        elif [ "$hack_option" -le "$num_scripts" ]; then
                            # Executa o script selecionado
                            script_path=$(ls hack_tools/*.sh | sed -n "${hack_option}p")
                            execute_script "$script_path"
                        else
                            echo_color "RED" "Opção inválida!"
                            read -p "Pressione ENTER para continuar..."
                        fi
                    else
                        echo_color "RED" "Opção inválida!"
                        read -p "Pressione ENTER para continuar..."
                    fi
                else
                    read -p "Pressione ENTER para continuar..."
                fi
            done
            ;;
        3)
            echo_color "GREEN" "Saindo..."
            exit 0
            ;;
        *)
            echo_color "RED" "Opção inválida!"
            read -p "Pressione ENTER para continuar..."
            ;;
    esac
done 