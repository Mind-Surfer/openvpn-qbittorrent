# Using code from https://stackoverflow.com/questions/6243276/how-to-get-the-physical-interface-ip-address-from-an-interface
# By Bruno Romano
# Modified to include try statement and use variable
import socket
import fcntl
import struct

def get_ip_address(ifname):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        IP = socket.inet_ntoa(fcntl.ioctl(
            s.fileno(),
            0x8915,  # SIOCGIFADDR
            struct.pack('256s', ifname[:15].encode('utf8'))
        )[20:24])
    except Exception:
        IP = 'error'
    finally:
        return IP

print(get_ip_address('tun0'))
