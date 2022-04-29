#paquete socket maneja conexiones TCP
import socket
import binascii

#IP a la cual conectarse
TCP_IP = '192.168.1.149'
#Puerto al cual conectarse
TCP_PORT = 2000
#Maximo de datos a recibir en el buffer
BUFFER_SIZE = 10


#Crea el objeto socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#Se conecta a la direccion especificada anteriormente
s.connect((TCP_IP, TCP_PORT))


#Eternamente hacer:
while True:
	#Recibir datos y guardarlos en data
	data = s.recv(BUFFER_SIZE)
	#Muestra lo recibido
	print "Remoto dice: ", data
	#Lee el input del usuario local
	localmessage = raw_input("Ingrese Comando:\n")
	#Lo envia y lo muestra
	s.send(localmessage)
	print "Local dice: ", localmessage

#Cierra todo
s.close()
quit()
