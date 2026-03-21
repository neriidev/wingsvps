FROM caddy:2-alpine
RUN apk add --no-cache curl
COPY run.sh /usr/local/bin/caddy-wings-entry.sh
ENTRYPOINT ["/bin/sh", "/usr/local/bin/caddy-wings-entry.sh"]
CMD []
