# qBittorrent #

A very simple (and small!) container image with OpenVPN and qBittorrent installed on the official latest Alpine base image.

## Features ##

* Works with any VPN provider that provides an OpenVPN configuration file
* Configurable DNS Servers
* Updated each week with relevant package and security updates
* qBittorrent runs under a low privilage account
* Automatically updates qBittorrent search pluggins from [https://github.com/qbittorrent/search-plugins](https://github.com/qbittorrent/search-plugins) when the container starts
* If OpenVPN loses its connection for whatever reason, the container will stop to prevent information leakage

## Base Image ##

* Alpine

## Software ##

* OpenVPN
* qBittorrent

### About OpenVPN ###

OpenVPN is a virtual private network (VPN) system that implements techniques to create secure point-to-point or site-to-site connections in routed or bridged configurations and remote access facilities.. [click here to see more info on wikipedia](https://en.wikipedia.org/wiki/OpenVPN)

### About qBittorrent ###

qBittorrent is a cross-platform free and open-source BitTorrent client.. [click here to see more info on wikipedia](https://en.wikipedia.org/wiki/QBittorrent)

***Note***
Bittorrent is not available in qAlpine apk. So we use the latest version provided by [userdocs on GitHub](https://github.com/userdocs/qbittorrent-nox-static). License information can be found [here](https://github.com/userdocs/qbittorrent-nox-static/blob/master/LICENSE.txt).

## Tags ##

Tag     | Description
:-------|:-----------------
latest  | v2.1.0
v2.1.0  | Alpine image base
v2.0.4  | Debian image base
v2.0.3  | Debian image base
v2.0.2  | Debian image base
v2.0.1  | Debian image base

## Package and Security Updates ##

The image is updated each week with relevant package and security updates.

## Requirements ##

The following text outlines the requirements that must be fulfilled in order to successfully run the container image.

### Directories ###

You need two directories on the host: -

1. A configuration directory
   1. This directory is going to hold your qBittorrent configuration and your OpenVPN configuration file
2. A torrent directory
   1. As implied, this directory will hold your torrent files

***These directories and the data held within them are persisted when the container is stopped or removed.***

### OpenVPN configuration file ###

* The file must be named openvpn.conf (the name must all be lower case)
* The file must be placed at the root of your configuration directory

Example:

1. I create a folder called qBittorrent in my home directory
2. I save the Open VP configuration file into the configuration directory created in the previous step (qBittorrent)

### qBittorrent Web UI TCP/IP Port Mapping ###

* You must map a TCP/IP port 8080.
  * i.e. using docker run, the port is be mapped like this -p 8080:8080

### Volume Mapping ###

* Map the directory that you created for the torrents to the container volume /torrents/
* Map the directoty that you created for the configuration to the container volume /config/

***The container requires read/write access to both volumes***

### Usage ###

The basic mode of operation when the container is started is as follows: -

1. The container will attempt to use the openvpn.conf from the volume. If the file does not exists, the container will exit and the output will indicate that the file could not be found.
2. When OpenVPN has established it's connection, qBittorrent will be started.
3. If OpenVPN loses its connection for whatever reason, the container will stop to prevent information leakage.

Optional environment variables: -

* DNS_SERVER1
  * A valid TCP/IP address of the DNS server you want to use.
* DNS_SERVER2
  * A valid TCP/IP address of the DNS server you want to use.

If not specified, they default to using Google's public DNS servers (8.8.8.8, 8.8.4.4)

#### Docker run ####

`docker run --name qbittorrent
    -d
    -it
    --device=/dev/net/tun
    --cap-add=NET_ADMIN
    -p 8080:8080
    -e DNS_SERVER2="8.8.8.8"
    -e DNS_SERVER2="8.8.4.4"
    -v ~/Downloads/Movies:/torrents/
    -v ~/qbittorrent:/config/
    mindsurfer/qbittorrent:latest`

#### Paramater Notes ####

There are a couple of parameters that I would like to draw your attention too;

* --device=/dev/net/tun
* --cap-add=NET_ADMIN

***These parameters are required for OpenVPN to connect. Without them, OpenVPN will not connect.***

### Accessing the qBittorrent Web UI ###

When OpenVPN has established its connection, the local area network becomes inaccessible to the container. This is by design. OpenVPN and your VPN provider use the same private address ranges that are in use on your home/local network. This unfortunately means that the qBittorrent Web UI is only accessible from the host (the machine where your container is running). It is possible to work around this and create a route to your local network, but the mapping may cause a conflict between the VPN network range and your network range. Best to leave it and avoid creating problems.

You can read more about this [here](https://openvpn.net/community-resources/how-to/).

### qBittorrent Web UI ###

When you first run the container, qBittorrent is setup with the default user name and password (admin, adminadmin). I strongly advise you to change these to something more secure.

If you appreciate my work, buy me a coffee!

[![If you appreciate my work, buy me coffee](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=9A8T62P8DDAMC)
