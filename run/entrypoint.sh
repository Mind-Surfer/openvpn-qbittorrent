#!/bin/sh
set -e

echo "Setting DNS name servers.."
echo
NOW=$(date)
echo "#DNS entries set $NOW" > /etc/resolv.conf
echo "nameserver $DNS_SERVER1" >> /etc/resolv.conf
echo "nameserver $DNS_SERVER2" >> /etc/resolv.conf
echo "/etc/resolv.conf: -"
cat /etc/resolv.conf
echo

# If the qBittorrent does not exist copy the default in
# We may also need to create the dir structure too
if [ ! -f /config/qBittorrent/config/qBittorrent.conf ];
     then
          echo "qBittorrent config does not exist, copying default config.."
          mkdir -p /config/qBittorrent/config
          cp /build/default-config/qBittorrent.conf /config/qBittorrent/config/qBittorrent.conf
else
     echo "qBittorrent config exists. "
     echo
fi

# This one is not for the config but for the plugins which we're going to pull down
# This makes it a bit easier to use because it saves clicking the check for updates button
# whenever we start the container
if [ ! -d /config/qBittorrent/data ];
     then
          mkdir -p /config/qBittorrent/data
fi

# We check if the openvpn.conf exists - we can't connect without it!
if [ ! -f /config/openvpn.conf ];
     then
          echo "Cannot find the VPN config file!"
          echo "Exiting.."
          exit 1
fi

# We need the private ip address so that we can compare it to the vpn ip and of course for informational purposes
privateip="$(python3 /run/getprimaryip.py)"
echo "Setting WebUI listener IP address.."
echo "WebUI listener IP address is: $privateip"
echo

# we need the webui to be accessible externally to the host so change the listner to the local host ip
sed -i 's/^WebUI\\Address=.*$/WebUI\\Address='"$privateip"'/' /config/qBittorrent/config/qBittorrent.conf

echo "Connecting VPN.."
openvpn --config /config/openvpn.conf \
     --ping 10 --ping-exit 60 --daemon \
     --script-security 2 --up-delay --up /run/vpnup.sh \
     --down /run/vpndown.sh --log /config/openvpn.log

# When the vpn is up, it will create this file. Then we can start the torrent client.
until [ -f /run/up.vpn ]
do
     echo "Waiting for vpn connection.."
     sleep 5
done

# Sleep again to make sure the connection is up and active before we go and do stuff
sleep 5

# Get the vpn address
vpnip="$(python3 /run/getvpnip.py)"
echo "VPN TCP/IP address: $vpnip"
echo

# Compare the private address and the vpn address
# they should not be the same, if they are we exit
if [ $privateip = $vpnip ];
     then
          echo "Failed to connect to the VPN correctly."
          echo "Exiting to prevent information leakage.."
          exit 2
fi

echo "VPN is up! Configuring qBittorrent to use vpn interface.."
sed -i 's/^Connection\\InterfaceAddress=.*$/Connection\\InterfaceAddress='"$vpnip"'/' /config/qBittorrent/config/qBittorrent.conf
echo

echo "Updating search plugins.."
cd /config/qBittorrent/data/
# Now we can go and get the default search plugins
wget https://github.com/qbittorrent/search-plugins/archive/refs/heads/master.zip
unzip master.zip
cp -r search-plugins-master/nova3 nova3
echo "Cleaning up.."
rm master.zip && rm -r search-plugins-master
echo

cd /

chown -R qbittorrent /config/
chown -R qbittorrent /torrents/
chown -R qbittorrent /home/qbittorrent/bin

echo "starting qBittorrent.."
su-exec qbittorrent "$@"

exit 0