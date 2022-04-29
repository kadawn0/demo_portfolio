tff=tf([1], [2 1]);
[num,den] = tfdata(tff);
syms s Ut
G_sym = poly2sym(cell2mat(num),s)/poly2sym(cell2mat(den),s)
y_time_sym = ilaplace(G_sym*Ut/s)