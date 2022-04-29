
import socket
import binascii

TCP_IP = '192.168.1.149'
TCP_PORT = 2000
BUFFER_SIZE = 5
MESSAGE = "Listo"
PASS = "G12"
CONNECTED = False
 
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((TCP_IP, TCP_PORT))

while True:

	data = s.recv(BUFFER_SIZE)
	print("received data: {}".format(data))

	if data == "PASS?":
		s.send(PASS)

	elif data == "AOK":
		CONNECTED = True
		break

	else:
		CONNECTED = False
		break 

while CONNECTED:

	MESSAGE = raw_input("Ingrese Comando:\n")

	if MESSAGE == "c":
		break

	else:
		s.send(MESSAGE)
		print("meensajeenviado")

s.close()

quit()
