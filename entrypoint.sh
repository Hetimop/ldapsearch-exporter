#!/bin/bash

# Bind Variable METRICS_PORT
if [ -n "$METRICS_PORT" ]; then
sed -E -i "s/listen\s+[0-9]+/listen ${METRICS_PORT}/" /etc/nginx/nginx.conf
fi

# Bind Variable LDAPSRV
if [ -n "$SRVLDAP" ]; then
sed -E -i "/^srvldap=/s#.*#srvldap=($SRVLDAP)#" /app/scripts/ldapsearch_exporter.sh
fi

# Bind Variable FILTRES
if [ -n "$FILTRE" ]; then
sed -E -i "/^filtre=/s/.*/filtre=(${FILTRE})/" /app/scripts/ldapsearch_exporter.sh
fi


# Start the Nginx service
nginx -g "daemon off;" &


while true; do
  /app/scripts/ldapsearch_exporter.sh >/dev/null 2>&1  &
  sleep 2
done