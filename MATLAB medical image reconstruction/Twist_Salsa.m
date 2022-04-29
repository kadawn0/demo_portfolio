function [angio1_salsa, angio1_twist] = Twist_Salsa(angio1, angio, sigma, MAXlambda, minlambda, dlambda, Ma, Na, calls)

    %%%% function handle for uniform blur operator (acts on the image
    %%%% coefficients)
    h_a = [1 1]*10^(-8);
    lh = length(h_a);
    h_a = h_a/sum(h_a);
    h_a = [h_a zeros(1,length(angio)-length(h_a))];
    h_a = cshift(h_a,-(lh-1)/2);
    h_a = h_a'*h_a;

    H_FFT = fft2(h_a);
    HC_FFT = conj(H_FFT);

    A = @(x) real(ifft2(H_FFT.*fft2(x))); % @(x) real(eye(size(x)));
    AT = @(x) real(ifft2(HC_FFT.*fft2(x))); % @(x) real(eye(size(x)));

    A = @(x) callcounter(A,x);
    AT = @(x) callcounter(AT,x);

    %%%% algorithm parameters
    % lambda = 2.5e-2; % reg parameter
    mu = 0;
    outeriters = 500;
    tol = 1e-5;

    % denoising function;
    tv_iters = 5;
    Psi_TV = @(x,th)  tvdenoise(x,2/th,tv_iters);
    % TV regularizer;
    Phi_TV = @(x) TVnorm(x);

    filter_FFT = 1./(abs(H_FFT).^2 + mu);
    invLS = @(x) real(ifft2(filter_FFT.*fft2( x )));

    invLS = @(x) callcounter(invLS,x);


    figure; colormap gray; 
    title(strcat('Sigma= ', ' ', num2str(sigma)));
    imagesc(angio1); axis off;
    snapnow;
    close;

    for lambda=minlambda:dlambda:MAXlambda
        disp("---------------");
        disp(strcat("LAMBDA: ", " ", num2str(lambda)));
        fprintf('Running SALSA...\n')
        [angio1_salsa, numA, numAt, objective, distance, times, mses] = ...
                 SALSA_v2(angio1, A, lambda,...
                 'AT', AT, ...
                 'StopCriterion', 3, ...
                 'True_x', angio, ...
                 'ToleranceA', tol,...
                 'MAXITERA', outeriters, ...
                 'TVINITIALIZATION', 1, ...
                 'TViters', 10, ...
                 'LS', invLS, ...
                 'VERBOSE', 0);
        mse_angio1 = norm(angio1-angio1_salsa,'fro')^2 /(Ma*Na);
        ISNR_angio1 = 10*log10( norm(angio1-angio,'fro')^2 / (mse_angio1*Ma*Na) );
        cpu_time = times(end);

        calls_salsa = calls;
        calls = 0;
        
        
        figure; colormap gray; 
        title('SALSA restored image')
        imagesc(angio1_salsa); axis off;
        snapnow;
        close;
        
        %pause
        
        fprintf('Running TwIST...\n')
        [angio1_twist,dummy,obj_twist,time_twist,dummy,mse_twist] = TwIST(angio1, A, lambda, ...
                  'AT', AT, ...
                  'StopCriterion',3, ...
                  'True_x', angio, ...
                  'ToleranceA',objective(end), ...
                  'PSI', Psi_TV, ...
                    'PHI', Phi_TV, ...
                  'VERBOSE', 0);
        twist_mse_angio1 = norm(angio-angio1_twist,'fro')^2 /(Ma*Na);
        ISNR_twist_angio1 = 10*log10(  norm(angio1-angio,'fro')^2 / (twist_mse_angio1*Ma*Na) );
        twist_time = time_twist(end);

        calls_twist = calls;
        calls = 0;

        figure; colormap gray; 
        title('TwIST restored image')
        imagesc(angio1_twist); axis off;
        snapnow;
        close;

        %%%% display results and plots
        fprintf('TwIST CPU time = %3.3g seconds, iters = %d \tMSE = %3.3g, ISNR = %3.3g dB\n', twist_time, length(time_twist), twist_mse_angio1, ISNR_twist_angio1)
        fprintf('SALSA\n CPU time = %3.3g seconds, iters = %d \tMSE = %3.3g, ISNR = %3.3g dB\n', cpu_time, length(objective), mse_angio1, ISNR_angio1)

        figure, semilogy(time_twist, obj_twist, 'b', 'LineWidth',1.8), hold on, 
        semilogy(times, objective,'r--', 'LineWidth',1.8),
        title('Objective function 0.5||y-Ax||_{2}^{2}+\lambda \Phi_{TV}(x)','FontName','Times','FontSize',14),
        set(gca,'FontName','Times'),
        set(gca,'FontSize',14),
        xlabel('seconds'), 
        legend('TwIST', 'SALSA');
        snapnow;
        close;
    end
end