#!/bin/sh

function valid_ip()
{
     #I got this from here https://www.linuxjournal.com/content/validating-ip-address-bash-script
     #By Mitch Frazier
     local  ip=$1
     local  stat=1

     if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
          OIFS=$IFS
          IFS='.'
          ip=($ip)
          IFS=$OIFS
          [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
               && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
          stat=$?
     fi
     return $stat
}

#Validate our dns ip addresses 
if [ ! $(valid_ip() $DNS_SERVER1) ] 
     then set $DNS_SERVER1="8.8.8.8" 
fi
if [ ! $(valid_ip() $DNS_SERVER2) ] 
     then set $DNS_SERVER2="8.8.4.4" 
fi

#If the qBittorrent does not exist copy the default in
#We may also need to create the dir structure too
if [ ! -f /config/qBittorrent/config/qBittorrent.conf ]
     then
          echo "qBittorrent config does not exist, copying default config.."
          mkdir /config/qBittorrent
          mkdir /config/qBittorrent/config
          cp /build/default-config/qBittorrent.conf /config/qBittorrent/config/qBittorrent.conf
else
     echo "qBittorrent config exists. "
fi

#This one is not for the config but for the plugins which we're going to pull down
#This makes it a bit easier to use because it saves clicking the check for updates button
#whenever we start the container
if [ ! -d /config/qBittorrent/data ]
     then
          mkdir /config/qBittorrent/data
fi

#We check if the openvpn.conf exists - we can't connect without it!
if [ ! -f /config/openvpn.conf ] 
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
declare -i timer
timer=0
until [ -f /run/up.vpn || timer > 60 ]
do
     echo "Waiting for vpn connection.."
     sleep 5
     timer+=5
done

if [ ! -f /run/up.vpn ]
     then
          echo "Timed out waiting for vpn connection."
          echo "Exiting.."
          exit 2
fi

#Sleep again to make sure the connection is up and active before we go and do stuff
sleep 5

#Get the vpn address
vpnip="$(python3 /run/getvpnip.py)"
echo "VPN TCP/IP address: $vpnip"

#Compare the private address and the vpn address
#they should not be the same, if they are we exit
if [ $privateip = $vpnip ]
     then
          echo "Failed to connect to the VPN correctly."
          echo "Exiting to prevent information leakage.."
          exit 3
fi

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

exit 0