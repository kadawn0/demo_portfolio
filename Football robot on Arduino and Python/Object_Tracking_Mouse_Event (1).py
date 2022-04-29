import numpy as np
import cv2 as cv2
import threading
import socket
import math
import time


class Processing(object):
    def __init__(self):
        object.__init__(self)
        self.n = 2
        self.h = 1240/self.n  # Height zona de juego
        self.w = 2200/self.n  # Width zona de juego
        self.cam = cv2.VideoCapture(1)
        self.isOpen = self.cam.isOpened()
        self.contours = []
        self.blops = []
        self.modo = int(raw_input("Seleccione el modo de operacion del robot:"))

        # INICIALIZA ARRAYS CON COLORES EN UINT8
        self.inSetup = True

        self.lower_matrix = np.zeros((5, 3), dtype=np.uint8)
        self.upper_matrix = np.zeros((5, 3), dtype=np.uint8)
        self.contador_matrix = 0

        self.lower = np.array([0, 50, 50], np.uint8)
        self.upper = np.array([5, 255, 255], np.uint8)
        self.error = np.array([7, 0, 0], np.uint8)

        self.Title_tracker = "Color Tracker"
        self.Title_original = "Original Image"
        self.stahp  =True

        self.position = tuple((0, 0))  # usado para property de posicion
        self.target = (0, 0)  # Posicion target
        self.angle = 10
        self.rotational_target = (0, 0)  # para calculo de angulo target
        self.angle_ref = 0  # recibido de opencv, es el angulo real
        self.rate = 5  # Cambiar con motores
        self.pos_pelota = []
        self.pos_small = []
        self.posiciones = []
        self.centro = []
        self.arco_1 = []
        self.arco_2 = []
        self.pos_enemigo = []  # estaba vacio y le puse una lista
        self.enable = True  # (de aca para abajo) Tienen los controles para que no se repita la misma ccion varias veces
        self.enabled = True  # Este es el enable del movimiento cartesiano
        self.listen = True  # enable del cliente tcp
        self.waiting = False  # Indica si el robot debe quedarse quieto
        self.host = '192.168.0.146'  # (de aca para abajo) host y port para funcion de cliente
        self.port = 2000
        self.password = "G09"  # Rellenar
        self.message = "Listo"  # o "Enc" En tcp robot client ejemplo

        self.order = ""  # Contiene la orden enviada desde el servidor. En este caso seran imagenes.
        self.data = ""  # Para guardar el dato mas reciente proveniente del serial
        self.start = True
        self.isFrame = False

        self.socket_cliente = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  # el socket para la conexion
        self.analysis_thread = threading.Thread(target=self.run_analysis)  # Thread de analisis de iamgen
        self.movement_thread = threading.Thread(target=self.move)  # Thread de movimiento cartesiano con rotacion
        # self.serial = serial.Serial('/dev/tty.usbserial', 9600)  # Serial para comunicacion con
        # arduino por puerto serial
        self.setup()

    # ---CODIGO DE POSICIONAMIENTO---

    @property
    def angulo(self):
        return self.angle_ref

    @property
    def pelota(self):
        return self.pos_pelota

    @pelota.setter
    def pelota(self, other):
        self.pos_pelota = (other[0], other[1])

    def setup(self):  # Setup para la caracteristica de cliente de esta clase
        print("SETUP")
        # self.connect_to_server()
        if self.start:
            done = True
            # while self.modo == "":  # porfa comenta cuales son las teclas que representan estos numeros
            #     if cv2.waitKey(10) == 48:
            #         self.modo = 0
            #         done = True
            #     elif cv2.waitKey(10) == 49:
            #         self.modo = 1
            #         done = True
            #     elif cv2.waitKey(10) == 50:
            #         self.modo = 2
            #         done = True
            if done:
                print("GONNA LISTEN")
                self.listener()  # Para conexion tcp wifly
                # self.start_listen_serial()  # Para conexion con puerto serial (para testing)
                print("ANALYSIS START")
                self.analysis_thread.start()
                print("MOVEMENT START")
                time.sleep(2)
                self.movement_thread.start()

    def Filter(self):
        all_mask = np.zeros((self.rows, self.colums), np.uint8)
        posicion=[]

        for i in range(5):

            self.thres = cv2.inRange(self.hsv_img, self.lower_matrix[i, :], self.upper_matrix[i, :])

            self.contours, self.hierarchy = cv2.findContours(self.thres, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

            if len(self.contours) != 0:

                index_moments = 0
                max_area = 0
                Countour = 0
                mask = np.zeros((self.rows, self.colums), np.uint8)
                self.isReady = False

                for cnt in self.contours:

                    moments = cv2.moments(cnt)
                    area = moments['m00']

                    if area > max_area:
                        index_moments = moments
                        max_area = area
                        Countour = cnt
                        self.isReady = True

                if self.isReady:
                    cv2.drawContours(mask, [Countour], 0, 255, -1)

                    all_mask = cv2.add(all_mask, mask)

                    x = (np.uint32)(index_moments['m10'] / max_area)
                    y = (np.uint32)(index_moments['m01'] / max_area)

                    cv2.circle(self.img, (x, y), 2, (255, 255, 255), 3)
                    posicion.append(x)
                    posicion.append(y)

        self.img_aux2 = cv2.bitwise_and(self.img, self.img, mask=all_mask)
        cv2.imshow("2", self.img_aux2)
        return posicion

    def Setup(self):
        self.thresh = cv2.inRange(self.hsv_img, self.lower, self.upper)

        self.img_aux = cv2.bitwise_and(self.img, self.img,
                                  mask=self.thresh)  # Se aplica la mascara para obtener la imagen con el color deseado

        # findContours obtiene todos los elementos cerrados de la imagen y los agrupa
        # Por cada agrupacion de pixeles, se crea un conjunto,
        # el cual llamaremos Blop los cuales se guardan en "contours"
        self.contours, self. hierarchy = cv2.findContours(self.thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        if len(self.contours) != 0:  # Se revisa que se haya encontrado algun conjunto de pixeles del color deseado
            index_moments = 0  # Guardamos los momentos del blop mas grande por si se requirieran
            max_area = 0  # Se utiliza para guardar el valor del Blop mas grande
            Countour = 0  # Se utiliza para guardar el indice del Blop mas grande
            mask = np.zeros((self.rows, self.colums), np.uint8)
            self.isReady = False

            for cnt in self.contours:
                # Para todos los elementos de contorno, se obtienen los momentos y se revisa el momento de area 'm00'

                moments = cv2.moments(cnt)
                area = moments['m00']

                if area > max_area:
                    # Se guardan los valores de momentos, area y numero de blop
                    index_moments = moments
                    max_area = area
                    Countour = cnt
                    self.isReady = True

            if self.isReady:
                cv2.drawContours(self.img_aux, [Countour], 0, (255, 255, 255), 1)

                cv2.drawContours(mask, [Countour], 0, (255, 255, 255), -1)

                self.img_aux2 = cv2.bitwise_and(self.img, self.img, mask=mask)

                # Utilizando los momentos m10 y m01 se pueden calcular la posicion del centro
                x = (np.uint32)(index_moments['m10'] / max_area)
                y = (np.uint32)(index_moments['m01'] / max_area)

                # Se dibuja el centro en la imagen
                cv2.circle(self.img_aux2, (x, y), 2, (255, 0, 0), 3)
                cv2.imshow("Only Threshold", self.img_aux)
                cv2.imshow(self.Title_tracker, self.img_aux2)
                self.inSetup = False

    def run_analysis(self):
        if not self.isOpen:
            self.isOpen = self.cam.open(1)
            if not self.isOpen:
                print ("Camera not open")
                self.cam.release()
                cv2.destroyAllWindows()

        self.isFrame, self.img = self.cam.read()

        if self.isFrame:

            # isChange1 = self.cam.set(cv2.CAP_PROP_FRAME_WIDTH, 800)  no estan los eventos de cv2
            # isChange2 = self.cam.set(cv2.CAP_PROP_FRAME_HEIGHT, 500)

            self.isFrame, self.img = self.cam.read()

            self.rows, self.colums, _ = self.img.shape
            self.centro=[int(self.rows/2), int(self.colums/2)]
            self.arco_1=[0, self.colums/2]
            self.arco_2=[self.rows,self.colums/2]

            self.img = np.zeros(self.img.shape, np.uint8)
            self.hsv_img = np.zeros(self.img.shape, np.uint8)
            cv2.namedWindow(self.Title_tracker, cv2.WINDOW_AUTOSIZE)
            cv2.namedWindow(self.Title_original, cv2.WINDOW_AUTOSIZE)

            cv2.setMouseCallback(self.Title_original, self._mouseEvent)
        else:
            print ("Not frame")
            self.cam.release()
            cv2.destroyAllWindows()

        while self.isFrame:
            self.isFrame, self.img = self.cam.read()

            cv2.imshow(self.Title_original, self.img)

            self.img = cv2.blur(self.img, (10, 10))

            self.hsv_img = cv2.cvtColor(self.img, cv2.COLOR_BGR2HSV)

            if self.inSetup:
                self.Setup()
                self.inSetup = False
                # print("inSetup")
            
            else:
                if self.Filter() != None and len(self.Filter())!=0:
                    self.posiciones = self.Filter()

                # MODO 0: IR AL CENTRO
                # MODO 1: IR A LA PELOTA
                # MODO 2: DEFENSA
                # MODO 3: OFENSA
                aux = []
                # Probar que las definiciones de arrays esten buenas
                for a in self.posiciones:
                    aux.append(int(a))
                self.posiciones = aux
                if len(self.posiciones) != 0:
                    if self.modo == 0: # ir al centro
                        if self.contador_matrix==2:
                            self.position=self.posiciones[0:2]
                            self.pos_small=self.posiciones[2:4]
                            x = self.position[0] - self.pos_small[0]
                            y = self.position[1] - self.pos_small[1]
                            if x == 0:
                                x = 1
                            self.angle = math.atan(y / x)
                            self.angle_ref = math.atan(self.w/2 / self.h/2)
                            self.target = (self.w/2, self.h/2)
                    if self.modo == 1: # ir a la pelota
                        if self.contador_matrix == 3:
                            self.position=self.posiciones[0:2]
                            self.pos_small=self.posiciones[2:4]
                            self.pos_pelota=self.posiciones[4:6]
                            self.target = self.pos_pelota
                            x = -self.position[0] + self.pos_small[0]
                            y = -self.position[1] + self.pos_small[1]
                            if x == 0:
                                print("\nPARCHE\n")
                                x = 1
                            self.angle = math.atan(y / x)
                            self.angle_ref = math.atan(self.pos_pelota[1] / self.pos_pelota[0])
                            print("REFERENCIA: {} {} {} {} {} {}".format(self.position, self.target, self.pos_small, self.pos_pelota, self.angle_ref, self.angle))
                    if self.modo == 2: # defender
                        if self.contador_matrix==4:
                            self.position=self.posiciones[0:2]
                            self.pos_small=self.posiciones[2:4]
                            self.pos_pelota=self.posiciones[4:6]
                            self.pos_enemigo=self.posiciones[6:8]
                            a = (self.pos_enemigo[1] + self.pos_pelota[1])/2
                            if a > (3/2)*self.arco_1[1]:
                                a = 15
                            elif a < (1/2)*self.arco_1[1]:
                                a = 0
                            self.target = (self.arco_1[0] + 15, a + self.arco_1[1])
                            # asumo que queremos interponernos entre la pelota y el enemigo.
                            # En caso contrario deberia tener la posicion del arco.
                            # ... pero no tenemos la posicion del arco
                            # (quiero que incluso cuando el enemigo tenga la pelota el robot avance a sacarla)
                            x = -self.position[0] + self.pos_small[0]
                            y = -self.position[1] + self.pos_small[1]
                            if x == 0:
                                x = 1
                            self.angle = math.atan(y / x)
                            self.angle_ref = math.atan(self.pos_enemigo[1] / self.pos_enemigo[0])
                            print("REFERENCIA: {} {} {} {} {} {} {}".format(self.position, self.target, self.pos_small,
                                                                         self.pos_pelota, self.pos_enemigo, self.angle_ref, self.angle))
                        elif self.contador_matrix <= 3:
                            self.position = self.posiciones[0:2]
                            self.pos_small = self.posiciones[2:4]
                            x = -self.position[0] + self.pos_small[0]
                            y = -self.position[1] + self.pos_small[1]
                            if x == 0:
                                x = 1
                            self.angle = math.atan(y / x)
                            self.angle_ref = math.atan(self.pos_enemigo[1] / self.pos_enemigo[0])
                            y = 0
                            if self.contador_matrix == 3:
                                self.pos_pelota = self.posiciones[4:6]
                                y = self.pos_pelota[1]
                                if y > self.pos_pelota[1]*(3/2):
                                    y = 15
                                elif y < (1/2)*self.pos_pelota[1]:
                                    y = 0
                            self.target = (self.arco_1[0] + 15, self.arco_1[1] + y)  # se va a parar al frente y al medio4
                            print("REFERENCIA: {} {} {} {} {}".format(self.position, self.target, self.pos_small, self.angle_ref, self.angle))
                            # del arco
                            if len(self.posiciones) >= 7:
                                self.pos_pelota = self.posiciones[4:6]
                                self.target = ((self.target[0] + self.pos_pelota[0])/2, (self.target[1] + self.pos_pelota[1])/2)
                                # si se ha movido a la parte del medio del arco y tiene la
                                # posicion de la pelota, se movera ligeramente
                                # para quedar tambien enfrente de la pelota.
                    if self.modo == 3:  # ofensa
                        if self.contador_matrix == 4:
                            self.position=self.posiciones[0:2]
                            self.pos_small=self.posiciones[2:4]
                            self.pos_pelota=self.posiciones[4:6]
                            self.pos_enemigo=self.posiciones[6:8]
                            self.target = ((self.pos_enemigo[0] + 9*self.pos_pelota[0])/2, (self.pos_enemigo[1] + 9*self.pos_pelota[1])/2)
                            # asumo que queremos interponernos entre la pelota y el enemigo.
                            # En caso contrario deberia tener la posicion del arco.
                            # En este caso se pone mas peso a la posicion de la pelota.
                            # (quiero que incluso cuando el enemigo tenga la pelota el robot avance a sacarla)
                            x = -self.position[0] + self.pos_small[0]
                            y = -self.position[1] + self.pos_small[1]
                            if x == 0:
                                x = 1
                            self.angle = math.atan(y / x)
                            self.angle_ref = math.atan(self.pos_pelota[1]/self.pos_pelota[0])
                        print("REFERENCIA: {} {} {} {} {} {} {}".format(self.position, self.target, self.pos_small,
                                                                        self.pos_pelota, self.pos_enemigo,
                                                                        self.angle_ref, self.angle))

            # print(self.position, self.pos_small, self.pos_pelota, self.posiciones)

            # ojala que el waitkey no vaya a colgar el codigo en algun momento
            if cv2.waitKey(10) == 27:
                self.cam.release()
                cv2.destroyAllWindows()
                break

    def _mouseEvent(self, event, x, y, flags, param):
        # Se obtiene el color del pixel (x,y) y se le suma y resta un error para tener el margen deseado.

        if event == cv2.EVENT_LBUTTONDOWN:
            self.lower[0] = self.hsv_img[y, x, 0]
            self.upper[0] = self.hsv_img[y, x, 0]

            lower = cv2.subtract(self.lower, self.error)
            upper = cv2.add(self.upper, self.error)
            #print(self.lower_matrix[0, :])
            #print(self.lower.transpose())
            self.lower_matrix[self.contador_matrix, :] = lower.transpose()
            self.upper_matrix[self.contador_matrix, :] = upper.transpose()

            self.contador_matrix = self.contador_matrix + 1
            if self.contador_matrix >= 5:
                self.contador_matrix = 0

    def cambiar_posicion(self, tx=0, ty=0):

        self.position = (self.position[0] + tx, self.position[1] + ty)

    # ---- CODIGO DE COMUNICACION ----

    def connect_to_server(self):  # Se conecta al servidor de la direccion especificada
        try:
            self.socket_cliente.connect((self.host, self.port))
            print("Cliente conectado exitosamente al servidor...")
        except:
            self.start = False
            print("ADVERTENCIA: NO SE PUDO CONECTAR")

    def listener(self):  # Para iniciar thread de escucha al servidor
        thread = threading.Thread(target=self.listen_thread)
        thread.start()

    def listen_thread(self):  # El thread que escucha al servidor con un maximo de 4 GB
        self.listen = True
        while self.listen:
            TCP_IP = '192.168.0.146'
            TCP_PORT = 2000
            BUFFER_SIZE = 5
            MESSAGE = "Listo"
            PASS = "G09"
            self.CONNECTED = False
            s = self.socket_cliente
            done = False
            try:
                s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                s.connect((TCP_IP, TCP_PORT))
                self.CONNECTED = True
            except:
                print("SE VA A CERRAR EL SOCKET")
                self.socket_cliente.close()
            while done is False:
                try:
                    data1 = s.recv(BUFFER_SIZE)
                    data = str(data1)
                    print("received data:" + data)

                    if data == "PASS?":
                        s.send(PASS.encode())
                        print("received data:" + data)

                    elif data == "AOK":
                        self.CONNECTED = True
                        print("se envio pass: " + data)
                        break

                    else:
                        done = True
                        self.CONNECTED = False
                        print("se envio pass: " + data)
                        break
                except:
                    self.socket_cliente.close()
            self.send("3")
            self.listen = False
            # while True:
            #     su = raw_input("Ingrese un comando: ")
            #     self.send(su)
            #     if su == "C":
            #         self.socket_cliente.close()

    def send(self, msg):  # Metodo para enviar datos al servidor
        try:
            msg_bytes = msg
            self.socket_cliente.send(msg_bytes)
            print("COMANDO {} ENVIADO".format(msg_bytes.decode()))
            # self.socket_cliente.close()
        except:
            print("NO SE PUDO ENVIAR COMANDO")
            pass

    # ---- CODIGO DE MOVIMIENTO ---

    def move(self):  # Funcion de movimiento cartesiano, origen en parte superior izquierda de la cancha
        # Agregar conversion de self.order a self.target
        inn = 0
        while self.enabled and self.isFrame and self.isOpen:
                # interpretese como el angulo al que va a ir
            self.listen = False
            self.enable = False
            rate = self.rate
            mov = [0, 0]
            if (abs(self.target[0] - self.position[0]) in range(-100, 100)
                and abs(self.target[1] - self.position[1]) in range(-100, 100)):
                print("Y:   {}".format(abs(self.target[1] - self.position[1])))
                print("X:   {}".format(abs(self.target[0] - self.position[0])))
                if len(self.Filter()) != 0 and inn > 10000000:
                    print("stop")
                    print(inn)
                    print("FILTER {}".format(self.Filter()))
                    print(self.Filter())
                    self.stahp = False
                    break
                self.waiting = True
                pass
            else:
                self.waiting = False
                if self.angle_ref not in range(int(self.angle) - 10, int(self.angle) + 10):
                    self.rotar()
                    tb = abs(self.angle - self.angle_ref)
                    print("TO GO:   {}".format(tb))
                    if tb < 100:
                        time.sleep(0.1)
                    else:
                        time.sleep(0.2)
                if self.stahp and self.waiting is False:
                    inn += 1
                    if self.target[0] != 0:
                        if self.target[0] > self.position[0]:
                            mov[0] = rate
                        elif self.target[0] < self.position[0]:
                            mov[0] = -rate
                    if self.target[1] != 0:
                        if self.target[1] > self.position[1]:
                            mov[1] = rate
                        elif self.target[1] < self.position[1]:
                            mov[1] = -rate
                    if mov != [0, 0]:
                        self.cambiar_posicion(*mov)  # verificar que la posicion sea correcta
                        self.send("W")
                        time.sleep(0.05)
                        # if abs(self.position[0] - self.target[0]) >= 300 or abs(self.position[1] - self.target[1]) >= 300:
                        #     self.send("5")
                        # elif abs(self.position[0] - self.target[0]) >= 100 or abs(self.position[1] - self.target[1]) >= 100:
                        #     self.send("4")
                        # else:
                        self.send("3")
            self.listen = True
            self.enable = True
        pass

    def rotar(self):
        # Si queremos que vaya a la pelota:
        # angulo_pelota = math.atan(self.pos_pelota[1]/self.pos_pelota[0])
        a = time.time()
        if self.angle < self.angulo:  # para cuadrantes positivos
            print("ROTANDO HORARIO")
            self.send("A")
            # self.send("S")
        elif self.angle > self.angulo:  # para cuadrantes negativos
            print("RODANDO ANTIHORARIO")
            self.send("D")
            # self.send("S")
        b = time.time()
        time.sleep(0.05*(b - a))
        pass

if __name__ == '__main__':
    process = Processing()
