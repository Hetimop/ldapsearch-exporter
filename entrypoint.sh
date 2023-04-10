#!/bin/bash

# Bind Variable METRICS_PORT
if [ -n "$METRICS_PORT" ]; then
sed -E -i "s/listen\s+[0-9]+/listen ${METRICS_PORT}/" /etc/nginx/nginx.conf
fi

# Bind Variable LDAPSRV
if [ -n "$LDAPSRV" ]; then
sed -i "/^urls=/s#.*#urls=($LDAPSRV)#" /app/scripts/ldapsearch_exporter.sh
fi

# Bind Variable FILTRES
if [ -n "$FILTRES" ]; then
sed -i "/^filtres=/s/.*/filtres=(${FILTRES})/" /app/scripts/ldapsearch_exporter.sh
fi


# Start the Nginx service
nginx -g "daemon off;" &


while true; do
  /app/scripts/ldapsearch_exporter.sh >/dev/null 2>&1  &
  sleep 15
done