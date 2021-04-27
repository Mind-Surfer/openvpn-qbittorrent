FROM debian:latest

LABEL maintainer="@Mind-Surfer" license="Apache License, Version 2.0"

COPY build/ /build/
COPY run/ /run/

##Install our packages
RUN chmod +x /build/setup.sh && \
    chmod +x /run/entrypoint.sh && \
    chmod +x /run/vpnup.sh && \
    chmod +x /run/vpndown.sh && \
    /build/setup.sh

##Open the web client port
EXPOSE 8080/tcp

VOLUME [ "/config/", "/torrents/"]

ENTRYPOINT exec /run/entrypoint.sh