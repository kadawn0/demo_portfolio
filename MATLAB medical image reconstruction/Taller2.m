%% DATOS
x = zeros(10,1);
x(1) = 1;
y = K(x)+ 1e-1*rand(10,1);
%% OPERADORES
% 1/2 ||y-Kx||2^2 + \lambda ||x||1
% f = \lambda ||x||1
% g = 1/2 ||y-Kx||2^2
K = @(x) fft(x);
KT = @(x) ifft(x);
proxf = @(x,l) max(abs(x)-l,0).*sign(x); %regularizacion
proxg = @(x) x - KT(K(x)-y); %data consistency
Gamma = @(x,l) proxf(proxg(x),l);
%% ITERACION
alpha = .3;
beta = .1;
xk1 = zeros(size(x)); %xk
xk2 = zeros(size(x)); %xk-1

lambda = .1;
xk1 = Gamma(xk1,lambda);
for k = 1:100
    xk2 = xk1;
    xk1 = (1-alpha)*xk2 + (alpha-beta)*xk1 + beta*Gamma(xk1,lambda);
end
%% 
stem(abs(x))
hold on
stem(abs(xk1))
stem(abs(y))
hold off
legend("x real", "TwIST", "y medida")