# Python Program - Print ASCII Values

import datetime
import management as manager


class UI:
    def __init__(self):
        print("\033[1m" + " (⊙ω⊙) (─‿‿─) Bienvenido a Superluchín (─‿‿─) (⊙ω⊙) \n")
        self.baseusers = []
        self.admins = []
        self.tester = str(input("\033[0m" + "Es usted un Tester de Superluchín? Si/No"))
        if "Si" == self.tester.strip():
            print("Superluchín mostrará información confidencial de las bases de datos.")
        # else:
        #   print("ASCII Art activado.- PEP8 no al 100% -")
        print("    === Ingrese su nombre de usuario y clave: ===")
        self.usuario = str(input("Usuario: ")).strip("\n")
        self.autenticaciones = 0
        self.cambiosfecha = 0
        self.fechas = []
        self.adminsession = False
        m = 0
        userbase = open("usuarios.csv", encoding="utf8")
        for line in userbase:
            dato = line.strip().split(",")
            self.baseusers.append(dato)
            if dato[3] == "":
                self.admins.append(dato)
        userbase.close()
        for datos in self.baseusers:
            if datos[1].strip("'") == self.usuario:
                m = 1
                for user in self.admins:
                    if self.usuario == user[1]:
                        self.adminsession = True
                if self.tester.strip() == "Si":
                    print("La clave de este usuario es: " + datos[2])
                self.clave = input("Clave: ")
                n = 0
                if datos[2].strip("'").strip() == self.clave.strip():
                    print("Bienvenido " + self.usuario)
                    if self.adminsession:
                        print("Usted se la logueado como ADMINISTRADOR ☚(ﾟヮﾟ☚)")
                    print("")
                    n = 1
                    self.landing()
                if n == 0:
                    print("Clave incorrecta")
                    self.clave = ""
                    self.usuario = ""
                    self.auth()
        if m == 0:
            print("Usuario no existe")
            self.clave = ""
            self.usuario = ""
            self.auth()

    def auth(self):
        self.autenticaciones += 1
        if self.autenticaciones > 10:
            print("Parece que ha fallado la autenticación, volviendo al menú principal")
            self.landing()
            return
        self.usuario = str(input("Usuario: ")).strip("\n").strip()
        m = 0
        for line in self.baseusers:
            if line[1].strip("'").strip() == self.usuario:
                m = 1
                if self.tester.strip() == "Si":
                    print("La clave de este usuario es: " + line[2])

                self.clave = input("Clave: ")
                n = 0

                if line[2].strip("'").strip() == self.clave.strip():
                    print("Bienvenido " + self.usuario)
                    print("")
                    n = 1
                    self.landing()
                if n == 0:
                    print("Clave incorrecta, ingrese datos nuevamente")
                    self.auth()
        if m == 0:
            print("Usuario no existe, ingrese datos nuevamente")
            self.clave = ""
            self.auth()

    def gettime(self):
        listafecha = []
        date = str(datetime.datetime.now()).split(".")
        date = date[0]
        listafecha.append(date)
        print("Fecha y hora: " + date)
        self.fechas = listafecha
        return listafecha

    def cambiofecha(self):
        self.cambiosfecha += 1
        if self.cambiosfecha > 10:
            print("Parece que ha fallado el cambio de fecha, volviendo al menú principal")
            self.landing()
            return
        listafecha = self.fechas
        año = input("Año: ")
        if any(char.isdigit() for char in año):
            mes = input("Mes: ")
            if any(char.isdigit() for char in mes) and (mes.strip() <= "12"):
                dia = input("Día: ")
                if any(char.isdigit() for char in dia) and (dia.strip() <= "31"):
                    hora = input("Hora: ")
                    if any(char.isdigit() for char in hora) and (hora.strip() < "24"):
                        minutos = input("Minutos: ")
                        if any(char.isdigit() for char in minutos) and (minutos.strip() <= "59"):
                            segundos = input("Segundos: ")
                            if any(char.isdigit() for char in segundos) and (segundos.strip() <= "59"):
                                self.fechas.append(str(datetime.datetime(int(año), int(mes), int(dia), int(hora), int(minutos), int(segundos))))
                                print("Fecha y hora: " + self.fechas[len(listafecha)-1])
                                self.landing()
                            else:
                                print("Ingrese segundos válidos")
                                self.cambiofecha()
                        else:
                            print("Ingrese minutos válidos")
                            self.cambiofecha()
                    else:
                        print("Ingrese una hora válida")
                        self.cambiofecha()
                else:
                    print("Ingrese un día válido")
                    self.cambiofecha()
            else:
                print("Ingrese un mes válido")
                self.cambiofecha()
        else:
            print("Ingrese un año válido")
            self.cambiofecha()

    def landing(self):
        print("=======  Superluchín  ========\nʕ•ᴥ•ʔ ʕ•ᴥ•ʔ ʕ•ᴥ•ʔ ʕ•ᴥ•ʔ ʕ•ᴥ•ʔ \n")
        if self.adminsession:
            print(self.usuario + "    ADMINISTRADOR")
        else:
            print(self.usuario + "    MIEMBRO")
        if self.cambiosfecha == 0:
            self.gettime()
        else:
            print("Fecha y hora: " + self.fechas[len(self.fechas)-1])
        print("AVISO: Todas la gestión de información se hace a través de Putintanker Manager\n")
        print("***** MENÚ *****\n")
        select = input("\n1)Cambiar usuario\n2)Cerrar sesión\n3)Cambiar fecha\n4)Acceder a Putintanker Manager\n")
        if select.strip() == "1":
            self.auth()
        elif select.strip() == "2":
            print("Gracias por usar Superluchín")
        elif select.strip() == "3":
            self.cambiofecha()
        elif select.strip() == "4":
            print("Inicializando Putintanker")
            putin = manager.PutinTanker(self.usuario, self.clave, self.fechas, self.baseusers, self.adminsession, self.tester)
        else:
            print("Selección inválida, inténtelo de nuevo")
            self.landing()

ui = UI()
