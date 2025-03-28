#!/bin/bash
# MAUVADAO
# VER: 1.0.0

# verificando o status da conexao
# setando informações de proxy e servidor
dom="br1.maudavpn.shop"
tempo="1"
proxy="timofertas.com"
porta="80"
request="PATCH"
echo
# fazendo o request
curl -m "$tempo" -s -o /dev/null -w '%{http_code}' -X GET "$dom" -H 'Websocket: Upgrade' -x "$proxy:$porta"
echo
