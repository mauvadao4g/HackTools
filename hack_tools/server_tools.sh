#!/bin/bash

# ==============================================
# Server Tools Menu
# ==============================================
# Script para instalação e configuração de servidores
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

# Função para atualizar o sistema
update_system() {
    echo_color "yellow" "🔄 Atualizando o sistema..."
    apt-get update -y
    check_status "atualizar repositórios"
    
    apt-get upgrade -y
    check_status "atualizar pacotes"
}

# Função para instalar e configurar servidor SSH
setup_ssh_server() {
    echo_color "blue" "🔒 Configurando servidor SSH..."
    
    # Instalar OpenSSH Server
    apt-get install -y openssh-server
    check_status "instalar OpenSSH Server"
    
    # Configurar SSH
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    
    # Configurações de segurança
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/#X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config
    
    # Reiniciar serviço SSH
    systemctl restart ssh
    check_status "reiniciar serviço SSH"
    
    echo_color "green" "✅ Servidor SSH configurado com sucesso!"
}

# Função para instalar e configurar servidor FTP
setup_ftp_server() {
    echo_color "blue" "📁 Configurando servidor FTP..."
    
    # Instalar vsftpd
    apt-get install -y vsftpd
    check_status "instalar vsftpd"
    
    # Backup da configuração
    cp /etc/vsftpd.conf /etc/vsftpd.conf.backup
    
    # Configurar vsftpd
    cat > /etc/vsftpd.conf << 'EOL'
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO
EOL
    
    # Criar diretório para usuários FTP
    mkdir -p /home/ftp
    chown root:root /home/ftp
    chmod 755 /home/ftp
    
    # Reiniciar serviço FTP
    systemctl restart vsftpd
    check_status "reiniciar serviço FTP"
    
    echo_color "green" "✅ Servidor FTP configurado com sucesso!"
}

# Função para instalar e configurar servidor Web (Apache + PHP + MySQL)
setup_web_server() {
    echo_color "blue" "🌐 Configurando servidor Web..."
    
    # Instalar Apache, PHP e MySQL
    apt-get install -y apache2 php php-mysql mysql-server
    check_status "instalar Apache, PHP e MySQL"
    
    # Configurar Apache
    a2enmod rewrite
    systemctl restart apache2
    check_status "configurar Apache"
    
    # Configurar PHP
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/' /etc/php/*/apache2/php.ini
    sed -i 's/post_max_size = 8M/post_max_size = 64M/' /etc/php/*/apache2/php.ini
    sed -i 's/memory_limit = 128M/memory_limit = 256M/' /etc/php/*/apache2/php.ini
    
    # Configurar MySQL
    mysql_secure_installation << EOF
y
root_password
root_password
y
y
y
y
EOF
    
    # Criar diretório para sites
    mkdir -p /var/www/html
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
    
    # Criar página de teste
    cat > /var/www/html/index.php << 'EOL'
<?php
phpinfo();
?>
EOL
    
    systemctl restart apache2
    check_status "reiniciar Apache"
    
    echo_color "green" "✅ Servidor Web configurado com sucesso!"
}

# Função para instalar e configurar servidor de Email (Postfix + Dovecot)
setup_email_server() {
    echo_color "blue" "📧 Configurando servidor de Email..."
    
    # Instalar Postfix e Dovecot
    apt-get install -y postfix dovecot-imapd dovecot-pop3d
    check_status "instalar Postfix e Dovecot"
    
    # Configurar Postfix
    cat > /etc/postfix/main.cf << 'EOL'
myhostname = mail.example.com
mydomain = example.com
myorigin = $mydomain
inet_interfaces = all
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
mynetworks = 127.0.0.0/8
home_mailbox = Maildir/
mailbox_command =
smtpd_banner = $myhostname ESMTP $mail_name
EOL
    
    # Configurar Dovecot
    cat > /etc/dovecot/conf.d/10-mail.conf << 'EOL'
mail_location = maildir:~/Maildir
EOL
    
    # Criar diretórios de email
    mkdir -p /var/mail/vhosts
    chown -R vmail:vmail /var/mail
    
    # Reiniciar serviços
    systemctl restart postfix
    systemctl restart dovecot
    check_status "reiniciar serviços de email"
    
    echo_color "green" "✅ Servidor de Email configurado com sucesso!"
}

# Função para configurar firewall
setup_firewall() {
    echo_color "blue" "🛡️ Configurando firewall..."
    
    # Instalar UFW
    apt-get install -y ufw
    check_status "instalar UFW"
    
    # Configurar regras básicas
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow http
    ufw allow https
    ufw allow ftp
    ufw allow 25/tcp
    ufw allow 110/tcp
    ufw allow 143/tcp
    ufw allow 993/tcp
    ufw allow 995/tcp
    
    # Habilitar firewall
    ufw --force enable
    check_status "habilitar firewall"
    
    echo_color "green" "✅ Firewall configurado com sucesso!"
}

# Banner
echo_color "magenta" "=============================================="
echo_color "yellow" "🖥️  Server Tools Menu - Versão 1.0 🖥️"
echo_color "magenta" "=============================================="
echo_color "cyan" "Script para instalação e configuração de servidores"
echo_color "magenta" "=============================================="
echo ""

# Verificar permissões de root
if [ "$EUID" -ne 0 ]; then 
    echo_color "red" "❌ Este script precisa ser executado como root (sudo)"
    exit 1
fi

# Menu principal
while true; do
    echo_color "cyan" "📋 Menu de Servidores:"
    echo "1) Atualizar Sistema"
    echo "2) Instalar e Configurar Servidor SSH"
    echo "3) Instalar e Configurar Servidor FTP"
    echo "4) Instalar e Configurar Servidor Web"
    echo "5) Instalar e Configurar Servidor de Email"
    echo "6) Configurar Firewall"
    echo "7) Instalar e Configurar Todos os Servidores"
    echo "0) Sair"
    echo ""
    
    read -p "Escolha uma opção (0-7): " option
    echo ""
    
    case $option in
        1)
            update_system
            ;;
            
        2)
            setup_ssh_server
            ;;
            
        3)
            setup_ftp_server
            ;;
            
        4)
            setup_web_server
            ;;
            
        5)
            setup_email_server
            ;;
            
        6)
            setup_firewall
            ;;
            
        7)
            update_system
            setup_ssh_server
            setup_ftp_server
            setup_web_server
            setup_email_server
            setup_firewall
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