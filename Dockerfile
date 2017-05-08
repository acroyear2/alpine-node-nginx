FROM mhart/alpine-node:4
RUN apk update && \
    apk add bash nginx openssl && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*
RUN mkdir -p /run/nginx
COPY start.sh /start.sh
RUN mkdir -p /usr/share/nginx/html
COPY index.html /usr/share/nginx/html
CMD ["/start.sh"]
