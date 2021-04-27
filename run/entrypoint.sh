#!/bin/sh

#If the config does not exist copy the default in
if [ ! -f /config/qBittorrent/config/qBittorrent.conf ]
     then
          echo "qBittorrent config does not exist, copying default config.."
          mkdir /config/qBittorrent
          mkdir /config/qBittorrent/config
          cp /build/default-config/qBittorrent.conf /config/qBittorrent/config/qBittorrent.conf
else
     echo "qBittorrent config exists. "
fi

if [ ! -d /config/qBittorrent/data ]
     then
          mkdir /config/qBittorrent/data
fi

echo "Setting WebUI listener IP address.."
#we need the webui to be accessible externally to the host so change the listner to the local host ip
sed -i 's/^WebUI\\Address=.*$/WebUI\\Address='"$(python3 /run/getprimaryip.py)"'/' /config/qBittorrent/config/qBittorrent.conf

if [ -f /config/openvpn.conf ] 
     then
          echo "Connecting VPN.."
          openvpn --config /config/openvpn.conf \
               --ping 10 --ping-exit 60 --daemon \
               --script-security 2 --up-delay --up /run/vpnup.sh \
               --down /run/vpndown.sh

          #When the vpn is up, it will create this file. Then we can start the torrent client.
          until [ -f /run/up.vpn ]
          do
               echo "Waiting for vpn connection.."
               sleep 5
          done

          sleep 5

          echo "VPN TCP/IP address: $(python3 /run/getprimaryip.py)"
          sed -i 's/^Connection\\InterfaceAddress=.*$/Connection\\InterfaceAddress='"$(python3 /run/getprimaryip.py)"'/' /config/qBittorrent/config/qBittorrent.conf

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
          qbittorrent-nox --profile=/config/

else
     echo "Cannot find the VPN config file!"
     echo "exiting.."

fi