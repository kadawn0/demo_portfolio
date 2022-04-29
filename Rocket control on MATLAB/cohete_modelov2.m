function xprima=cohete_modelov2(t,x,ut,ux,uy)
g0 = 9.8065;  % gravedad (se asume constante en altura)
ro0= 0.1; % coef resistencia superficie terrestre
ve=5000; % velocidad de escape de gases
Ac=7.5; % area transversal para calculo de roce con aire
Mmin=100; % masa del cohete sin combustible

%Ruido
mu=0;
sigma=0.5*pi/180;

% maximos para tobera
utMax=10; % maximo empuje longitudinal
uxMax=0.3*pi/180;  % maxima inclinacion tobera en eje x del cohete
uyMax=0.3*pi/180;  % maxima inclinacion tobera en eje y del cohete

if x(3)<Mmin   % se acabo el combustible
    ut=0;
end

L=63; % largo cohete
Ir=x(3)*L^2/12; % momento de inercia rotacional cohete

% FUERZAS MAXIMAS
if ut>utMax, ut=utMax; end;
if ut<0, ut=0; end;


if ux>uxMax, ux=uxMax; end;
if ux<-uxMax, ux=-uxMax; end;
if uy>uyMax, uy=uyMax; end;
if uy<-uyMax, uy=-uyMax; end;


% ECUACIONES DIFERENCIALES SIMPLIFICADAS
% g=g0*(Rs/(Rs+x(1))); % gravedad
Ftob=ut*ve; % fuerza tobera empuje, thrust
Fux=Ftob*sin(x(8)); % componente de fuerza tobera transversal X
Fuy=Ftob*sin(x(9)); % componente de fuerza tobera transversal Y
Fp=sqrt((Ftob)^2-Fux^2-Fuy^2); % fuerza empuje vertical
ro=ro0*((1 - (x(1)/20000)^2)>0)*(1 - (x(1)/20000)^2); % roce aire



xprima(1)=x(2); % dh/dt
xprima(2)=(Fp - ro*Ac*sign(x(2))*abs(x(2))^(3/2)- x(3)*g0*sin(x(4)))/x(3); % dh^2/dt^2
xprima(3)=-ut; % dM/dT
xprima(4)=x(6); % d_phi/dt
xprima(5)=x(7);%+normrnd(mu,sigma); % d_theta/dt
xprima(6)=(L/2)*(Fux-1*g0*cos(x(4))-1500*x(6))/Ir;  % d^2_phi/dt^2
xprima(7)=(L/2)*(Fuy-1500*x(7))/Ir;  % d^2_theta/dt^2
xprima(8) = (ux-x(8))/2;
xprima(9) = (uy-x(9))/2;

% [x(8),xprima(8)]

xprima=xprima';