#!/bin/sh

# Message prefix
TIME=$(date +%T)
PREFIX="[${TIME} INFO]: "
RED="\033[0;31m"
WHITE="\e[0;37m"

echo "${RED}${PREFIX}VPN connection down.${WHITE}"
rm /run/up.vpn
pkill qbittorrent-nox