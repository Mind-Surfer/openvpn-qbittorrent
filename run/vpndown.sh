#!/bin/sh
echo "VPN connection down."
rm /run/up.vpn
pkill qbittorrent-nox