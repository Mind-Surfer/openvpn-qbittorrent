#!/bin/sh

# Message prefix
TIME=$(date +%T)
PREFIX="[${TIME} INFO]:"

echo "${PREFIX} VPN connection down."
rm /run/up.vpn
pkill qbittorrent-nox