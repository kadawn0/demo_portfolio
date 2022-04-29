classdef NewSensors < handle
    properties
        % inicializacion variables de salida
        Ts % periodo del sistema
        Tmax
        SUrte
        Time
        InitSUrte
        k
        mu
        sigma_r
        sigma_phi
        sigma_theta
        r
        xx
        y
        z
        phi 
        theta
        J
        Ur_anterior
        Uxr_anterior
        Uyr_anterior
        Ma
        Uxr
        Uyr
        Uxr_set
        Uyr_set
        X
        T
        h
        vz
        vphi
        vtheta
    end
    methods
        function obj = NewSensors(dt,tmax,x0)
            obj.Ts = dt;
            obj.Tmax = tmax;
            obj.SUrte = zeros(fix(tmax/dt)+1,9);
            obj.Time = zeros(fix(tmax/dt)+1,1);
            obj.InitSUrte = x0;
            obj.k = 1;
            obj.mu = 0;
            obj.sigma_phi = 0.1*pi/180; % 1 mucho, 0.1 poco
            obj.sigma_theta = 0.1*pi/180; % 1 mucho, 0.1 poco
            obj.sigma_r = 0.02; % 2 mucho, 0.02 poco
            obj.J = 0;
            obj.Ma= 2000; % 4400000;%2000;
            obj.Ur_anterior = 0;
            obj.Uxr_anterior = 0;
            obj.Uyr_anterior = 0;
            obj.xx=0;
            obj.y=0;
            obj.z=0;
            obj.Uxr=0;
            obj.Uyr=0;
            obj.Uxr_set=0;
            obj.Uyr_set=0;
            obj.T = zeros(fix(tmax/dt),1);
            obj.X = zeros(fix(tmax/dt),9);
            obj.h = 0;
            obj.vz = 0;
        end
        function obj = update(obj,t1,Ur,Uxr,Uyr, eject, iter)
            % integrador numerico
            options=odeset('RelTol',1e-3,'AbsTol',1e-4);
%             obj.InitSUrte(2) = vz_in;
%             alert=0;
%             % delay input
%             if obj.Uxr_set~=Uxr
%                 obj.Uxr_set=Uxr;
%                 alert=1;
%             end
%             if obj.Uyr_set~=Uyr
%                 obj.Uyr_set=Uyr;
%                 alert=1;
%             end
%             
%             Uxr_f = @(t, x) x - x*exp(-(t)/2);
%             Uyr_f = @(t, x) x - x*exp(-(t)/2);
%             
%             if alert==1
% %                 disp('CHANGE OF ANGULAR INPUTS!');
%                 [tt, uxr] = ode23(@(tt, uxr) Uxr_f(tt, Uxr), [t1 t1+obj.Ts], [0]);
%                 [tt, uyr] = ode23(@(tt, uyr) Uyr_f(tt, Uyr), [t1 t1+obj.Ts], [0]);
% 
%                 obj.Uxr=uxr(length(uxr));
%                 obj.Uyr=uyr(length(uyr));
%             else
%                 [tt, uxr] = ode23(@(tt, uxr) Uxr_f(tt, Uxr), [t1 t1+obj.Ts], [obj.Uxr]);
%                 [tt, uyr] = ode23(@(tt, uyr) Uyr_f(tt, Uyr), [t1 t1+obj.Ts], [obj.Uyr]);
%                 
%                 obj.Uxr=uxr(length(uxr));
%                 obj.Uyr=uyr(length(uyr));
%             end
%             if obj.Uxr > Uxr
            obj.Uxr = Uxr;
%             end
%             if obj.Uyr > Uyr
            obj.Uyr = Uyr;
%             end
%             obj.Uxr
%             obj.Uyr
            
            [t,x]=ode113(@(t,x) cohete_modelov2(t,x,Ur,obj.Uxr,obj.Uyr),[t1 t1+obj.Ts],obj.InitSUrte,options);

            % toma ultimo valor del vector
            obj.SUrte(obj.k,:)=x(max(size(x, 1)),:);
            
            % toma ultimo valor tiempo simulado
            obj.Time(obj.k,:)=t(max(size(t)));
            
            % MASA ACTUAL
%             obj.InitSUrte(3) = obj.InitSUrte(3) - Ur;

%             if eject == 1
%                 obj.InitSUrte(3) = obj.InitSUrte(3) - 300;
%             end
%             if obj.Ma <= 0
%                 obj.Ma=0;
%             end
            
%             
%             % phi usa valor entre 0 y pi
%             if obj.SUrte(obj.k,2)<-pi
%                 obj.SUrte(obj.k,2)=0;
%             end
%             if obj.SUrte(obj.k,2)>pi
%                 obj.SUrte(obj.k,2)=pi;
%             end
% 
%             % theta usa valor entre 0 y 2pi
%             if obj.SUrte(obj.k,3)<0
%                 obj.SUrte(obj.k,3)=obj.SUrte(obj.k,3)+2*pi;
%             end
%             if obj.SUrte(obj.k,3)>2*pi
%                 obj.SUrte(obj.k,3)=obj.SUrte(obj.k,3)-2*pi;
%             end
            
            
            % guarda valor de variables para inicio periodo siguiente
            obj.InitSUrte=obj.SUrte(obj.k,:);
            
            %Se agrega ruido a los sensores
%             obj.r = (obj.InitSUrte(1)/cos(obj.InitSUrte(4))) + normrnd(obj.mu,obj.sigma_r);
%             obj.xx = (obj.InitSUrte(1)/cos(obj.InitSUrte(4)))*sin(obj.InitSUrte(4))*cos(obj.InitSUrte(5)) + normrnd(obj.mu,obj.sigma_r);
%             obj.y = (obj.InitSUrte(1)/cos(obj.InitSUrte(4)))*sin(obj.InitSUrte(4))*sin(obj.InitSUrte(5)) + normrnd(obj.mu,obj.sigma_r);
            if obj.InitSUrte(1) < 0
                obj.InitSUrte(1) = 0;
            end
            
            aux_h = x(end,2)*sin(x(end,4))*obj.Ts;

            obj.z = obj.InitSUrte(1); %  + normrnd(obj.mu,obj.sigma_r);
            obj.phi = obj.InitSUrte(4); %  + normrnd(obj.mu,obj.sigma_phi);
            obj.theta = obj.InitSUrte(5); % + normrnd(obj.mu,obj.sigma_theta);
            obj.vz = obj.InitSUrte(2); % velocidad de z
            obj.vphi = obj.InitSUrte(6); % velocidad de phi
            obj.vtheta = obj.InitSUrte(7); % velocidad de theta
            
            obj.xx(iter)=obj.xx(iter-1)+x(end,2)*cos(x(end,4))*cos(x(end,5))*obj.Ts;
            obj.y(iter)=obj.y(iter-1)+x(end,2)*cos(x(end,4))*sin(x(end,5))*obj.Ts;
            
            act_iter = obj.h(iter-1)+aux_h;
            if act_iter < 0
                act_iter = 0;
            end
            
            obj.h(iter)= act_iter;
            obj.T=[obj.T;t+obj.Ts*(iter-1)];
            obj.X =[obj.X;x];
%             disp(size([obj.T;t+obj.Ts*(iter-1)]))
            % incrementar periodo
            if obj.k < obj.Tmax/obj.Ts + 1
                obj.k = obj.k + 1;
            else
                obj.k = obj.Tmax/obj.Ts + 1;
            end
            
            
        end
        function [xt, tt, posx, posy, posz, vz, obj] = read(obj)
            xt = obj.X;
            tt = obj.T;
            posx = obj.xx;
            posy = obj.y;
            posz = obj.h;
            vz = obj.vz;
            obj = [obj.z obj.phi obj.theta];
        end
        function obj = cost(obj)
            obj = [obj.J];
        end
            
    end
end