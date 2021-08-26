#!/bin/sh
mkdir -p /home/qbittorrent/.profile
mkdir -p /home/qbittorrent/bin && source /home/qbittorrent/.profile
echo "Downloading qBittorrent-nox from 'https://github.com/userdocs/qbittorrent-nox-static'.."
wget -qO /home/qbittorrent/bin/qbittorrent-nox https://github.com/userdocs/qbittorrent-nox-static/releases/latest/download/x86_64-qbittorrent-nox
chmod 700 /home/qbittorrent/bin/qbittorrent-nox
echo