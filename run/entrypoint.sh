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

privateip="$(python3 /run/getprimaryip.py)"
echo "Private TCP/IP address: $privateip"
echo "Setting WebUI listener IP address.."
#we need the webui to be accessible externally to the host so change the listner to the local host ip
sed -i 's/^WebUI\\Address=.*$/WebUI\\Address='"$privateip"'/' /config/qBittorrent/config/qBittorrent.conf

if [ -f /config/openvpn.conf ] 
     then
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

          #Compare the private address and the vpn address
          #they should not be the same, if they are we exit
          if [ $privateip != $vpnip ]
               then
                    echo "VPN TCP/IP address: $vpnip"
                    sed -i 's/^Connection\\InterfaceAddress=.*$/Connection\\InterfaceAddress='"$vpnip"'/' /config/qBittorrent/config/qBittorrent.conf

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
               echo "Failed to connect to the VPN correctly."
               echo "Exiting to prevent information leakage.."

          fi

else
     echo "Cannot find the VPN config file!"
     echo "Exiting.."

fi