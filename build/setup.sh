#!/bin/sh

#This script installs and applies the latest updates to the image and then installs QBittorrent, OpenVPN. 
apt-get update -y && apt-get upgrade -y && apt-get autoremove -y

echo "**** Installing OpenVPN and qBittorrent.. ****"
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun
cat /dev/net/tun
apt-get install -y openvpn qbittorrent-nox python3 wget unzip

echo "**** Finished installing OpenVPN and qBittorrent. ****"

echo "**** Cleaningup.. ****"
apt-get clean && \
rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*
echo "**** Finished cleaningup. ****"