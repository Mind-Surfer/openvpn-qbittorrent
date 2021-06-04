#!/bin/sh
set -e

#If the qBittorrent does not exist copy the default in
#We may also need to create the dir structure too
if [ ! -f /config/qBittorrent/config/qBittorrent.conf ];
     then
          echo "qBittorrent config does not exist, copying default config.."
          mkdir -p /config/qBittorrent/config
          cp /build/default-config/qBittorrent.conf /config/qBittorrent/config/qBittorrent.conf
else
     echo "qBittorrent config exists. "
fi

#This one is not for the config but for the plugins which we're going to pull down
#This makes it a bit easier to use because it saves clicking the check for updates button
#whenever we start the container
if [ ! -d /config/qBittorrent/data ];
     then
          mkdir -p /config/qBittorrent/data
fi

#We check if the openvpn.conf exists - we can't connect without it!
if [ ! -f /config/openvpn.conf ];
     then
          echo "Cannot find the VPN config file!"
          echo "Exiting.."
          exit 1
fi

#We need the private ip address so that we can compare it to the vpn ip and of course for informational purposes
privateip="$(python3 /run/getprimaryip.py)"
echo "Private TCP/IP address: $privateip"
echo "Setting WebUI listener IP address.."

#we need the webui to be accessible externally to the host so change the listner to the local host ip
sed -i 's/^WebUI\\Address=.*$/WebUI\\Address='"$privateip"'/' /config/qBittorrent/config/qBittorrent.conf

echo "Connecting VPN.."
openvpn --config /config/openvpn.conf \
     --ping 10 --ping-exit 60 --daemon \
     --script-security 2 --up-delay --up /run/vpnup.sh \
     --down /run/vpndown.sh --log /config/openvpn.log

#When the vpn is up, it will create this file. Then we can start the torrent client.
until [ -f /run/up.vpn ]
do
     echo "Waiting for vpn connection.."
     sleep 5
done

#Sleep again to make sure the connection is up and active before we go and do stuff
sleep 5

#Get the vpn address
vpnip="$(python3 /run/getvpnip.py)"
echo "VPN TCP/IP address: $vpnip"
echo "DNS server 1: $DNS_SERVER1"
echo "DNS server 2: $DNS_SERVER2"

#Compare the private address and the vpn address
#they should not be the same, if they are we exit
if [ $privateip = $vpnip ];
     then
          echo "Failed to connect to the VPN correctly."
          echo "Exiting to prevent information leakage.."
          exit 2
fi

sed -i 's/^Connection\\InterfaceAddress=.*$/Connection\\InterfaceAddress='"$vpnip"'/' /config/qBittorrent/config/qBittorrent.conf
#/etc/resolv.conf
echo "VPN is up, Updating search plugins.."
cd /config/qBittorrent/data/
#Now we can go and get the default search plugins
wget https://github.com/qbittorrent/search-plugins/archive/refs/heads/master.zip
unzip master.zip
cp -r search-plugins-master/nova3 nova3
echo "Cleaning up.."
rm master.zip && rm -r search-plugins-master
cd /

echo "starting qBittorrent.."
exec "$@"

exit 0