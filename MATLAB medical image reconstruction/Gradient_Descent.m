function m = Gradient_Descent(B, E, iterations)
    m_k = E'*B; % reconstruccion zero fill
    r_k = m_k - E'*(E*m_k);
    vec = @(x) x(:);
    
    for k = 1:iterations
        alpha_k = (vec(r_k)'*vec(r_k))/(vec(r_k)'*vec(E'*(E*r_k)));
        m_k = m_k + alpha_k*r_k;
        r_k = r_k - alpha_k*(E'*(E*r_k));
    end
    
    m = m_k;
end