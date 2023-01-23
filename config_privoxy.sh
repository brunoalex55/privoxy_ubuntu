#!/bin/bash

# Atualizar o sistema
sudo apt-get update

# Habilita o ufw caso esteja inativo
sudo ufw status | grep inactive && sudo ufw enable

# Instala o privoxy
sudo apt-get install privoxy -y

# Instala socat
sudo apt-get install socat -y

# Comentando as linhas referentes ao listen-address no arquivo de configuração do privoxy
sudo sed -i 's/^listen-address/#listen-address/' /etc/privoxy/config

# Adicionando a permissão de acesso de qualquer IP no arquivo de configuração do privoxy
echo "permit-access 0.0.0.0/0" | sudo tee -a /etc/privoxy/config

# Adicionando listen-address para qualquer IP no arquivo de configuração do privoxy
echo "listen-address 0.0.0.0:9741" | sudo tee -a /etc/privoxy/config

# Adicionando as configurações para trabalhar com o socat como proxy SOCKS5 no arquivo de configuração do privoxy
echo "forward-socks5 / 0.0.0.0/0" | sudo tee -a /etc/privoxy/config
echo "socks-proxy-retry" | sudo tee -a /etc/privoxy/config

# Adicionando regras no firewall para permitir portas 9741, 22, 80, 443, 1080,53
sudo ufw allow 1080
sudo ufw allow 8118
sudo ufw allow 9741
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 53


# Iniciando o socat como proxy SOCKS5
socat TCP4-LISTEN:1080,reuseaddr,fork SOCKS4A:localhost:.,socksport=8118 &

# Reiniciando o privoxy
sudo systemctl restart privoxy
