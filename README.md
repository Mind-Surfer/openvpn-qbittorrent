# Debian OpenVPN and qBittorrent Container Image

A very simple container that has OpenVPN and qBittorrent installed on the official latest debian base image. It was created for my specifically for my own use but it may also be useful to you too. I am aware that this container is restrictive, so if it's not suitable for you there are other images out there offering more flexible options using OpenVPN and Deluge. I just happen to like qBittorrent and wanted to try creating my own container :-).

## About OpenVPN

OpenVPN is a virtual private network (VPN) system that implements techniques to create secure point-to-point or site-to-site connections in routed or bridged configurations and remote access facilities.. [click here to see more info on wikipedia](https://en.wikipedia.org/wiki/OpenVPN)

## About qBittorrent

qBittorrent is a cross-platform free and open-source BitTorrent client.. [click here to see more info on wikipedia](https://en.wikipedia.org/wiki/QBittorrent)

## Requirements

The following text outlines the requirements that must be fulfilled in order to successfully run the image.

### Directories

You need two directories on the host: -

1. A configuration directory
   1. This directory is going to hold your qBittorrent configuration and your OpenVPN configuration file
2. A torrent directory
   1. As implied, this directory will hold your torrent files

***These directories and the data held within them are persisted when the container is stopped or removed.***

### OpenVPN configuration file

* The file must be named openvpn.conf (the name must all be lower case)
* The file must be placed at the root of your configuration directory

Example:

1. I create a folder called qBittorrent in my home folder
2. I save my Open VP configuration file into the qBittorrent folder created in the previous step

### qBittorrent Web UI TCP/IP Port Mapping

* You must map a TCP/IP port 8080.
  * i.e. using docker run, the port would be mapped like this -p 8080:8080

### Volume Mapping

You must map two directories to that you have created on the host to the container:-

* Map the directory that you created for the torrents to the container volume /torrents/
* Map the directoty that you created for the configuration to the container volume /config/

***The container requires read/write access to both volumes***

### Usage

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

#### Docker run

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

#### Paramater Notes

There are a couple of parameters that I would like to draw your attention too;

* --device=/dev/net/tun
* --cap-add=NET_ADMIN

***These parameters are required for OpenVPN to connect. Without them, OpenVPN will not connect.***

### Accessing the qBittorrent Web UI

When OpenVPN has established its connection, the local area network becomes inaccessible. This is by design because OpenVPN and your VPN provider use the same private address ranges that are in use on your local network. This unfortunately means that the qBittorrent Web UI is only accessible from the host (the machine where your container is running).

You can read more about this [here](https://openvpn.net/community-resources/how-to/).

### qBittorrent Web UI

When you first run the container, qBittorrent is setup with the default user name and password (admin, adminadmin). I strongly advise you to change these to something more secure.