#Posted here https://stackoverflow.com/questions/166506/finding-local-ip-addresses-using-pythons-stdlib
#by user2561747 - This method returns the "primary" IP on the local box (the one with a default route).
import socket
def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # doesn't even have to be reachable
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
        
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP
#needed for the ouput into bash
print(get_ip())