
import socket

TCP_IP = '192.168.0.138'
TCP_PORT = 2000
BUFFER_SIZE = 5
MESSAGE = "Listo"
PASS = "G01"
CONNECTED = False
 
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((TCP_IP, TCP_PORT))
CONNECTED = True
while True:

	data1 = s.recv(BUFFER_SIZE)
	data = str(data1, 'utf-8')
	print("received data:" + data)

	if data == "PASS?":
		s.send(PASS.encode())
		print("received data:" + data)

	elif data == "AOK":
		CONNECTED = True
		print("se envio pass: " + data)
		break

	else:
		CONNECTED = False
		print("se envio pass: " + data)
		break 

while CONNECTED:

	MESSAGE = input("Ingrese Comando:\n")

	if MESSAGE == "c":
	   break

	else:
		s.send(MESSAGE.encoded())
		print(MESSAGE)

s.close()

quit()
