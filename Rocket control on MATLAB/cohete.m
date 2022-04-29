function yprima=cohete(t,o,Uxr,Uyr,Ut, Ma)
g0 = 9.8065;  % gravedad inicial
Rs = 6.35*10^6; % radio promedio de la Tierra
% Ac = 7.5; % área transversal del cohete
% p0 = 0.5; % coeficiente densidad del aire respecto al nivel del mar
% vp = 500; % velocidad del gas expulsado relativa al cohete

M = 2000; % 4400000; %2000;   % masa inicial del cohete, kg
% Ma=M;
L = 63;   % largo cohete
AnguloMax=0.0175; % torque maximo disponible, motores alfa y beta
EmpujeMax=10.0;  % fuerza maxima disponible, motor flecha

% pasar esfericas a cartesianas
% disp('------------');
% % % Ma
%  o
%  cos(o(2))

Vp = o(4);
Vphi = o(1)*o(5);
Vtheta = o(1)*o(6)*sin(o(2));

% Vx = cos(o(2))*cos(o(3))*Vp + o(1)*cos(o(2))*sin(o(3))*Vtheta + o(1)*sin(o(2))*cos(o(3))*Vphi;
% Vy = cos(o(2))*sin(o(3))*Vp - o(1)*cos(o(2))*cos(o(3))*Vtheta + o(1)*sin(o(2))*sin(o(3))*Vphi;
% Vz = sin(o(2))*Vp - o(1)*cos(o(2))*Vphi;
% % 
% % Vx=o(1)*Vtheta*cos(o(2))*cos(o(3))+Vp*cos(o(3))*sin(o(2))-o(1)*Vphi*sin(o(2))*sin(o(3));
% % 
% % Vy=o(1)*Vtheta*cos(o(3))*sin(o(2))+o(1)*Vphi*cos(o(2))*sin(o(3))+Vp*sin(o(2))*sin(o(3));
% % 
% % Vz=Vp*cos(o(3))-o(1)*Vtheta*sin(o(3))
% o
% o(2)
% o(3)
% x =  o(1)*sin(o(2))*cos(o(3)) % + Vx*t;
% y =  o(1)*sin(o(2))*sin(o(3)) % + Vy*t;
% z = o(1)*cos(o(2))% + Vz*t

% x = o(1);
% y = o(2);
% z = o(3);
% Vx = Vp;
% Vy = Vphi;
% Vz = Vtheta;

% R = [x y z];
% V = [Vx Vy Vz];

% TORQUES Y FUERZA MAXIMO DE MOTORES
if Uxr>AnguloMax, Uxr=AnguloMax; end;
if Uxr<-AnguloMax, Uxr=-AnguloMax; end;
if Uyr>AnguloMax, Uyr=AnguloMax; end;
if Uyr<-AnguloMax, Uyr=-AnguloMax; end;
if Ut>EmpujeMax, Ut=EmpujeMax; end;
if Ut<0, Ut=0; end;

% POSICION RELATIVA CM
Lactual = Ma*L/(M); % largo del cilindro de combustible del momento de inercia
CM = (Lactual)/2; % el origen de las coordenadas relativas de largo esta en la tobera

% COORDENADAS RELATIVAS
% p = sqrt(x^2 + y^2 + z^2); % radial
% phi = tan(y/x) + Uxr; % elevacion
% theta = tan(sqrt(x^2 + y^2)/z) + Uyr; % azimut
% Vp = sqrt(Vx^2 + Vy^2 + Vz^2);
% Vphi = Vp*sin(pi/2-phi);
% Vtheta = atan(sqrt(Vx^2 + Vy^2)/Vz);
% 
% % VELOCIDAD ANGULAR
% w_absoluta = cross(R,V)/(norm(R)^2);
% % w_relativa = cross([p phi theta],[Vp Vphi Vtheta])/(norm([p phi theta])^2); % p, elevacion, azimut
% 
% % ENERGIA CINETICA
% K = 0.5*Ma*(V + cross(w_absoluta, R)).^2;
% 
% % GRAVEDAD
% g = (Rs/(Rs + z))*g0;
% 
% % LAGRANGIANO
% L_x = K(1) + ((1/12)*(Ma)*Lactual^2)*0.5*w_absoluta(1).^2 - 0; % como el diametro se asume muy pequeño casi no aporta energia cinetica en esta direccion
% L_y = K(2) + ((1/12)*(Ma)*Lactual^2 + Ma*(CM)^2)*0.5*w_absoluta(2).^2 - 0;
% L_z = K(3) + ((1/12)*(Ma)*Lactual^2 + Ma*(CM)^2)*0.5*w_absoluta(3).^2 - Ma*g*z;
% L = [L_x L_y L_z];
% 
% % ROCE AIRE
% Fr = (p0*(1-(x(3)/20000)^2))*Ac*(abs(x(4))^(3/2))*sign(x(4));
% 
% % EMPUJE
% Fp = Ut*vp;
% 
% 
% % FUERZAS EXTERNAS
% Fp = Fp - Fr;
% Fx = Fp*sin(phi)*cos(theta);
% Fy = Fp*sin(phi)*sin(theta);
% Fz = Fp*cos(phi); 

% ECUACIONES DIFERENCIALES DEPENDIENTES DE x, y, z, Vx, Vy, Vz, Lactual,
% CM, Ma
aux1=-((-480000000000*Ut-960000000000*Ut*o(1)-480000000000*Ut*o(1)^2-480000000000*Ut*cos(Uxr+o(2))*o(2)-960000000000*Ut*cos(Uxr+o(2))*o(1)*o(2)-480000000000*Ut*cos(Uxr+o(2))*o(1)^2*o(2)+3600000000*abs(cos(o(2))*o(1))^(3/2)*sign(cos(o(2))*o(1))+7200000000*o(1)*abs(cos(o(2))*o(1))^(3/2)*sign(cos(o(2))*o(1))+3600000000*o(1)^2*abs(cos(o(2))*o(1))^(3/2)*sign(cos(o(2))*o(1))-9*cos(o(2))^2*o(1)^2*abs(cos(o(2))*o(1))^(3/2)*sign(cos(o(2))*o(1))-18*cos(o(2))^2*o(1)^3*abs(cos(o(2))*o(1))^(3/2)*sign(cos(o(2))*o(1))-9*cos(o(2))^2*o(1)^4*abs(cos(o(2))*o(1))^(3/2)*sign(cos(o(2))*o(1))+3600000000*cos(Uxr+o(2))*o(2)*abs(cos(o(2))*o(1))^(3/2)*sign(cos(o(2))*o(1))+7200000000*cos(Uxr+o(2))*o(1)*o(2)*abs(cos(o(2))*o(1))^(3/2)*sign(cos(o(2))*o(1))+3600000000*cos(Uxr+o(2))*o(1)^2*o(2)*abs(cos(o(2))*o(1))^(3/2)*sign(cos(o(2))*o(1))-9*cos(o(2))^2*cos(Uxr+o(2))*o(1)^2*o(2)*abs(cos(o(2))*o(1))^(3/2)*sign(cos(o(2))*o(1))-18*cos(o(2))^2*cos(Uxr+o(2))*o(1)^3*o(2)*abs(cos(o(2))*o(1))^(3/2)*sign(cos(o(2))*o(1))-9*cos(o(2))^2*cos(Uxr+o(2))*o(1)^4*o(2)*abs(cos(o(2))*o(1))^(3/2)*sign(cos(o(2))*o(1))-480000000000*Ut*o(1)*sin(Uxr+o(2))-960000000000*Ut*o(1)^2*sin(Uxr+o(2))-480000000000*Ut*o(1)^3*sin(Uxr+o(2))+3600000000*o(1)*abs(cos(o(2))*o(1))^(3/2)*sign(cos(o(2))*o(1))*sin(Uxr+o(2))+7200000000*o(1)^2*abs(cos(o(2))*o(1))^(3/2)*sign(cos(o(2))*o(1))*sin(Uxr+o(2))+3600000000*o(1)^3*abs(cos(o(2))*o(1))^(3/2)*sign(cos(o(2))*o(1))*sin(Uxr+o(2))-9*cos(o(2))^2*o(1)^3*abs(cos(o(2))*o(1))^(3/2)*sign(cos(o(2))*o(1))*sin(Uxr+o(2))-18*cos(o(2))^2*o(1)^4*abs(cos(o(2))*o(1))^(3/2)*sign(cos(o(2))*o(1))*sin(Uxr+o(2))-9*cos(o(2))^2*o(1)^5*abs(cos(o(2))*o(1))^(3/2)*sign(cos(o(2))*o(1))*sin(Uxr+o(2))-960000000*Ma*o(2)*sin(Uxr+o(2))*o(3)*Vphi*Vtheta-960000000*Ma*o(1)*o(2)*sin(Uxr+o(2))*o(3)*Vphi*Vtheta-960000000*Ma*cos(Uxr+o(2))*o(2)^2*sin(Uxr+o(2))*o(3)*Vphi*Vtheta-960000000*Ma*cos(Uxr+o(2))*o(1)*o(2)^2*sin(Uxr+o(2))*o(3)*Vphi*Vtheta-960000000*Ma*o(1)*o(2)*sin(Uxr+o(2))^2*o(3)*Vphi*Vtheta-960000000*Ma*o(1)^2*o(2)*sin(Uxr+o(2))^2*o(3)*Vphi*Vtheta-960000000*CM^2*Ma*cos(Uxr+o(2))*o(2)*sin(Uxr+o(2))*Vtheta^2-80000000*Lactual^2*Ma*cos(Uxr+o(2))*o(2)*sin(Uxr+o(2))*Vtheta^2-960000000*CM^2*Ma*cos(Uxr+o(2))^2*o(2)^2*sin(Uxr+o(2))*Vtheta^2-80000000*Lactual^2*Ma*cos(Uxr+o(2))^2*o(2)^2*sin(Uxr+o(2))*Vtheta^2-960000000*CM^2*Ma*cos(Uxr+o(2))*o(1)*o(2)*sin(Uxr+o(2))^2*Vtheta^2-80000000*Lactual^2*Ma*cos(Uxr+o(2))*o(1)*o(2)*sin(Uxr+o(2))^2*Vtheta^2+960000000*Ma*cos(Uxr+o(2))*o(2)*sin(Uxr+o(2))*o(3)^2*Vtheta^2+960000000*Ma*cos(Uxr+o(2))^2*o(2)^2*sin(Uxr+o(2))*o(3)^2*Vtheta^2+960000000*Ma*cos(Uxr+o(2))*o(1)*o(2)*sin(Uxr+o(2))^2*o(3)^2*Vtheta^2+1920000000*Ma*o(2)*Vphi*(Vp)+1920000000*Ma*o(1)*o(2)*Vphi*(Vp)+1920000000*Ma*cos(Uxr+o(2))*o(2)^2*Vphi*(Vp)+1920000000*Ma*cos(Uxr+o(2))*o(1)*o(2)^2*Vphi*(Vp)+1920000000*Ma*o(1)*o(2)*sin(Uxr+o(2))*Vphi*(Vp)+1920000000*Ma*o(1)^2*o(2)*sin(Uxr+o(2))*Vphi*(Vp)-960000000*Ma*cos(Uxr+o(2))*o(2)*o(3)*Vtheta*(Vp)-960000000*Ma*cos(Uxr+o(2))^2*o(2)^2*o(3)*Vtheta*(Vp)+1920000000*Ma*cos(Uxr+o(2))*o(2)*sin(Uxr+o(2))*o(3)*Vtheta*(Vp)+960000000*Ma*cos(Uxr+o(2))*o(1)*o(2)*sin(Uxr+o(2))*o(3)*Vtheta*(Vp)+1920000000*Ma*sin(Uxr+o(2))^2*o(3)*Vtheta*(Vp)+3840000000*Ma*o(1)*sin(Uxr+o(2))^2*o(3)*Vtheta*(Vp)+1920000000*Ma*o(1)^2*sin(Uxr+o(2))^2*o(3)*Vtheta*(Vp)-960000000*Ma*Vphi*(Vphi)-1920000000*Ma*o(1)*Vphi*(Vphi)-960000000*Ma*o(1)^2*Vphi*(Vphi)-960000000*Ma*cos(Uxr+o(2))*o(2)*Vphi*(Vphi)-1920000000*Ma*cos(Uxr+o(2))*o(1)*o(2)*Vphi*(Vphi)-960000000*Ma*cos(Uxr+o(2))*o(1)^2*o(2)*Vphi*(Vphi)-960000000*Ma*o(1)*sin(Uxr+o(2))*Vphi*(Vphi)-1920000000*Ma*o(1)^2*sin(Uxr+o(2))*Vphi*(Vphi)-960000000*Ma*o(1)^3*sin(Uxr+o(2))*Vphi*(Vphi)-960000000*Ma*cos(Uxr+o(2))*o(3)*Vtheta*(Vphi)-1920000000*Ma*cos(Uxr+o(2))*o(1)*o(3)*Vtheta*(Vphi)-960000000*Ma*cos(Uxr+o(2))*o(1)^2*o(3)*Vtheta*(Vphi)+960000000*Ma*cos(Uxr+o(2))^2*o(2)*o(3)*Vtheta*(Vphi)+1920000000*Ma*cos(Uxr+o(2))^2*o(1)*o(2)*o(3)*Vtheta*(Vphi)+960000000*Ma*cos(Uxr+o(2))^2*o(1)^2*o(2)*o(3)*Vtheta*(Vphi)+1920000000*Ma*cos(Uxr+o(2))*sin(Uxr+o(2))*o(3)*Vtheta*(Vphi)+4800000000*Ma*cos(Uxr+o(2))*o(1)*sin(Uxr+o(2))*o(3)*Vtheta*(Vphi)+3840000000*Ma*cos(Uxr+o(2))*o(1)^2*sin(Uxr+o(2))*o(3)*Vtheta*(Vphi)+960000000*Ma*cos(Uxr+o(2))*o(1)^3*sin(Uxr+o(2))*o(3)*Vtheta*(Vphi)+960000000*Ma*o(2)*sin(Uxr+o(2))*o(3)*Vtheta*(Vphi)+960000000*Ma*o(1)*o(2)*sin(Uxr+o(2))*o(3)*Vtheta*(Vphi)-960000000*Ma*cos(Uxr+o(2))*o(2)^2*sin(Uxr+o(2))*o(3)*Vtheta*(Vphi)-960000000*Ma*cos(Uxr+o(2))*o(1)*o(2)^2*sin(Uxr+o(2))*o(3)*Vtheta*(Vphi)-1920000000*Ma*o(2)*sin(Uxr+o(2))^2*o(3)*Vtheta*(Vphi)-2880000000*Ma*o(1)*o(2)*sin(Uxr+o(2))^2*o(3)*Vtheta*(Vphi)-960000000*Ma*o(1)^2*o(2)*sin(Uxr+o(2))^2*o(3)*Vtheta*(Vphi)-960000000*Ma*cos(Uxr+o(2))*o(2)*Vtheta*(Vtheta)-960000000*Ma*cos(Uxr+o(2))*o(1)*o(2)*Vtheta*(Vtheta)-960000000*Ma*cos(Uxr+o(2))^2*o(2)^2*Vtheta*(Vtheta)-960000000*Ma*cos(Uxr+o(2))^2*o(1)*o(2)^2*Vtheta*(Vtheta)-960000000*Ma*sin(Uxr+o(2))*Vtheta*(Vtheta)-1920000000*Ma*o(1)*sin(Uxr+o(2))*Vtheta*(Vtheta)-960000000*Ma*o(1)^2*sin(Uxr+o(2))*Vtheta*(Vtheta)-960000000*Ma*cos(Uxr+o(2))*o(2)*sin(Uxr+o(2))*Vtheta*(Vtheta)-2880000000*Ma*cos(Uxr+o(2))*o(1)*o(2)*sin(Uxr+o(2))*Vtheta*(Vtheta)-1920000000*Ma*cos(Uxr+o(2))*o(1)^2*o(2)*sin(Uxr+o(2))*Vtheta*(Vtheta)-960000000*Ma*o(1)*sin(Uxr+o(2))^2*Vtheta*(Vtheta)-1920000000*Ma*o(1)^2*sin(Uxr+o(2))^2*Vtheta*(Vtheta)-960000000*Ma*o(1)^3*sin(Uxr+o(2))^2*Vtheta*(Vtheta))/(960000000*Ma*(1+o(1))^2*(1+cos(Uxr+o(2))*o(2)+o(1)*sin(Uxr+o(2)))));

aux2=-((-12*sin(Uxr+o(2))*o(3)*Vphi*Vtheta-12*o(1)*sin(Uxr+o(2))*o(3)*Vphi*Vtheta-12*cos(Uxr+o(2))*o(2)*sin(Uxr+o(2))*o(3)*Vphi*Vtheta-12*cos(Uxr+o(2))*o(1)*o(2)*sin(Uxr+o(2))*o(3)*Vphi*Vtheta-12*o(1)*sin(Uxr+o(2))^2*o(3)*Vphi*Vtheta-12*o(1)^2*sin(Uxr+o(2))^2*o(3)*Vphi*Vtheta-12*CM^2*cos(Uxr+o(2))*sin(Uxr+o(2))*Vtheta^2-Lactual^2*cos(Uxr+o(2))*sin(Uxr+o(2))*Vtheta^2-12*CM^2*cos(Uxr+o(2))^2*o(2)*sin(Uxr+o(2))*Vtheta^2-Lactual^2*cos(Uxr+o(2))^2*o(2)*sin(Uxr+o(2))*Vtheta^2-12*CM^2*cos(Uxr+o(2))*o(1)*sin(Uxr+o(2))^2*Vtheta^2-Lactual^2*cos(Uxr+o(2))*o(1)*sin(Uxr+o(2))^2*Vtheta^2+12*cos(Uxr+o(2))*sin(Uxr+o(2))*o(3)^2*Vtheta^2+12*cos(Uxr+o(2))^2*o(2)*sin(Uxr+o(2))*o(3)^2*Vtheta^2+12*cos(Uxr+o(2))*o(1)*sin(Uxr+o(2))^2*o(3)^2*Vtheta^2+24*Vphi*(Vp)+24*o(1)*Vphi*(Vp)+24*cos(Uxr+o(2))*o(2)*Vphi*(Vp)+24*cos(Uxr+o(2))*o(1)*o(2)*Vphi*(Vp)+24*o(1)*sin(Uxr+o(2))*Vphi*(Vp)+24*o(1)^2*sin(Uxr+o(2))*Vphi*(Vp)-12*cos(Uxr+o(2))*o(3)*Vtheta*(Vp)-12*cos(Uxr+o(2))^2*o(2)*o(3)*Vtheta*(Vp)+24*cos(Uxr+o(2))*sin(Uxr+o(2))*o(3)*Vtheta*(Vp)+12*cos(Uxr+o(2))*o(1)*sin(Uxr+o(2))*o(3)*Vtheta*(Vp)+24*cos(Uxr+o(2))^2*o(3)*Vtheta*(Vphi)+48*cos(Uxr+o(2))^2*o(1)*o(3)*Vtheta*(Vphi)+24*cos(Uxr+o(2))^2*o(1)^2*o(3)*Vtheta*(Vphi)+12*sin(Uxr+o(2))*o(3)*Vtheta*(Vphi)+12*o(1)*sin(Uxr+o(2))*o(3)*Vtheta*(Vphi)-12*cos(Uxr+o(2))*o(2)*sin(Uxr+o(2))*o(3)*Vtheta*(Vphi)-12*cos(Uxr+o(2))*o(1)*o(2)*sin(Uxr+o(2))*o(3)*Vtheta*(Vphi)+12*o(1)*sin(Uxr+o(2))^2*o(3)*Vtheta*(Vphi)+12*o(1)^2*sin(Uxr+o(2))^2*o(3)*Vtheta*(Vphi)-12*cos(Uxr+o(2))*Vtheta*(Vtheta)-12*cos(Uxr+o(2))*o(1)*Vtheta*(Vtheta)-12*cos(Uxr+o(2))^2*o(2)*Vtheta*(Vtheta)-12*cos(Uxr+o(2))^2*o(1)*o(2)*Vtheta*(Vtheta)-12*cos(Uxr+o(2))*o(1)*sin(Uxr+o(2))*Vtheta*(Vtheta)-12*cos(Uxr+o(2))*o(1)^2*sin(Uxr+o(2))*Vtheta*(Vtheta))/(12*(1+o(1))^2*(1+cos(Uxr+o(2))*o(2)+o(1)*sin(Uxr+o(2)))));

aux3=-((2*(sin(Uxr+o(2))*Vtheta*(Vp)+cos(Uxr+o(2))*Vtheta*(Vphi)+cos(Uxr+o(2))*o(1)*Vtheta*(Vphi)-o(2)*sin(Uxr+o(2))*Vtheta*(Vphi)))/(1+cos(Uxr+o(2))*o(2)+o(1)*sin(Uxr+o(2))));


% v1=Vp; % -((-Vz*cos(o(2))^2*cos(o(3))-Vz*cos(o(3))*sin(o(2))^2-Vx*cos(o(2))*sin(o(3))-Vy*sin(o(2))*sin(o(3)))/(cos(o(2))^2*cos(o(3))^2+cos(o(3))^2*sin(o(2))^2+cos(o(2))*cos(o(3))*sin(o(2))*sin(o(3))+sin(o(2))^2*sin(o(3))^2));
% 
% v2=Vphi; % -((Vz*cot(o(2))*cot(o(3))*csc(o(3))-Vz*cot(o(3))^2*csc(o(3))+Vx*csc(o(2))*csc(o(3))-Vy*cot(o(3))*csc(o(2))*csc(o(3))+Vx*cot(o(3))^2*csc(o(2))*csc(o(3))-Vy*cot(o(2))*cot(o(3))^2*csc(o(2))*csc(o(3)))/(o(1)*(1+cot(o(2))*cot(o(3))+cot(o(3))^2+cot(o(2))^2*cot(o(3))^2)))
% 
% v3=Vtheta; % -((csc(o(3))*(-Vx*cos(o(2))*cot(o(3))-Vy*cot(o(3))*sin(o(2))+Vz*cos(o(2))*cot(o(3))*sin(o(2))+Vz*sin(o(2))^2))/(o(1)*(cos(o(2))^2*cot(o(3))^2+cos(o(2))*cot(o(3))*sin(o(2))+sin(o(2))^2+cot(o(3))^2*sin(o(2))^2)));

acc1=aux1;
acc2=aux2;
acc3=aux3;


% acc1=-((o(1)*v2*cos(o(2))^2-aux3*cos(o(2))^2*sec(o(3))+o(1)*v2*sin(o(2))^2-o(1)*v3^2*cos(o(2))^2*sin(o(2))^2-aux3*sec(o(3))*sin(o(2))^2-o(1)*v3^2*sin(o(2))^4-aux2*cos(o(2))*tan(o(3))+aux1*sin(o(2))*tan(o(3)))/(cos(o(2))^2+sin(o(2))^2));
% acc2=-((sec(o(2))*(2*v2*v1*cos(o(2))^3-aux1*cos(o(2))^2*sec(o(3))-o(1)*v3^2*cos(o(2))^4*sin(o(2))-aux2*cos(o(2))*sec(o(3))*sin(o(2))+2*v2*v1*cos(o(2))*sin(o(2))^2-o(1)*v3^2*cos(o(2))^2*sin(o(2))^3+aux3*cos(o(2))^3*sec(o(3))*tan(o(3))+aux3*cos(o(2))*sec(o(3))*sin(o(2))^2*tan(o(3))+aux2*cos(o(2))^2*tan(o(3))^2-aux1*cos(o(2))*sin(o(2))*tan(o(3))^2))/(o(1)*(cos(o(2))^2+sin(o(2))^2)));
% acc3=-(1/(o(1)*(1+cot(o(2))^2)))*(2*v1*v3+2*o(1)*v2*v3*cot(o(2))+2*v1*v3*cot(o(2))^2+2*o(1)*v2*v3*cot(o(2))^3+aux1*csc(o(2))^2-aux2*cot(o(2))*csc(o(2))^2);


yprima(1)=Vp; % velocidad r
yprima(2)=Vphi; % velocidad phi
yprima(3)=Vtheta; % velocidad theta
yprima(4)=acc1; % aceleracion r
yprima(5)=acc2; % aceleracion phi
yprima(6)=acc3; % aceleracion theta

yprima=yprima';
%  pause