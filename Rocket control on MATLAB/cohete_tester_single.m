function [Kp_r, Kp_phi, Kp_theta, Kd_r, Kd_phi, Kd_theta, Ki_r, Ki_phi, Ki_theta, J_best, J_acum] =  cohete_tester_single(Kp_r_test, Kp_phi_test, Kp_theta_test, Kd_r_test, Kd_phi_test, Kd_theta_test, Ki_r_test, Ki_phi_test, Ki_theta_test, J_best, dm, dm2, low_mult, high_mult, high_mult2)
disp(" -------------- BEGIN ---------------")
x0 = [63/2 0 2000 0 0 0 0]; % r phi theta vr vphi vtheta
% [63/2 0.0001 0 100 1 1]; caso 1
% [63/2 0.0001 0 10 1 1]; caso 2
% [63/2 0.0001 0 50 0.1 0.1]; caso 3
% [63/2 0.1 0.1 50 10 10]; caso 4
% [63/2 0.0001 0.0001 100 1 1]; caso 5 SpaceX (peso real)
% [63/2 0.0001 0.0001 100 1 1]; caso 6 [SpaceX (peso combustible 2000 kg)]
% [63/2 0.05 0.05 0 1 1]; caso 7

%Tiempo de muestreo por defecto
Ts = 1;

%Tiempo de simulaci�n
Tmax = 200;

% maximos para tobera
utMax=5; % maximo empuje longitudinal


stopcode = 0;
stopcount = 0;


Ki_phi = Ki_phi_test;
Ki_theta = Ki_theta_test;
Ki_r = Ki_r_test;

Kd_phi = Kd_phi_test;
Kd_theta = Kd_theta_test;
Kd_r = Kd_r_test;

Kp_phi = Kp_phi_test; 
Kp_theta = Kp_theta_test; % KP_THETA;
Kp_r = Kp_r_test; % KP_R;

%Torques y fuerza iniciales
Uxr = 0; % 0.0001 entrada 1
Uyr = 0; % 0.0001 entrada 1
Ur = utMax;

%Primero se crean los sensores
sensores = NewSensors(Ts,Tmax,x0);

%Variables para guardar los valores leidos
valores = [];
phi = [];
r = [];
theta = [];
acu_phi = 0;
acu_theta = 0;
acu_r = 0;

e_phi = 0;
e_theta = 0;
e_r = 0;

e_phi_anterior = 0;
e_theta_anterior = 0;
e_r_anterior = 0;

phi_anterior = 0;
theta_anterior = 0;
r_anterior = 0;


Uxr_anterior = 0;
Uyr_anterior = 0;
Ur_anterior = 0;


% estos son los defaults a los que vuelve el controlador y desde los que
% inicia
set_phi = 0.0001*pi/180;
set_theta = 0.0001*pi/180;
set_r = 10000;    

J = 0;
J_acum = 0;
eject = 0;
for t_actual=0:Ts:Tmax
%     t_actual
    e_phi_anterior = (set_phi - phi_anterior)*180/pi;
    e_theta_anterior = (set_theta - theta_anterior)*180/pi;
    e_r_anterior = set_r - r_anterior;

    %Se actualizan los sensores y la planta
    %con los valores en los actuadores actuales

    if e_phi_anterior < 1 && e_theta_anterior < 1 && e_r_anterior < 1
        eject = 1;
    end
    sensores.update(t_actual,Ur, Uxr,Uyr, eject);
    if eject == 1
        eject = 0;
    end

    %Si se quieren ver por separado
    valores = sensores.read();
    phi_actual = valores(4);
    theta_actual = valores(5);
    r_actual = valores(3); % (3) dice r pero es solo z, la altura

    % errores de control
    e_phi = (set_phi - phi_actual)*180/pi;
    e_theta = (set_theta - theta_actual)*180/pi;
    e_r = set_r - r_actual;

    % errores acumulados
%                                         acu_phi = acu_phi + e_phi;
%                                         acu_theta = acu_theta + e_theta;
%                                         acu_r = acu_r + e_r;


    % anti wind up
    if abs(e_r) > 0.1
        acu_r = acu_r + e_r;
    end
    if abs(e_phi) > 0.1
        acu_phi = acu_phi + e_phi;
    end
    if abs(e_theta) > 0.1
        acu_theta = acu_theta + e_theta;
    end

%     
    Uxr = (Kp_phi*(e_phi) + Ki_phi*acu_phi + Kd_phi*((e_phi) - e_phi_anterior)/Ts);
    Uyr = Kp_theta*(e_theta) + Ki_theta*acu_theta + Kd_theta*((e_theta) - e_theta_anterior)/Ts;
    Ur = ((Kp_r*(e_r) + Ki_r*acu_r + Kd_r*((e_r) - e_r_anterior)/Ts))*(utMax*1/3);
%                                         Ur = 0;
%                                         disp(Ur)
    % variaciones de variables manipuladas
    d_a = (Uxr - Uxr_anterior);
    d_b = (Uyr - Uyr_anterior);
    d_f = (Ur - Ur_anterior);

    %Ejemplo para almacenar valores
    phi = [phi; phi_actual];
    theta = [theta; theta_actual];
    r = [r; r_actual];

    phi_anterior = phi_actual;
    theta_anterior = theta_actual;
    r_anterior = r_actual;

    Uxr_anterior = Uxr;
    Uyr_anterior = Uyr;
    Ur_anterior = Ur;
%     disp('b');

    %
    %pause
    if t_actual >= 0
        J = (abs((e_theta^2 + e_phi^2 + 0.02*e_r^2 + 0.2*10^(-13)*(((e_theta) - e_theta_anterior)/Ts) + 0.2*10^(-13)*(((e_phi) - e_phi_anterior)/Ts) + 0.2*10^(-8)*(((e_r) - e_r_anterior)/Ts))) + abs(e_phi*0.2 + e_theta*0.4 + e_r*0.4))/2 ;
        J_acum = J_acum + J;
    end
end
disp(J_acum)
if (abs(J_acum) < J_best) && (abs(J_acum) <= 3e+07)
    %Graficando 
    close();
    disp(" ---------------------------------- ")
    disp(J_acum)
    disp([Kp_r Kp_phi Kp_theta Kd_r Kd_phi Kd_theta Ki_r Ki_phi Ki_theta])
    disp([Ur Uyr Uxr])
    disp([e_r acu_r])
    plot((phi)*180/pi); title('Elevacion [grados]')
    figure; plot(theta*180/pi); title('Azimut [grados]')
    figure; plot(r);  title('Desplazamiento en eje z (Altura) [m]')

    J_best = J_acum;

    pause(3)
    close()
end




