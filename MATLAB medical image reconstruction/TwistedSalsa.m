function [a, b] = TwistedSalsa(U, M, calls, name, option, Ma, Na, Mu, C)
    calls_salsa = 0;
    calls_twist = 0;
    % denoising function;
    tv_iters = 5;
    Psi = @(x,th)  tvdenoise(x, 2/th, tv_iters);
    Phi = @(x) TVnorm(x);
    % Parameters
    tolA = 1e-4;
    lam1 = 1;% 1e-4;    
    tau = 1e-18; %2e-2*1^2/0.56^2;;

    h_a = [1 1]*10^(-8);
    lh = length(h_a);
    h_a = h_a/sum(h_a);
    h_a = [h_a zeros(1,length(M)-length(h_a))];
    h_a = cshift(h_a,-(lh-1)/2);
    h_a = h_a'*h_a;

    H_FFT = fft2(h_a);
    HC_FFT = conj(H_FFT);

    %%%% algorithm parameters
    % lambda = 2.5e-2; % reg parameter
    mu = 0;
    outeriters = 500;

    % denoising function;
    tv_iters = 5;
    Psi_TV = @(x,th)  tvdenoise(x,2/th,tv_iters);
    % TV regularizer;
    Phi_TV = @(x) TVnorm(x);
    
    if option ==1
        A = Cartesian_SENSE(U, C);
        AT = A;
        x = M;
        y = A*x;
        x0 = A'*(A*x);
        
%         Aa = @(x) real(ifft2(H_FFT.*fft2(x))); % @(x) real(eye(size(x)));
%         ATa = @(x) real(ifft2(HC_FFT.*fft2(x))); % @(x) real(eye(size(x)));
%         Aa = @(x) callcounter(Aa,x);
%         ATa = @(x) callcounter(ATa,x);
    else
%         A = @(x) real(ifft2(H_FFT.*fft2(x))); % @(x) real(eye(size(x)));
%         AT = @(x) real(ifft2(HC_FFT.*fft2(x))); % @(x) real(eye(size(x)));
        A = (@(x) callcounter(@(x) ktoi(U.*itok(x)),x)); % @(x) ktoi(U.*itok(x));
        AT = (@(x) callcounter(@(x) ktoi(U.*itok(x)),x)); % @(x) ktoi(U.*itok(x));
        x = M;
        y = A(x);
        x0 = AT(A(x));
%         A = @(x) callcounter(A,x);
%         AT = @(x) callcounter(AT,x);
        
    end

    filter_FFT = 1./(abs(H_FFT).^2 + mu);
    invLS = @(x) real(ifft2(filter_FFT.*fft2( x )));

    invLS = @(x) callcounter(invLS,x);

    if option == 1
        % -- SALSA ---------------------------
        [angio1_salsa, numA, numAt, objective, distance, times, mses] = ...
                         SALSA_v2(y, (@(x) mtimes_alt(U,C,x,1)), lam1,...
                         'AT', (@(x) mtimes_alt(U,C,x,2)), ...
                         'StopCriterion', 3, ...
                         'True_x', M, ...
                         'ToleranceA', tolA,...
                         'MAXITERA', outeriters, ...
                         'TVINITIALIZATION', 1, ...
                         'TViters', 10, ...
                         'LS', invLS, ...
                         'VERBOSE', 0);
        imwrite(abs([x0 angio1_salsa]), sprintf('SALSA_%s.jpg', name))
  
        mse_angio1 = norm(M-angio1_salsa,'fro')^2 /(Ma*Na);
        ISNR_angio1 = 10*log10( norm(angio1_salsa-M,'fro')^2 / (mse_angio1*Ma*Na) );
        cpu_time = times(end);

        calls_salsa = calls;
        calls = 0;
        
        % -- TwIST ---------------------------
        [x_twist,dummy,obj_twist,time_twist,dummy,mse_twist] = TwIST(y,A,tau,'lambda',lam1,'Psi', Psi, ...
                 'Phi',Phi,'Monotone',1,'Initialization',x0,'StopCriterion',3,...
                 'ToleranceA',tolA,'Verbose', 0);
        imwrite(abs([x0 x_twist]), sprintf('TWIST_%s.jpg', name)) 
        bar(abs(obj_twist))
        
        twist_mse_angio1 = norm(M-x_twist,'fro')^2 /(Ma*Na);
        ISNR_twist_angio1 = 10*log10(  norm(x_twist-M,'fro')^2 / (twist_mse_angio1*Ma*Na) );
        twist_time = time_twist(end);


        calls_twist = calls;
        calls = 0;
 
  
    else
        % -- SALSA ---------------------------
        [angio1_salsa, numA, numAt, objective, distance, times, mses] = ...
                         SALSA_v2(y, A, lam1,...
                         'AT', AT, ...
                         'StopCriterion', 3, ...
                         'True_x', M, ...
                         'ToleranceA', tolA,...
                         'MAXITERA', outeriters, ...
                         'TVINITIALIZATION', 1, ...
                         'TViters', 10, ...
                         'LS', invLS, ...
                         'VERBOSE', 0);
        fprintf('SALSA_%s.jpg\n', name)
        imwrite(abs([x0 angio1_salsa]), sprintf('SALSA_%s.jpg', name))

        mse_angio1 = norm(M-angio1_salsa,'fro')^2 /(Ma*Na);
        ISNR_angio1 = 10*log10( norm(angio1_salsa-M,'fro')^2 / (mse_angio1*Ma*Na) );
        cpu_time = times(end);

        calls_salsa = calls;
        calls = 0;
        % -- TwIST ---------------------------
%         [x_twist,~,obj_twist,~,~,~] = TwIST(Mu,A,tau,'lambda',lam1,'AT', AT, 'Psi', Psi, ...
%                  'Phi',Phi,'Monotone',1,'StopCriterion',1,...
%                  'ToleranceA',tolA,'Verbose', 1);
        [x_twist,dummy,obj_twist,time_twist,dummy,mse_twist] = TwIST(y, A, lam1, ...
                  'AT', AT, ...
                  'StopCriterion',3, ...
                  'True_x', M, ...
                  'ToleranceA',objective(end), ...
                  'PSI', Psi, ...
                    'PHI', Phi, ...
                  'VERBOSE', 0);
        imwrite(abs([x0 x_twist]), sprintf('TWIST_%s.jpg', name)) 
        bar(abs(obj_twist))
        
        twist_mse_angio1 = norm(M-x_twist,'fro')^2 /(Ma*Na);
        ISNR_twist_angio1 = 10*log10(  norm(x_twist-M,'fro')^2 / (twist_mse_angio1*Ma*Na) );
        twist_time = time_twist(end);


        calls_twist = calls;
        calls = 0;

        
    end
    
    %%%% display results and plots
    fprintf('TwIST CPU time = %3.3g seconds, iters = %d \tMSE = %3.3g, ISNR = %3.3g dB\n', twist_time, length(time_twist), twist_mse_angio1, ISNR_twist_angio1)
    fprintf('SALSA\n CPU time = %3.3g seconds, iters = %d \tMSE = %3.3g, ISNR = %3.3g dB\n', cpu_time, length(objective), mse_angio1, ISNR_angio1)

    a = x_twist;
%     b = angio1_salsa;
    b = 0;
end