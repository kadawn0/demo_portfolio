clear all
close all
clc

M0 = 2000;   % masa inicial  
Mcarga = 300;   % masa carga 300 kg 

% variables de estado iniciales
x0(1)=0;  % z
x0(2)=0;  % vz
x0(3)=M0; % M
x0(4)=90*pi/180;  % phi
x0(5)=0;    % theta
x0(6)=0;    % w_phi
x0(7)=0;    % w_theta
x0(8)=0;
x0(9)=0;

% x=x0;
Tf=5000; % tiempo total de simulaci�n
dT=0.1; % tiempo de muestreo para ciclo discreto de control
T=[]; % vector que guarda los tiempos de simulacion
X=[]; % vector que guarda los outputs de ODE23 para graficar cada parametro

% posicion absoluta en espacio inicial
px=0; py=0; pz=0; 

% setpoints iniciales para angulos de actitud del cohete 
PhiSP=90*pi/180;
ThetaSP=90*pi/180;

% -------------- setopints en coordenadas cartesianas ------------------
set_x = 5000;
set_y = 1000;
set_z = 10000;

AlturaSP = set_z;

% inicializacion de error de control de angulos de actitud del cohete
errPhi=0;
errTheta=0;
errR=0;

% inicializacion de vectores de registro de datos
X=zeros(fix(Tf/dT),9);
T=zeros(fix(Tf/dT),1);

g0 = 9.8065; % gravedad

ganancia_tobera = 1.001; % multiplicador empirico de ganancia para el controlador PD en Theta
Kp=0.5  *ganancia_tobera; %0.5
Kd=6.5  *ganancia_tobera; %1.2

% constantes del controlador PD de Phi
Kd_phi = 1.5; %2.4*1.01;  1.5
Kp_phi = 0.5; % 0.5

Kp_impulso = 1;
Kd_impulso = 1;
dm=3;

% constantes base para el controlador PID + prealimentación en altura
constD = 1.25; % constante del término derivativo
constP = 0.12; % constante del término proporcional
Ki= 500*10^(-10); % constante del integrador
preK =  0.00011; % constante de la constante de prealimentación
nr = 0.0000001; % factor de decaimiento exponencial

% constantes del controlador PD de la velocidad de aterrizaje
Kp_vel = 0.12;
Kd_vel = 1.25;

% definicion vectores de graficos finales
X=zeros(fix(Tf/dT),9);
T=zeros(fix(Tf/dT),1);
setphi=zeros(fix(Tf/dT),1);

M0 = 2000;   % masa inicial  
Mcarga = 300;   % masa carga 300 kg 

% variables de estado iniciales
x0(1)=0;  % z
x0(2)=0;  % vz
x0(3)=M0; % M
x0(4)=90*pi/180;  % phi
x0(5)=0;    % theta
x0(6)=0;    % w_phi
x0(7)=0;    % w_theta
x0(8)=0;    % delay en phi
x0(9)=0;    % delay en theta

% variables auxiliares de controladores
d_r=0;
u_ant=0;
vel_ant=0;
errvel=0;
acum_z=0;
d_errvel=0;
ref = 0;
ut_f = 1;
set_final = 0;

% tolerancia de distancia a la que se está del setpoint para considerar que
% se llegará a este
tolerance = min(300, (set_x+set_y+set_z)*0.02);

% flags de estado
fase2=0;
flag=0;
finalstage=0;

% flag de que se suelta la carga al llegar al setpoint
sueltacarga=0;

finish=0;
goal = 0;
flagg = 0;
landing = 0;
last_t = 0;

% puntos en el gráfico
p1 = 0;
p2 = 0;
p3 = [0 0 0]; 

% modo de operacion. Si esto es cero entonces al llegar al setpoint se hace
% el aterrizaje suave. En caso contrario, hace caída libre.
caidalibre = 0;


for iter=2:fix(Tf/dT)
	% ***************CALCULO SETPOINTS INCREMENTALES**********************
    if flagg==0 % ascenso hacia setpoint
        % actualizar el ángulo de elevación objetivo
        directive = wrapTo2Pi(atan(sqrt((set_x-px(iter-1))^2 + (set_y-py(iter-1))^2)/(set_z-pz(iter-1)) ));
        
        % transformar a coordenadas de elevación dadas en el enunciado del
        % proyecto
        if directive >= 0
            directive = pi/2-directive;
        end
        if directive < 0
            directive = directive+pi/2;
        end
        PhiSP = directive;
        
        % actualizar setpoints en z y en theta (el de z es solo
        % referencial, no se usa en el cálculo del error)
        ThetaSP = wrapTo2Pi(atan((set_y-py(iter-1))/(set_x-px(iter-1))));
        AlturaSP = sqrt((set_y-py(iter-1))^2 + (set_y-py(iter-1))^2 + (set_z-pz(iter-1))^2);
    else % etapas de descenso controlado
        if landing == 0 % controlador en base a energía cinética
            set_z = set_z*(1 + 0.000000015*errvel*( ((pz(iter-1)+1)*1)/(ref*1000) ) );
            if (pz(iter-1) > ref*0.88)
                % actualizar el ángulo de elevación objetivo
                directive = wrapTo2Pi(atan(sqrt((set_x-px(iter-1))^2 + (set_y-py(iter-1))^2)/(set_z-pz(iter-1)) ));
            else
                landing = 1;
            end
        else % controlador en base a velocidad en coordenada cartesiana z
            if (x0(end,2) < 50) % se calcula con este setpoint cuando la velocidad es baja
                set_z = set_z*0.997*(1 + 0.00011*(-x0(end,2)) + 0.005*( ref/((pz(iter-1)+1)*1000) ) );
            end
            % actualizar el ángulo de elevación objetivo
            directive = wrapTo2Pi(atan(sqrt((set_x-px(iter-1))^2 + (set_y-py(iter-1))^2)/(1e10-pz(iter-1)) ));
        end
        % transformar a coordenadas de elevación dadas en el enunciado del
        % proyecto
        if directive >= 0
            directive = pi/2-directive;
        end
        if directive < 0
            directive = directive+pi/2;
        end
        PhiSP = directive; 
        
        % actualizar setpoints en z y en theta (el de z es solo
        % referencial, no se usa en el cálculo del error)
        ThetaSP = wrapTo2Pi(atan((set_y-py(iter-1))/(set_x-px(iter-1))));
        AlturaSP = sqrt((set_y-py(iter-1))^2 + (set_y-py(iter-1))^2 + (set_z-pz(iter-1))^2);
    end
    % ***************CONTROLADOR**********************
    errPhi_old=errPhi;

    % error en phi
    errPhi=PhiSP-x0(4);
%             disp(errPhi)

    % derivada para error en phi
    evPhi=(errPhi-errPhi_old)/dT;

    % theta
    errTheta_old=errTheta;

    % error en theta
    errTheta=ThetaSP-x0(5);

    % derivada para error en theta
    evTheta=(errTheta-errTheta_old)/dT;

    % altura
    errR_old=errR;

    % error en altura
    errR= (set_z - pz(iter-1)); %AlturaSP-x0(1);

    acum_z = acum_z + errR; % error en altura acumulado

    % derivada para error en phi
    evR=(errR-errR_old)/dT;

    % nuevas constantes variables para el lazo de altura
    Kp_impulso = constP*(abs(errR)/10000);
    Kd_impulso = constD*(abs(errR)/10000);

    Kd_ur = Kd_impulso*1.5;

    if flag==0
        if ((set_z - pz(iter-1)) > set_z*0.5)&&(fase2==0)
            ut=5; % se asciende a media velocidad para entregar al controlador un cohete menos descontrolado
            ux=0;
            uy=0;
            disp("ASCENDIENDO...")
        else
            if fase2 == 0
                fase2=1;
                p1=[px(iter-1) py(iter-1) pz(iter-1)]; % guardar punto donde termina el ascenso
                disp(" === TÉRMINO DE ASCENSO ===")
            end
        end
        
        if fase2==1
            % variables manipuladas para angulo de toberas
            ux=Kp_phi*errPhi+Kd_phi*evPhi  + 0.2*preK*x0(end,3)*g0*sin(x0(end,4)) ; %rad
            uy=Kp*errTheta+Kd*evTheta; %rad
            integral = Ki*acum_z;
            if integral > 0.5 % saturar el término integral en 0.5
                integral = 0.5;
            end
            
            % control hacia setpoint
            if (((abs(set_z - pz(iter-1)) > tolerance)&&((set_z - pz(iter-1)) > 0))||((abs(set_y - py(iter-1)) > tolerance))||((abs(set_x - px(iter-1)) > tolerance)))&&(flagg==0)
                ut=Kp_impulso*errR+Kd_impulso*exp(-iter*nr)*evR + integral + Kd_ur*d_r  + preK*x0(end,3)*g0*sin(x0(end,4)); % controlador para llegar a setpoint, con tolerancia = tolerance
            else
                if caidalibre==0 
                    if landing == 0 % control por energía cinética
                        k = 0.5*x(end,3)*(sqrt((x(end,2))^2 + (x(end,6))^2 + (x(end, 7))^2  ))^2;
                        errvel = -k;
                        d_errvel = errvel - vel_ant;

                        uy = 0; % el cohete no se mueve en la coordenada esférica theta
                        ut=(Kp_impulso*errR+Kd_impulso*exp(-iter*nr)*evR + 0.000003*errvel)*0.1; % controlador de energía cinética
                        
                        if flagg == 0
                            flagg = 1;
                            ref = pz(iter-1); % guardar como referencia la altura alcanzada en el setpoint donde se suelta la carga
                            p2=[px(iter-1) py(iter-1) pz(iter-1)]; % guardar punto donde se llega a setpoint
                            disp("------ LLEGADA A SETPOINT ------")
                            x0(end,3) = x0(end,3) - Mcarga; % soltar la carga
                            disp(last_t)
                            disp([px(iter-1) py(iter-1) pz(iter-1)])
                        end
                        
                    else % control por velocidad en coordenada z, justo antes de efectivamente aterrizar sobre la superficie terrestre
                        disp("Landing...")
                        disp([x(end,2) x(end,4)*180/pi])
                        disp(errR)

                        uy = 0; % 0.3*pi/180;
                        if pz(iter-1) > 16 % control de velocidad suave
                            ut= Kp_impulso*errR+Kd_impulso*exp(-iter*nr)*evR + 0.0000000001*(-x(end,2)) ;
                        else % fase final de contacto con la tierra
                            ut=ut*0.99;
                        end
                        disp("----------------------------")
                        disp([PhiSP set_z pz(iter-1)])
                        disp([ux uy ut])

                        if x(end,2) <= 10
                            p3=[px(iter-1) py(iter-1) pz(iter-1)];
                        end

                        if (pz(iter-1) <= 0)
                            goal=1;
                            disp(" -------- CRASHED SUCCESFULLY -------- ")
                            disp(last_t)
                            disp([px(iter-1) py(iter-1) pz(iter-1)])
                        end
                    end
                else % caída libre
                    if flagg == 0
                        flagg = 1;
                        ref = pz(iter-1);
                        p2=[px(iter-1) py(iter-1) pz(iter-1)];
                        p3=[px(iter-1) py(iter-1) pz(iter-1)];
                        disp("------ LLEGADA A SETPOINT ------")
                        x0(end,3) = x0(end,3) - Mcarga;  % soltar la carga
                        disp(last_t)
                        disp([px(iter-1) py(iter-1) pz(iter-1)])
                    end
                    % mantener todas las variables de control en cero
                    ut = 0;
                    ux = 0;
                    uy = 0;
                    if (pz(iter-1) <= 0)
                        goal=1;
                        disp(" -------- CRASHED SUCCESFULLY -------- ")
                        disp(last_t)
                        disp([px(iter-1) py(iter-1) pz(iter-1)])
                    end
                end
            end
        end
    end

    d_r = ut - u_ant;
    % ************************************************
    % ********   integracion numerica variables cohete   ***********
    options=odeset('RelTol',1e-4,'AbsTol',1e-6);
    [t,x]=ode23(@(t,x) cohete_modelov2(t,x,ut,ux,uy),[0 dT],x0,options);

    % paso a coordenadas absolutas px, py, pz
    px(iter)=px(iter-1)+x(end,2)*cos(x(end,4))*cos(x(end,5))*dT;
    py(iter)=py(iter-1)+x(end,2)*cos(x(end,4))*sin(x(end,5))*dT;
%             disp(x)

    aux=pz(iter-1)+x(end,2)*sin(x(end,4))*dT;
    if aux < 0 % limitar z a valores positivos o cero, pues el cohete no excava la tierra
        aux=0;
    end
    pz(iter)=aux;
    
    % actualizar vectores con valores relevantes
    T=[T;t+dT*(iter-1)];
    X=[X;x];
    x0=x(end,:);
    u_ant = ut;
    vel_ant= errvel;

    if goal==1
        break
    end
    last_t = t+dT*(iter-1);
end

% graficar los resultados de la simulación actual
disp("=================================")
figure; plot((1:iter)*dT,pz/1000); title('h (altura absoluta, Km)'); xlabel('tiempo, seg');
figure; plot(T,X(:,2));  title('vel longitudinal, m/s'); xlabel('tiempo, seg');
figure; plot(T,X(:,3)); title('masa, Kg'); xlabel('tiempo, seg');
figure; plot(T,[X(:,4) X(:,5)]*180/pi); title('phi y theta, grados'); xlabel('tiempo, seg'); legend("Phi(t)", "Theta(t)");
%             figure; plot(setphi*180/pi); title('Setpoint de elevación');
figure; hold on; plot3(px/1000,py/1000,pz/1000); title('trayectoria 3D (coordenadas absolutas)');
h = scatter3(p1(1)/1000,p1(2)/1000,p1(3)/1000,'filled');
h.SizeData = 150;
h1 = scatter3(p2(1)/1000,p2(2)/1000,p2(3)/1000,'filled');
h1.SizeData = 150;
h2 = scatter3(p3(1)/1000,p3(2)/1000,p3(3)/1000,'filled');
h2.SizeData = 150;
grid
xlabel('km');ylabel('km');zlabel('altitude, km');
hold off;
%             pause(10)
%             close();