
import socket
import binascii

TCP_IP = "192.168.0.139"
TCP_PORT = 2000
BUFFER_SIZE = 5
MESSAGE = "Enc"
PASS = "G02"
 
print("Conectando")
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((TCP_IP, TCP_PORT))
print("Conectado")

while True:

	data1 = s.recv(BUFFER_SIZE)
	data = str(data1, 'utf-8')
	
	print(data)

	if data == 'PASS?':
		s.send(PASS.encode())

	elif data == "AOK":
		s.send(MESSAGE.encode())

	elif data == "Ready?":
		s.send(b"Yes!")

	elif data == "c":
		s.send(b"close\n")
		break

	elif data != "":
		send = "received: " + data + "\n"
		s.send(send.encode())

s.close()

quit()
