FROM ubuntu:24.04

ARG WINGS_VERSION=1.12.1
ARG YQ_VERSION=4.45.1

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

RUN ARCH=$(uname -m) \
    && if [ "$ARCH" = "x86_64" ]; then WARCH=amd64; \
       elif [ "$ARCH" = "aarch64" ]; then WARCH=arm64; \
       else echo "unsupported arch: $ARCH" && exit 1; fi \
    && curl -fsSL -o /usr/local/bin/wings \
        "https://github.com/pterodactyl/wings/releases/download/v${WINGS_VERSION}/wings_linux_${WARCH}" \
    && chmod +x /usr/local/bin/wings

RUN ARCH=$(uname -m) \
    && if [ "$ARCH" = "x86_64" ]; then YARCH=amd64; \
       elif [ "$ARCH" = "aarch64" ]; then YARCH=arm64; \
       else echo "unsupported arch: $ARCH" && exit 1; fi \
    && curl -fsSL -o /usr/local/bin/yq \
        "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${YARCH}" \
    && chmod +x /usr/local/bin/yq

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /etc/pterodactyl
ENTRYPOINT ["/entrypoint.sh"]
