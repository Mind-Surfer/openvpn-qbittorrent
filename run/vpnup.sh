#!/bin/sh
echo "VPN connection up."
touch /run/up.vpn
cp /run/resolv.conf /etc/resolv.conf