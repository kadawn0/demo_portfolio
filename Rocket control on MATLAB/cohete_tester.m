function [Kp_globalr, Kd_globalr, Kp_globalp, Kd_globalp, Kp_globalt, Kd_globalt] =  cohete_tester(kp_l, kd_l, kp_h, kd_h, dm3, Kp_r_test, Kp_phi_test, Kp_theta_test, Kd_r_test, Kd_phi_test, Kd_theta_test, Ki_r_test, Ki_phi_test, Ki_theta_test, J_best, dm, dm2, low_mult, high_mult, high_mult2)
% [Kp_r, Kp_phi, Kp_theta, Kd_r, Kd_phi, Kd_theta, Ki_r, Ki_phi, Ki_theta, J_best]
disp(" -------------- BEGIN ---------------")
x0 = [63/2 0 2000 90*pi/180 0 0 0 0 0]; % r phi theta vr vphi vtheta
% [63/2 0.0001 0 100 1 1]; caso 1
% [63/2 0.0001 0 10 1 1]; caso 2
% [63/2 0.0001 0 50 0.1 0.1]; caso 3
% [63/2 0.1 0.1 50 10 10]; caso 4
% [63/2 0.0001 0.0001 100 1 1]; caso 5 SpaceX (peso real)
% [63/2 0.0001 0.0001 100 1 1]; caso 6 [SpaceX (peso combustible 2000 kg)]
% [63/2 0.05 0.05 0 1 1]; caso 7

%Tiempo de muestreo por defecto
Ts = 0.1;

%Tiempo de simulaci�n
Tmax = 150;

% maximos para tobera
utMax=10; % maximo empuje longitudinal
% 
% Ki_phi_c = 0;
% Ki_theta_c = 0;
% Ki_r_c = 0;
% 
% Kd_phi_c = 0;
% Kd_theta_c = 0;
% Kd_r_c = 0;
% 
% Kp_phi_c = 0; 
% Kp_theta_c = 0;
% Kp_r_c = 0;

stopcode = 0;
stopcount = 0;

set_vz = 500;

% for KI_R=Ki_r_test*low_mult :(Ki_r_test*high_mult - Ki_r_test*low_mult)/dm:Ki_r_test*high_mult
%     for KI_PHI=Ki_phi_test*low_mult :(Ki_phi_test*high_mult - Ki_phi_test*low_mult)/dm:Ki_phi_test*high_mult
%         for KI_THETA=Ki_theta_test*low_mult :(Ki_theta_test*high_mult - Ki_theta_test*low_mult)/dm2:Ki_theta_test*high_mult

% for KP_THETA=Kp_theta_test*low_mult :(Kp_theta_test*high_mult - Kp_theta_test*low_mult)/dm2:Kp_theta_test*high_mult
%     for KP_R= Kp_r_test*low_mult :(Kp_r_test*high_mult - Kp_r_test*low_mult)/dm:Kp_r_test*high_mult
%         for KP_PHI= Kp_phi_test*low_mult :(Kp_phi_test*high_mult - Kp_phi_test*low_mult)/dm:Kp_phi_test*high_mult
%             for KD_R=Kd_r_test*low_mult:(Kd_r_test*high_mult2 - Kd_r_test*low_mult)/dm2:Kd_r_test*high_mult2
%                 for KD_PHI=Kd_phi_test*low_mult:(Kd_phi_test*high_mult2 - Kd_phi_test*low_mult)/dm2:Kd_phi_test*high_mult2
%                     for KD_THETA=Kd_theta_test*low_mult :(Kd_theta_test*high_mult2 - Kd_theta_test*low_mult)/dm2:Kd_theta_test*high_mult2   

for Kp_globalt= -Kp_theta_test*high_mult :(Kp_theta_test*high_mult*2)/dm2:Kp_theta_test*high_mult
    for Kp_globalr= -Kp_r_test*high_mult :(Kp_r_test*high_mult*2)/dm:Kp_r_test*high_mult
        for Kp_globalp= -Kp_phi_test*high_mult :(Kp_phi_test*high_mult*2)/dm:Kp_phi_test*high_mult
            for Kd_globalr= - Kd_r_test*high_mult2:(Kd_r_test*high_mult2*2)/dm2:Kd_r_test*high_mult2
                for Kd_globalp= -Kd_phi_test*high_mult2:(Kd_phi_test*high_mult2*2)/dm2:Kd_phi_test*high_mult2
                    for Kd_globalt= -Kd_theta_test*high_mult2  :(Kd_theta_test*high_mult2*2)/dm2:Kd_theta_test*high_mult2     
                        for m_r = 0:1:5
                            for m_phi = 0.5:0.5:1
                                for m_theta = 0:1:6    
%                                     for multr = 0:0.1:0.1
%                                         for multr1 = 0:0.1:0.1
%                                             for multr2 = 0:0.1:0.1
                                    for Kp_vel = -1:1:1
                                        for Kd_vel = -1:1:1
                                            for multvel = 0:0.5:1
                                                for Kd_ur = -100:100:100
                                                    for Kd_uphi = -1:1:1
                                                        for Kd_utheta = -1:1:1
                                                            for nr = 3:3:9
                                                                for nphi = 3:3:9
                                                                    for ntheta = 3:3:9
                                                                        multr = 0;
                                                                        multr1 = 0;
                                                                        multr2 = 0;

                                            %             for Kp_globalr=kp_l:(kp_h - kp_l)/dm3:kp_h
                                            %                 for Kd_globalr=kd_l:(kd_h - kd_l)/dm3:kd_h
                                            %                     for Kp_globalp=kp_l:(kp_h - kp_l)/dm3:kp_h
                                            %                         for Kd_globalp=kd_l:(kd_h - kd_l)/dm3:kd_h
                                            %                             for Kp_globalt=kp_l:(kp_h - kp_l)/dm3:kp_h
                                            %                                 for Kd_globalt=kd_l:(kd_h - kd_l)/dm3:kd_h
                                                                                close();
                                            %                                     disp(Kd_theta_test*low_mult :(Kd_theta_test*high_mult2 - Kd_theta_test*low_mult)/dm2:Kd_theta_test*high_mult2)
                                            %                                     Ki_phi = Ki_phi_test;
                                            %                                     Ki_theta = Ki_theta_test;
                                            %                                     Ki_r = Ki_r_test;
                                            % 
                                            %                                     Kd_phi = KD_PHI;
                                            %                                     Kd_theta = KD_THETA;
                                            %                                     Kd_r = KD_R;
                                            % 
                                            %                                     Kp_phi = KP_PHI; 
                                            %                                     Kp_theta = KP_THETA;
                                            %                                     Kp_r = KP_R;
                                            %                                     
                                                                                %Torques y fuerza iniciales
                                                                                Uxr = 0; % 0.0001 entrada 1
                                                                                Uyr = 0; % 0.0001 entrada 1
                                                                                Ur = utMax;

                                                                                %Primero se crean los sensores
                                                                                sensores = NewSensors(Ts,Tmax,x0);

                                                                                %Variables para guardar los valores leidos
                                                                                valores = []; phi = []; r = []; theta = [];
                                                                                acu_phi = 0; acu_theta = 0; acu_r = 0;

                                                                                e_phi = 0; e_theta = 0; e_r = 0; ez = 0;
                                                                                e_phi_anterior = 0; e_theta_anterior = 0; e_r_anterior = 0;
                                                                                e_x_anterior = 0; e_y_anterior = 0; e_z_anterior = 0; ez_anterior = 0;

                                                                                phi_anterior = 0; theta_anterior = 0; r_anterior = 0;
                                                                                x_anterior = 0; y_anterior = 0; z_anterior = 0;
                                                                                Uxr_anterior = 0; Uyr_anterior = 0; Ur_anterior = 0;
                                                                                px = 0; py = 0; pz = 0;

                                                                                % estos son los defaults a los que vuelve el controlador y desde los que
                                                                                % inicia
                                                                                set_phi = 0.0001*pi/180;
                                                                                set_theta = 0.0001*pi/180;
                                                                                set_r = 10000;    

                                                                                set_z = set_r;
                                                                                set_x = 1000;
                                                                                set_y = 2000;

                                                                                J = 0; J_acum = 0; eject = 0; iter = 2;
                                                                                d_xr = 0; d_yr = 0; d_r = 0;

                                                                                if stopcode == 0
                                                                                    for t_actual=0:Ts:Tmax
                                                                                    %     t_actual
                                                                                        e_phi_anterior = (set_phi - phi_anterior)*180/pi;
                                                                                        e_theta_anterior = (set_theta - theta_anterior)*180/pi;
                                                                                        e_r_anterior = set_r - r_anterior;
                                                                                        ez_anterior = ez;

                                                                                        e_x_anterior = (set_x - x_anterior);
                                                                                        e_y_anterior = (set_y - y_anterior);
                                                                                        e_z_anterior = (set_z - z_anterior);

                                                                                        %Se actualizan los sensores y la planta
                                                                                        %con los valores en los actuadores actuales

                                                                                        if e_phi_anterior < 1 && e_theta_anterior < 1 && e_r_anterior < 1
                                                                                            eject = 1;
                                                                                        end
                                                                                        sensores.update(t_actual,Ur, Uxr,Uyr, eject, iter);
                                                                                        if eject == 1
                                                                                            eject = 0;
                                                                                        end

                                                                                        %Si se quieren ver por separado
                                                                                        [Xx, Tt, posx , posy, posz, vz, valores] = sensores.read();
                                                                                        phi_actual = valores(2);
                                                                                        theta_actual = valores(3);
                                                                                        r_actual = valores(1); % (3) dice r pero es solo z, la altura

        %                                                                                 if r_actual < 0
        %                                                                                     r_actual = 0;
        %                                                                                 end

                                                                                        px = posx;
                                                                                        py = posy;
                                                                                        pz = posz;

                                                                                        X = Xx;
                                                                                        T = Tt;

                                                                                        z_actual = posz(length(posz));
                                                                                        y_actual = posy(length(posy));
                                                                                        x_actual = posx(length(posx));

                                                                                        % errores de control
                                                                                        e_phi = (set_phi - phi_actual)*180/pi;
                                                                                        e_theta = (set_theta - theta_actual)*180/pi;
                                                                                        e_r = set_r - r_actual;

                                                                                        ez = set_vz - vz;
                                                                                        set_vz = ez/1000;
                                                                                        
                                                                                        e_x = (set_x - x_actual);
                                                                                        e_y = (set_y - y_actual);
                                                                                        e_z = (set_z - z_actual);

                                                                                        % actualizar variables
                                            %                                             Ki_phi = Ki_phi_test/(abs(e_phi) + 1);
                                            %                                             Ki_theta = Ki_theta_test/(abs(e_theta) + 1);
                                            %                                             Ki_r = Ki_r_test/(abs(e_r)*multr + 1);
                                            % 
                                            %                                             Kd_phi = KD_PHI/(abs(e_phi) + 1);
                                            %                                             Kd_theta = KD_THETA/(abs(e_theta) + 1);
                                            %                                             Kd_r = KD_R/(abs(e_r)*multr + 1);
                                            % 
                                            %                                             Kp_phi = KP_PHI/(abs(e_phi) + 1); 
                                            %                                             Kp_theta = KP_THETA/(abs(e_theta) + 1);
                                            %                                             Kp_r = KP_R/(abs(e_r)*multr + 1);

                                                                                        Kp_global_r = Kp_globalr/(abs(e_z)*multr + 1);
                                                                                        Kd_global_r = Kd_globalr/(abs(e_z)*multr + 1);
                                                                                        Kp_global_phi = Kp_globalp/(abs(e_x)*multr1 + 1);
                                                                                        Kd_global_phi = Kd_globalp/(abs(e_x)*multr1 + 1);
                                                                                        Kp_global_theta = Kp_globalt/(abs(e_y)*multr2 + 1);
                                                                                        Kd_global_theta = Kd_globalt/(abs(e_y)*multr2 + 1);
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

                                                                                        % (Kp_phi*(e_phi) + Ki_phi*acu_phi + Kd_phi*((e_phi) - e_phi_anterior)/Ts)*0
                                                                                        % (Kp_theta*(e_theta) + Ki_theta*acu_theta + Kd_theta*((e_theta) - e_theta_anterior)/Ts)*0
                                                                                        % (((Kp_r*(e_r) + Ki_r*acu_r + Kd_r*((e_r) - e_r_anterior)/Ts))*(utMax*1/3))*0


                                                                                        Uxr = 1*(Kp_global_phi*e_x + Kd_global_phi*(exp(-t_actual/nphi)/nphi)*((e_x) - e_x_anterior)/Ts + Ki_phi_test*acu_phi)*m_phi + Kd_uphi*d_xr;
                                                                                        Uyr = 1*(Kp_global_theta*e_y + Kd_global_theta*(exp(-t_actual/ntheta)/ntheta)*((e_y) - e_y_anterior)/Ts + Ki_theta_test*acu_theta)*m_theta  + Kd_utheta*d_yr;
                                                                                        Ur =  1*(Kp_global_r*e_z + Kd_global_r*(exp(-t_actual/nr)/nr)*((e_z) - e_z_anterior)/Ts + Ki_r_test*acu_r)*m_r + (Kp_vel*ez + Kd_vel*(ez - ez_anterior)/Ts)*multvel  + Kd_ur*d_r;
                                                %                                         Ur = 0;
                                                %                                         disp(Ur)
                                                                                        if abs(Ur) == Inf
                                                                                            disp(Kd_global_r*(exp(-t_actual/nr)/nr)*((e_z) - e_z_anterior)/Ts)
                                                                                            disp(Ki_r_test*acu_r)
                                                                                            disp(1*(Kp_global_r*e_z + Kd_global_r*(exp(-t_actual/nr)/nr)*((e_z) - e_z_anterior)/Ts + Ki_r_test*acu_r)*m_r)
                                                                                            disp(Kd_ur*d_r)
                                                                                            disp(Kd_ur)
                                                                                            disp(d_r)
                                                                                            disp((Kp_vel*ez + Kd_vel*(ez - ez_anterior)/Ts)*multvel)
                                                                                        end
                                                                                            % variaciones de variables manipuladas
                                                                                            d_xr = (Uxr - Uxr_anterior);
                                                                                            d_yr = (Uyr - Uyr_anterior);
                                                                                            d_r = (Ur - Ur_anterior);


                                                                                        %Ejemplo para almacenar valores
                                            %                                             phi = [phi; phi_actual];
                                            %                                             theta = [theta; theta_actual];
                                            %                                             r = [r; r_actual];

                                                                                        phi_anterior = phi_actual;
                                                                                        theta_anterior = theta_actual;
                                                                                        r_anterior = r_actual;

                                                                                        z_anterior = z_actual;
                                                                                        y_anterior = y_actual;
                                                                                        x_anterior = x_actual;

                                                                                        Uxr_anterior = Uxr;
                                                                                        Uyr_anterior = Uyr;
                                                                                        Ur_anterior = Ur;
                                                                                    %     disp('b');

                                                                                        %
                                                                                        %pause
                                                                                        if t_actual >= 0
                                            %                                                 J1 = abs((e_theta^2 + e_phi^2 + 0.02*e_r^2 + 0.2*10^(-13)*(((e_theta) - e_theta_anterior)/Ts) + 0.2*10^(-13)*(((e_phi) - e_phi_anterior)/Ts) + 0.2*10^(-8)*(((e_r) - e_r_anterior)/Ts))); % + abs(e_phi*0.2 + e_theta*0.4 + e_r*0.4))/2 ;
                                                                                            J2 = e_r^2; % (abs((e_x^2 + e_y^2 + 5*e_z^2 + 0.2*10^(-13)*(((e_x) - e_x_anterior)/Ts) + 0.2*10^(-13)*(((e_y) - e_y_anterior)/Ts) + 0.2*10^(-8)*(((e_z) - e_z_anterior)/Ts))));
                                                                                            J = J2*1;
                                                                                            J_acum = J_acum + J;
                                                                                        end
                                                                                        iter = iter + 1;
                                                                                    end

                                                                                    if (abs(J_acum) < J_best)
                                                                                        close()
                                                                                        %Graficando 
                                                                                        disp(" =========== MATCH =========== ")
                                                                                        disp(" ---------------------------------- ")
                                                                                        disp(J_acum)
                                                                                        disp([Kp_globalr Kd_globalr Kp_globalp Kd_globalp Kp_globalt Kd_globalt m_r m_phi m_theta]); % Kp_r Kp_phi Kp_theta Kd_r Kd_phi Kd_theta Ki_r Ki_phi Ki_theta])
%                                                                                         disp([multr multr1 multr2])
                                                                                        disp([Kp_vel Kd_vel multvel])
                                                                                        disp([Kd_ur Kd_uphi Kd_utheta])
                                                                                        disp([nr nphi ntheta])
                                                                                        disp([Ur Uyr Uxr])
                                                                                        disp([e_x e_y e_z])
                                                                                        disp(set_vz)
                                                                                        
                                            %                                             disp(size(px))
                                            %                                             plot((phi)*180/pi); title('Elevacion [grados]')
                                            %                                             figure; plot(theta*180/pi); title('Azimut [grados]')
                                            %                                             figure; plot(r);  title('Desplazamiento en eje z (Altura) [m]')
                                            %                                             figure; 
                                            %                                             disp(size((1:iter-1)*Ts))
                                            %                                             disp(size(pz/1000))
                                                                                        figure; plot((1:iter-1)*Ts,pz/1000); title('h (altura absoluta, Km)'); xlabel('tiempo, seg');
                                                                                        figure; plot(T,X(:,2));  title('vel longitudinal, m/s'); xlabel('tiempo, seg');
                                                                                        figure; plot(T,X(:,3)); title('masa, Kg'); xlabel('tiempo, seg');
                                                                                        figure; plot(T,[X(:,4) X(:,5)]*180/pi); title('phi y theta, grados'); xlabel('tiempo, seg');

                                                                                        figure; plot3(px/1000,py/1000,pz/1000); title('trayectoria 3D (coordenadas absolutas)');
                                                                                        grid
                                                                                        xlabel('km');ylabel('km');zlabel('altitude, km');

                                                                                        J_best = J_acum;
                                                                                        pause(5)
                                            %                                             pause
                                                                                        close()
                                                                                        stopcount = stopcount + 1;
                                                                                            if stopcount >= 10
                                                                                                stopcode = 1;
                                                %                                                 pause
                                                                                            end
                                                                                    end
                                                                                    end
                                                                                end
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
%         end
%     end
% end



