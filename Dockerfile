FROM debian:bullseye-20230320-slim

# Add image information
LABEL \
    category="ldapsearch-nginx-exporter" \
    maintainers="Hetimop"



# Install requirements
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends  ldap-utils nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./config/*.sh /app/scripts/
COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /app/scripts/* && \
    chmod +x /usr/local/bin/entrypoint.sh && \
    mkdir /app/metrics -p

CMD [ "/usr/local/bin/entrypoint.sh"]