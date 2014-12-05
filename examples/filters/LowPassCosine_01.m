n = 0:300;
T = 0.2;
% sampled input waveform x[n]
x = 1 + cos (T * n) + cos (20 * T * n);
% sampled output waveform y[n]
hd = [0.00682160223685108,0.0205455195681673,0.0620929929427971,0.124783664238318,0.182647739345040,0.206216963337653,0.182647739345040,0.124783664238318,0.0620929929427971,0.0205455195681673,0.00682160223685108];
%hd = [0.00875474290329771,0.0479488721685246,0.164024391089411,0.279271993838767,0.279271993838767,0.164024391089411,0.0479488721685246,0.00875474290329771];
y = filter(hd, 1, x);
% plot x(t)
t = 0:.1:30;
subplot (211);
plot(n*T, x);
subplot (212);
plot(n*T, y);