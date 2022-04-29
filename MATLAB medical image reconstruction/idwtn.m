function y = idwtn(x,L,h)
    if ~exist('L','var')
        L = 2;
    end
    if ~exist('h','var')
        h = compute_wavelet_filter('Daubechies',4);
    end
    %Its assumed thad every dimension its a power of two
    y = squeeze(x);
    Ndims = length(size(x));
    switch Ndims
        case 3
            for k = 1:size(x,3)
                yk = y(:,:,k);
                y(:,:,k) = midwt(real(yk), h, L) + 1i*midwt(imag(yk),h, L);
            end
            y = permute(y,[3 1 2]);
            for i = 1:size(x,1)
                for j = 1:size(x,2)
                    yij = y(:,i,j);
                    y(:,i,j) = midwt(real(yij), h, L) + 1i*midwt(imag(yij),h, L);
                end
            end
            y = ipermute(y,[3 1 2]);
        otherwise
            y = midwt(real(x), h, L) + 1i*midwt(imag(x),h, L);
    end
end
