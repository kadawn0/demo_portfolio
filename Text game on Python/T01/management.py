import planificacion as planner


class PutinTanker:

    def __init__(self, usuario, clave, fechas, base, admin, tester):
        print(" d(>_・ ) PutinTanker Manager d(>_・ ) ")
        self.sesion = {"usuario": usuario, "clave": clave, "fechas": fechas}
        self.baseusuarios = base
        self.baserecursos = []
        self.baseincendios = []
        self.basemetereologia = []
        self.resumen = self.cargar_bases()
        self.permisos = Persona(self.sesion["usuario"], self.baseusuarios, self.baserecursos, self.baseincendios)
        self.permisos.leer_cometido(self.baseusuarios, self.baserecursos)
        self.permisos.asignar_miembro()
        self.menus()

    def menus(self):
        if self.permisos.tipo.strip() == "jefe":
            jefe = Jefe(self.sesion["usuario"], self.baseusuarios, self.baserecursos, self.baseincendios)
            jefe.leer_cometido(self.baseusuarios, self.baserecursos)
            print("\n||||  === Recurso asignado: === ID: " + jefe.recurso[0] + " Tipo: " + jefe.recurso[
                1] + " Latitud: " + jefe.recurso[2] + " Longitud: " + jefe.recurso[3] + " Velocidad: " + jefe.recurso[
                      4] + " Autonomía: " + jefe.recurso[5] + " Delay: " + jefe.recurso[6] + " Tasa de extinción: " +
                  jefe.recurso[7] + "===  ||||")
            select = input(" === MENÚ JEFE === \n1)Información sobre incendio\n2)Información sobre recurso")

            if select.strip() == "1":
                print("Usted está en standby, no tiene incendio que apagar.")
                # print("ID: " + jefe.incendio.id + "LATITUD: " + jefe.incendio.latitud + "LONGITUD: " +  jefe.incendio.longitud + "\nPOTENCIA: " + jefe.incendio.potencia + "FECHA INICIO: " jefe.incendio.fecha_inicio)
            elif select.strip() == "2":
                print("\n === Recurso asignado: === \nID: " + jefe.recurso[0] + "\nTipo: " + jefe.recurso[1] + "\nLatitud: " + jefe.recurso[2])
                print("Longitud: " + jefe.recurso[3] + "\nVelocidad: " + jefe.recurso[4])
                print("Autonomía: " + jefe.recurso[5] + "\nDelay: " + jefe.recurso[6] + "\nTasa de extinción: " + jefe.recurso[7] + "\n\n<ΦωΦ><ΦωΦ><ΦωΦ>")
                self.menus()
        elif self.permisos.tipo.strip() == "piloto":
            piloto = Piloto(self.sesion["usuario"], self.baseusuarios, self.baserecursos, self.baseincendios)
            piloto.leer_cometido(self.baseusuarios, self.baserecursos)
            print("\n||||  === Recurso asignado: === ID: " + piloto.recurso[0] + " Tipo: " + piloto.recurso[
                1] + " Latitud: " + piloto.recurso[2] + " Longitud: " + piloto.recurso[3] + " Velocidad: " + piloto.recurso[
                      4] + " Autonomía: " + piloto.recurso[5] + " Delay: " + piloto.recurso[6] + " Tasa de extinción: " +
                  piloto.recurso[7] + "===  ||||")
            select = input(" === MENÚ PILOTO === \n1)Información sobre incendio\n2)Información sobre recurso")

            if select.strip() == "1":
                print("Usted está en standby, no tiene incendio que apagar.")
                # print("ID: " + jefe.incendio.id + "LATITUD: " + jefe.incendio.latitud + "LONGITUD: " +  jefe.incendio.longitud + "\nPOTENCIA: " + jefe.incendio.potencia + "FECHA INICIO: " jefe.incendio.fecha_inicio)
            elif select.strip() == "2":
                print("\n === Recurso asignado: === \nID: " + piloto.recurso[0] + "\nTipo: " + piloto.recurso[1] + "\nLatitud: " + piloto.recurso[2])
                print("Longitud: " + piloto.recurso[3] + "\nVelocidad: " + piloto.recurso[4])
                print("Autonomía: " + piloto.recurso[5] + "\nDelay: " + piloto.recurso[6] + "\nTasa de extinción: " + piloto.recurso[7] + "\n\n<ΦωΦ><ΦωΦ><ΦωΦ>")
                self.menus()
        elif self.permisos.tipo.strip() == "anaf":
            anaf = Admin(self.sesion["usuario"], self.baseusuarios, self.baserecursos, self.baseincendios)
            anaf.leer_cometido(self.baseusuarios, self.baserecursos)
            selecting = input("\n === MENÚ ADMINISTRADOR === \n0) Mostrar usuarios\n1) Mostrar incendios\n2) Mostrar recursos\n3) Crear usuario\n4) Añadir pronóstico del tiempo\n5) Añadir incendio\n6) Entrar a planificador")
            if selecting.strip() == "0":
                print("\n=== BASE DE DATOS DE USUARIOS ===")
                print("ID   //   Nombre   //   Contraseña   //   Recurso   //")
                for usuario in self.baseusuarios:
                    tstr = ""
                    for info in usuario:
                        tstr += info+"  "
                    print(tstr)
                self.menus()
            elif selecting.strip() == "1":
                print(self.baseincendios)
                print("\n=== BASE DE DATOS DE INCENDIOS ===")
                print("ID   //   Latitud   //   Longitud   //   Fecha de inicio   //")
                for incendio in self.baseincendios:
                    tstr = ""
                    for info in incendio:
                        tstr += info+"  "
                    print(tstr)
                self.menus()
            elif selecting.strip() == "2":
                print("\n=== BASE DE DATOS DE RECURSOS ===")
                print("ID   //   Tipo   //   Latitud   //   Longitud   //   Velocidad   //   Autonomía   //   Delay   //   Tasa de extinción   //")
                for recurso in self.baserecursos:
                    rstr = ""
                    for info in recurso:
                        rstr += info + "  "
                    print(rstr)
                self.menus()
            elif selecting.strip() == "3":
                self.baseusuarios = anaf.crear_usuario(self.baseusuarios)
                self.menus()
            elif selecting.strip() == "4":
                self.basemetereologia = anaf.agregar_pronostico(self.basemetereologia)
                self.menus()
            elif selecting.strip() == "5":
                self.baseincendios = anaf.agregar_incendio(self.baseincendios)
                self.menus()

    def cargar_bases(self):
        recursos = open("recursos.csv", mode="r", encoding="utf8")
        for line in recursos:
            dato1 = line.strip().split(",")
            self.baserecursos.append(dato1)
        recursos.close()
        incendios = open("incendios.csv", mode="r", encoding="utf8")
        for line in incendios:
            dato2 = line.strip().split(",")
            self.baseincendios.append(dato2)
        incendios.close()
        metereologia = open("meteorologia.csv", mode="r", encoding="utf8")
        for line in metereologia:
            dato3 = line.strip().split(",")
            self.basemetereologia.append(dato3)
        metereologia.close()
        crossbase = {"usuarios": self.baseusuarios, "recursos": self.baserecursos, "incendios": self.baseincendios, "metereología": self.basemetereologia}
        return crossbase


class Persona:
    def __init__(self, usuario, base, recursos, incendios):
        self.nombre = usuario
        self.ID = ""
        self.recurso = ""
        self.tipo = ""
        self.latitud = ""
        self.longitud = ""
        self.velocidad = ""
        self.costo = ""
        self.tasa = ""
        self.autonomia = ""
        self.delay = ""

        self.incendio_datos = dict()
        self.incendio = ""
        self.incendios = incendios
        self.estado = "standby"

        self.leer_cometido(base, recursos)

    def leer_cometido(self, base, recursos):
        for dato in base:
            if dato[1] == self.nombre:
                self.ID = dato[0]
                self.recurso = dato[3]
        for recurso in recursos:
            if self.recurso == recurso[0]:
                self.recurso = recurso
                self.latitud = recurso[2]
                self.longitud = recurso[3]
                self.velocidad = recurso[4]
                self.autonomia = recurso[5]
                self.delay = recurso[6]
                self.tasa = recurso[7]
                self.costo = recurso[8]
                return

    def asignar_miembro(self):
        print(self.recurso)
        if self.recurso != "":
            if self.recurso[1] in ["HELICOPTERO", "AVION"]:
                self.tipo = "piloto"
            elif self.recurso[1] in ["BOMBEROS", "BRIGADA"]:
                self.tipo = "jefe"
        else:
            self.tipo = "anaf"

    def movilizarse(self, destino):
        self.estado = "movilizado"
        n = 0
        for incendio in self.incendios:
            if destino == incendio[0]:
                for i in range(0, 4):
                    n += 1
                    self.incendio_datos["a" + str(n)] = incendio[i]
                    self.incendio = Incendio(**self.incendio_datos)
                    print("Jefe " + self.nombre + "ha sido movilizado al incendio " + self.incendio.id)
    # def agregar_usuario(self):


class Incendio:
    def __init__(self, a1, a2, a3, a4, a5):
        self.id = a1
        self.latitud = a2
        self.longitud = a3
        self.potencia = a4
        self.fecha_inicio = a5


class Jefe(Persona):
    def __init__(self, usuario, base, recursos, incendios):
        Persona.__init__(self, usuario, base, recursos, incendios)
        self.leer_cometido(base, recursos)

    def movilizarse(self, destino):
        self.movilizarse(destino)


class Piloto(Persona):
    def __init__(self, usuario, base, recursos, incendios):
        Persona.__init__(self, usuario, base, recursos, incendios)
        self.leer_cometido(base, recursos)

    def movilizarse(self, destino):
        self.movilizarse(destino)


class Admin(Persona):
    def __init__(self, usuario, base, recursos, incendios):
        Persona.__init__(self, usuario, base, recursos, incendios)
        self.leer_cometido(base, recursos)

    def actualizar_base(self, nombrebase):
        basea = open(str(nombrebase)+".csv", mode="r", encoding="utf8")
        baseb = []
        for line in basea:
            dato = line.strip().split(",")
            baseb.append(dato)
        return baseb

    def crear_usuario(self, base):
        basedatos = open("usuarios.csv", mode="a", encoding="utf8")
        print(len(base))
        iid = len(base)-1
        user = input("Nombre de nuevo usuario: ")
        clave = input("Clave de nuevo usuario: ")
        recurso = input("Número de recurso asignado - Enter para administrador: ")
        for us in base:
            if recurso == us[3] and recurso != " " and recurso != "":
                print("Recurso ya existe, ingrese un número distinto")
                self.crear_usuario(base)
            # elif recurso == " ":
            #    recurso = ""
            elif user == us[1]:
                print("Usuario ya existe, ingrese otro")
                self.crear_usuario(base)
        stra = ",".join([str(iid), str(user), str(clave), str(recurso)+"\n"])
        basedatos.write(stra)
        basedatos.close()
        return self.actualizar_base("usuarios")

    def agregar_pronostico(self, metereologia):
        basemeter = open("meteorologia.csv", mode="a", encoding="utf8")
        iid = len(metereologia)-1
        fecha_inicio = input("Ingrese fecha de inicio del pronóstico: ")
        fecha_termino = input("Ingrese su fecha de término")
        tipo = input("Ingrese el tipo de pronóstico: ")
        valor = input("Ingrese el valor del pronóstico: ")
        lat = input("Ingrese la latitud")
        lon = input("Ingrese la longitud")
        radio = input("Ingrese el radio del pronóstico")
        sstr = ",".join([str(iid), str(fecha_inicio), str(fecha_termino), str(tipo), str(valor), str(lat), str(lon), str(radio)+"\n"])
        basemeter.write(sstr)
        basemeter.close()
        return self.actualizar_base("meteorologia")

    def agregar_incendio(self, base):
        baseinc = open("incendios.csv", mode="a", encoding="utf8")
        iid = len(base)-1
        lat = input("Ingrese la latitud")
        lon = input("Ingrese la longitud")
        potencia = input("Ingrese el radio del pronóstico")
        fecha_inicio = input("Ingrese la fecha de inicio")
        dstr = ",".join([str(iid), str(lat), str(lon), str(potencia), str(fecha_inicio)+"\n"])
        baseinc.write(dstr)
        baseinc.close()
        return self.actualizar_base("incendios")