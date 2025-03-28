#!/bin/bash

# ==============================================
# Vim Config - Arquivo Principal
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

# Criar diretório de configuração
mkdir -p ~/.vim/config
check_status "criar diretório de configuração"

# Carregar arquivos de configuração
source vim_config_general.sh
source vim_config_indent.sh
source vim_config_search.sh
source vim_config_backup.sh
source vim_config_plugins.sh

# Executar funções de configuração
create_general_config
create_indent_config
create_search_config
create_backup_config
create_plugin_config

# Criar arquivo .vimrc principal
echo_color "blue" "📝 Criando arquivo .vimrc principal..."
cat > ~/.vimrc << 'EOL'
" ==============================================
" Vim Config - Arquivo Principal
" ==============================================

" Carregar configurações
source ~/.vim/config/general.vim
source ~/.vim/config/indent.vim
source ~/.vim/config/search.vim
source ~/.vim/config/backup.vim
source ~/.vim/config/plugins.vim
EOL

check_status "criar arquivo .vimrc principal"

echo_color "GREEN" "✨ Configuração do Vim concluída com sucesso!" 