#!/bin/bash

# Obtient l’adresse IP de l’interface utilisée par défaut.
# L’exécution est arrêtée si le port est utilisé.
if=$(route -n get 0.0.0.0 2>/dev/null | awk '/interface: / {print $2}')
if [ -n "$if" ]; then
    echo "Default route is through interface $if"
else
    echo "No default route found"
fi
IP=$( ipconfig getifaddr $if )
echo $IP
PORT=8080
PORTINUSE=$( lsof -i tcp:$PORT )
if [ -n "$PORTINUSE" ]; then
    echo "$IP:$PORT already in use"
    exit 1
fi

# Enregistre les paramètres dans le fichier de config
# http://stackoverflow.com/questions/24633919/prepend-heredoc-to-a-file-in-bash
CONFIG_DEV="_config_dev.yml"
read -r -d '' CONFIG_STR << EOF
url: http://$IP:$PORT
host: $IP
port: $PORT
baseurl: ""

sass:
  style: normal
l
EOF
# trick to pertain newline at the end of a message
# see here: http://unix.stackexchange.com/a/20042
CONFIG_STR=${CONFIG_STR%l}
printf %s "$CONFIG_STR" > $CONFIG_DEV
more $CONFIG_DEV


# Démarre Jekyll
bundle exec jekyll serve --config _config.yml,_config_dev.yml
