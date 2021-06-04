FROM debian:latest

LABEL maintainer="@Mind-Surfer" license="Apache License, Version 2.0"

#Defaults to Google's DNS Servers
ENV DNS_SERVER1="8.8.8.8" DNS_SERVER2="8.8.4.4"

COPY build/ /build/
COPY run/ /run/

##Install our packages
RUN apt-get update -y && apt-get upgrade -y && apt-get autoremove -y && \
    echo "**** Installing OpenVPN and qBittorrent.. ****" && \
    #Needed for OpenVPN
    mkdir -p /dev/net && \
    mknod /dev/net/tun c 10 200 && \
    chmod 600 /dev/net/tun && \
    #Now we can install the packages
    apt-get install -y openvpn qbittorrent-nox python3 wget unzip && \
    echo "**** Finished installing OpenVPN and qBittorrent. ****" && \
    echo "**** Cleaning up.. ****" && \
    apt-get clean && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/* && \
    echo "**** Finished cleaning up. ****" && \
    chmod +x /run/entrypoint.sh && \
    chmod +x /run/vpnup.sh && \
    chmod +x /run/vpndown.sh

##Open the web client port
EXPOSE 8080/tcp

VOLUME [ "/config/", "/torrents/"]

ENTRYPOINT [ "/run/entrypoint.sh" ]

CMD [ "qbittorrent-nox", "--profile=/config/" ]