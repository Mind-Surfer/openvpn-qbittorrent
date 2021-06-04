FROM debian:latest

LABEL maintainer="@Mind-Surfer" license="Apache License, Version 2.0"

#Defaults to Google's DNS Servers
ENV DNS_SERVER1="8.8.8.8" DNS_SERVER2="8.8.4.4"

COPY build/ /build/
COPY run/ /run/

##Install our packages
RUN chmod +x /build/setup.sh && \
    chmod +x /run/entrypoint.sh && \
    chmod +x /run/isipvalid.sh && \
    chmod +x /run/vpnup.sh && \
    chmod +x /run/vpndown.sh && \
    /build/setup.sh

##Open the web client port
EXPOSE 8080/tcp

VOLUME [ "/config/", "/torrents/"]

ENTRYPOINT [ "/run/entrypoint.sh" ]

CMD [ "qbittorrent-nox", "--profile=/config/" ]