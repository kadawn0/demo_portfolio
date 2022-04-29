%% Cargar datos y agregar ruido

clear

load 'angio.mat'
load 'perfusion.mat'

global calls;
calls = 0;

% rango de testeo de parametro de regularizacion
MAXlambda=1; %0.04
minlambda=0;
dlambda=(MAXlambda-minlambda)/5; % /10

colormap(gray);

[Ma, Na] = size(angio);
[Mp, Np] = size(perfusion);

sigma1 = 0.002;
sigma2 = 0.008;

angio1 = imnoise(angio, 'gaussian', 0, sigma1);
angio2 = imnoise(angio, 'gaussian', 0, sigma2);

perfusion = normalize(abs(perfusion));

imwrite(perfusion/max(max(perfusion)), 'perfusion.png');

perf1 = perfusion + sigma1*randn(size(perfusion)); % imnoise(real(perfusion), 'gaussian', 0, sigma1);
perf2 = perfusion + sigma2*randn(size(perfusion)); % imnoise(real(perfusion), 'gaussian', 0, sigma2);


%% Parte 1
% Preguntas 2 y 3 

% %% perfusion.mat
% 
% disp(" ---------------- PERFUSION Sigma = 0.002 --------------------")
% [perf1_salsa, perf1_twist] = Twist_Salsa(perf1, real(perfusion), sigma1, MAXlambda, minlambda, dlambda, Mp, Np, calls);
% 
% disp(" ---------------- PERFUSION Sigma = 0.008 --------------------")
% [perf2_salsa, perf2_twist] = Twist_Salsa(perf2, real(perfusion), sigma2, MAXlambda, minlambda, dlambda, Mp, Np, calls);
% 
% %% angio.mat
% 
% % MAXlambda=0.04; % 0.04
% % minlambda=0;
% % dlambda=(MAXlambda-minlambda)/10;
% 
% disp(" ---------------- ANGIO Sigma = 0.002 --------------------")
% [angio1_salsa, angio1_twist] = Twist_Salsa(angio1, angio, sigma1, MAXlambda, minlambda, dlambda, Ma, Na, calls);
% 
% disp(" ---------------- ANGIO Sigma = 0.008 --------------------")
% [angio2_salsa, angio2_twist] = Twist_Salsa(angio2, angio, sigma2, MAXlambda, minlambda, dlambda, Ma, Na, calls);

%% guardar para pasar a python

% imwrite(angio1, 'angio1.png');
% imwrite(angio2, 'angio2.png');
% 
% imwrite(perf1/max(max(perf1)), 'perf1.png');
% imwrite(perf2/max(max(perf2)), 'perf2.png');

% Parte 1: Pregunta 4 ESTE ADMM LO DEJÉ DE LEGACY PERO NO APARECE EN EL
% INFORME
 

% angio1_admm = easyADMM(angio1, sigma1, minlambda, dlambda, MAXlambda);
% disp("----------------------------------------------------------------");
% 
% angio2_admm = easyADMM(angio2, sigma2, minlambda, dlambda, MAXlambda);
% disp("----------------------------------------------------------------");
% 
% perf1_admm = easyADMM(perf1, sigma1, minlambda, dlambda, MAXlambda);
% disp("----------------------------------------------------------------");
% 
% perf2_admm = easyADMM(perf2, sigma2, minlambda, dlambda, MAXlambda);
% disp("----------------------------------------------------------------");


%% Parte 2

fftnc = @(x) fftshift(fftn(fftshift(x)));
ifftnc = @(x) ifftshift(ifftn(ifftshift(x)));
vec = @(x) x(:);

MAXlambda=1;
minlambda=0;
dlambda=(MAXlambda-minlambda)/10;

angio3 = imnoise(angio,'poisson');
angio4 = imnoise(angio,'salt & pepper',0.01);
angio5 = imnoise(angio,'salt & pepper',0.05);
% 
% scale = 0.2;
% angio3 = imresize(angio3, scale);
% angio4 = imresize(angio4, scale);
% angio5 = imresize(angio5, scale);

muestras = 5;
achicar = @(x, muestras) x(1:muestras:end,1:muestras:end);

angio3 = achicar(angio3, muestras);
angio4 = achicar(angio4, muestras);
angio5 = achicar(angio5, muestras);

% figure; colormap gray; 
% imagesc(angio3); axis off;
% 
% pause

ll = size(angio3);

angio3_g = vec(fftnc(angio3)) ;
angio4_g = vec(fftnc(angio4)) ;
angio5_g = vec(fftnc(angio5)) ;

% h_a = [1 1]*10^(-8);
% lh = length(h_a);
% h_a = h_a/sum(h_a);
% h_a = [h_a zeros(1,length(angio)-length(h_a))];
% h_a = cshift(h_a,-(lh-1)/2);
% h_a = h_a'*h_a;
% 
% H_FFT = fft2(h_a);
% HC_FFT = conj(H_FFT);

psf = zeros(size(angio3));
psf(32, 32) = 1;
 % real(ifft2(H_FFT))


% figure; colormap gray; 
% imagesc(psf); axis off;
% 
% pause

angio3_A = diag(vec(fftnc(psf)));
angio4_A = diag(vec(fftnc(psf)));
angio5_A = diag(vec(fftnc(psf)));

size(angio3);

[Ua3,Sa3,Va3] = svd(angio3_A);
[Ua4,Sa4,Va4] = svd(angio4_A);
[Ua5,Sa5,Va5] = svd(angio5_A);

sigma_a3 = diag(Sa3);
sigma_a4 = diag(Sa4);
sigma_a5 = diag(Sa5);

%% TSVD
disp(" ================ ANGIO POISSON ==================");
for k = 1:(length(sigma_a3)-1)/10:length(sigma_a3)/2
    tic
    angio3_tsvd = KSVD(angio3_g, k, sigma_a3, Ua3, Va3);
    toc
    angio3_tsvd = reshape(angio3_tsvd, ll);
    angio3_tsvd = abs(ifftnc(angio3_tsvd));
    disp("---------------");
    disp(strcat("k: ", " ", num2str(k)));
    figure; colormap gray; 
    imagesc(angio3_tsvd); axis off;
    snapnow;
    close;
end
disp(" ================ ANGIO SALT PEPPER 0.01 ==================");
for k = 1:(length(sigma_a4)-1)/10:length(sigma_a4)/2
    tic
    angio4_tsvd = KSVD(angio4_g, k, sigma_a4, Ua4, Va4);
    toc
    angio4_tsvd = reshape(angio4_tsvd, ll);
    angio4_tsvd = abs(ifftnc(angio4_tsvd));
    disp("---------------");
    disp(strcat("k: ", " ", num2str(k)));
    figure; colormap gray; 
    imagesc(angio4_tsvd); axis off;
    snapnow;
    close;
end
disp(" ================ ANGIO SALT PEPPER 0.05 ==================");
for k = 1:(length(sigma_a5)-1)/10:length(sigma_a5)/2
    tic
    angio5_tsvd = KSVD(angio5_g, k, sigma_a5, Ua5, Va5);
    toc
    angio5_tsvd = reshape(angio5_tsvd, ll);
    angio5_tsvd = abs(ifftnc(angio5_tsvd));
    disp("---------------");
    disp(strcat("k: ", " ", num2str(k)));
    figure; colormap gray; 
    imagesc(angio5_tsvd); axis off;
    snapnow;
    close;
end

%% Tikhonov

disp(" ================ ANGIO POISSON ==================");
for k = minlambda:dlambda:MAXlambda       % este k es lambda
    tic
    angio3_tsvd = Tikhonov(angio3_g, k, sigma_a3, Ua3, Va3);
    toc
    angio3_tsvd = reshape(angio3_tsvd, ll);
    angio3_tsvd = abs(ifftnc(angio3_tsvd));
    disp("---------------");
    disp(strcat("LAMBDA: ", " ", num2str(k)));
    figure; colormap gray; 
    imagesc(angio3_tsvd); axis off;
    snapnow;
    close;
end
disp(" ================ ANGIO SALT PEPPER 0.01 ==================");
for k = minlambda:dlambda:MAXlambda
    tic
    angio4_tsvd = Tikhonov(angio4_g, k, sigma_a4, Ua4, Va4);
    toc
    angio4_tsvd = reshape(angio4_tsvd, ll);
    angio4_tsvd = abs(ifftnc(angio4_tsvd));
    disp("---------------");
    disp(strcat("LAMBDA: ", " ", num2str(k)));
    figure; colormap gray; 
    imagesc(angio4_tsvd); axis off;
    snapnow;
    close;
end
disp(" ================ ANGIO SALT PEPPER 0.05 ==================");
for k = minlambda:dlambda:MAXlambda
    tic
    angio5_tsvd = Tikhonov(angio5_g, k, sigma_a5, Ua5, Va5);
    toc
    angio5_tsvd = reshape(angio5_tsvd, ll);
    angio5_tsvd = abs(ifftnc(angio5_tsvd));
    disp("---------------");
    disp(strcat("LAMBDA: ", " ", num2str(k)));
    figure; colormap gray; 
    imagesc(angio5_tsvd); axis off;
    snapnow;
    close;
end

%% TV gradiente proximal
 
disp(" ================ ANGIO POISSON ==================");
for k = minlambda:dlambda:MAXlambda       % este k es lambda
    tic 
    angio3_tsvd = Salsa_part2(angio3, achicar(angio, muestras), k, "Poisson", Ma, Na, calls, 0.0001);
    toc
end
disp(" ================ ANGIO SALT PEPPER 0.01 ==================");
for k = minlambda:dlambda:MAXlambda  
    tic
    angio4_tsvd = Salsa_part2(angio4, achicar(angio, muestras), k, "Poisson", Ma, Na, calls, 0.01);
    toc
end
disp(" ================ ANGIO SALT PEPPER 0.05 ==================");
for k = minlambda:dlambda:MAXlambda  
    tic
    angio5_tsvd = Salsa_part2(angio5, achicar(angio, muestras), k, "Poisson", Ma, Na, calls, 0.05);
    toc
end
