clear all
load M.mat
load C.mat

global calls;
calls = 0;


%%
imshow(abs(M),[])
montage(abs(C)/max(abs(C(:))))
[MM, NN] = size(M);
fftnc = @(x) fftshift(fftn(fftshift(x)));
ifftnc = @(x) ifftshift(ifftn(ifftshift(x)));
vec = @(x) x(:);

%% máscaras de muestreo
% U4 = zeros(size(M)); %Ua4
% U8 = zeros(size(M)); % Ua8
% U4(1:4:end, :) = 1;
% U8(1:8:end, :) = 1;
% imshow([U4 U8])
% imshow(abs(ktoi(itok(M).*U4)),[])
%% Densidad variable
p = 16; % grado del polinomio de aproximación
percent = 1/4;
distType = 2; % L2
radius = .1;
dispp = 1;
[pdf,val] = genPDF(size(M, 1),p,percent,distType,radius,dispp);
% pdf = regmat(pdf, size(M,2), 1);

iter_samples = 10;
tol = 1;
[UA4,stat,actpctg] = genSampling(pdf,iter_samples,tol);


percent = 1/8;
[pdf,val] = genPDF(size(M, 1),p,percent,distType,radius,dispp);
% pdf = regmat(pdf, size(M,2), 1);

[UA8,stat,actpctg] = genSampling(pdf,iter_samples,tol);


figure
imshow([UA4 UA8])
%% Cartesian SENSE and TV
addpath("./TwIST_v2")
% addpath("./Archivos_Tarea_5/")
%Encoding operator

M_ua4 = ifftnc(UA4.*fftnc(M));
M_ua8 = ifftnc(UA8.*fftnc(M));

% UA4
[ua4_twist_p1, ua4_salsa_p1] = TwistedSalsa(UA4, M_ua4, calls, "UA4_part1",2, MM, NN, M_ua4, C);
% UA8
[ua8_twist_p1, ua8_salsa_p1] = TwistedSalsa(UA8, M_ua8, calls, "UA8_part1",2, MM, NN, M_ua4, C);

% UA4
[ua4_twist, ua4_salsa] = TwistedSalsa(UA4, M, calls, "UA4_part2", 1, MM, NN, M_ua4, C);
% UA8
[ua8_twist, ua8_salsa] = TwistedSalsa(UA8, M, calls, "UA8_part2", 1, MM, NN, M_ua4, C);

% %%
% figure;
% subplot 211, imshow(abs([x0 x x_twist]),[]) 
% subplot 212, plot(abs(obj_twist))
     
%% transformada wavelet
% --------------- forma 1 --------------
% h = daubcqf(4,'min');
% L = 2;
% [WM_r, L] = mdwt(real(M), h, L);
% [WM_im, L] = mdwt(imag(M), h, L);
% WM = WM_r + WM_im;

% -------------- forma 2 ---------------
L = 2;
h = compute_wavelet_filter('Daubechies',4);
WM = dwtn(M, L); % el wavelet filter viene por default

% -------------- mostrar ---------------
figure;
imshow(abs(WM), [])
% imwrite(abs(WM), 'Resultado.png')

%% FISTA
A = Cartesian_SENSE(UA4, C);
x = M;
y = A*x;
x0 = A'*(A*x);

lambdas = linspace(-8,-4,15);
error = zeros(size(lambdas));
k = 1;
best_error = 1e100;
% ant_error = 0;
disp(" ------------------ ")
for lambda = 10.^lambdas
% lambda = 0.1;
    f = @(x) lambda*norm(x,1);
    vec = @(x) x(:);
    g = @(x) (1/2)*sqrt(sum(vec(abs(E*WT(x))).^2));
    F = @(x) f(x) + g(x);
    % C = ones(size(M));
    E = Cartesian_SENSE(UA4, C);
    W = @(x) dwtn(x);
    WT = @(x) idwtn(x);
    proxf = @(x, t) max(abs(x) - lambda*t, 0).*sign(x);
    gradg = @(x) W(E'*((E*WT(x)) - y));

    alpha0 = W(x0);
    L = 10; % 1e1
    niter = 50;
    [alpha_fista, obj] = FISTA(alpha0, proxf, gradg, L, niter, F, 10^(-5));
    x_fista = WT(alpha_fista);
    fprintf("Lambda = %e, Finished ", lambda)
    error(k) = norm(x - x_fista, "fro");
    if error(k) < best_error
        x_opt = x_fista;
        best_error = error(k);
        fprintf("*\n",0)
        save("best_result.mat", 'x_opt', 'lambda')
    else
        fprintf("\n",0)
    end
    k = k + 1;
%     if ant_error > error(k):
%         break
%     end
%     ant_error = error(k);
end
figure;
subplot 311
imshow(abs([x0 x x_fista]), [])
% imshow(abs([x x_fista]), [])
subplot 312
semilogy(obj)
subplot 313
loglog(lambdas, error)

pause

A = Cartesian_SENSE(UA8, C);
x = M;
y = A*x;
x0 = A'*(A*x);

lambdas = linspace(-8,-4,15);
error = zeros(size(lambdas));
k = 1;
best_error = 1e100;
% ant_error = 0;
disp(" ------------------ ")
for lambda = 10.^lambdas
% lambda = 0.1;
    f = @(x) lambda*norm(x,1);
    vec = @(x) x(:);
    g = @(x) (1/2)*sqrt(sum(vec(abs(E*WT(x))).^2));
    F = @(x) f(x) + g(x);
    % C = ones(size(M));
    E = Cartesian_SENSE(UA8, C);
    W = @(x) dwtn(x);
    WT = @(x) idwtn(x);
    proxf = @(x, t) max(abs(x) - lambda*t, 0).*sign(x);
    gradg = @(x) W(E'*((E*WT(x)) - y));

    alpha0 = W(x0);
    L = 10; % 1e1
    niter = 50;
    [alpha_fista, obj] = FISTA(alpha0, proxf, gradg, L, niter, F, 10^(-5));
    x_fista = WT(alpha_fista);
    fprintf("Lambda = %e, Finished ", lambda)
    error(k) = norm(x - x_fista, "fro");
    if error(k) < best_error
        x_opt = x_fista;
        best_error = error(k);
        fprintf("*\n",0)
        save("best_result.mat", 'x_opt', 'lambda')
    else
        fprintf("\n",0)
    end
    k = k + 1;
%     if ant_error > error(k):
%         break
%     end
%     ant_error = error(k);
end
figure;
subplot 311
imshow(abs([x0 x x_fista]), [])
% imshow(abs([x x_fista]), [])
subplot 312
semilogy(obj)
subplot 313
loglog(lambdas, error)
