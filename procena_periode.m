function [pt1, pt2, pt3, pt4, pt5, pt6, pt] = procena_periode(fs,N,m1,m2,m3,m4,m5,m6)
win = round(fs*15e-3); %sirina prozora u odbircima
NN = floor(N/(win/2)); %broj procena
pt1 = zeros(1,NN);
pt2 = zeros(1,NN);
pt3 = zeros(1,NN);
pt4 = zeros(1,NN);
pt5 = zeros(1,NN);
pt6 = zeros(1,NN);
pt = zeros(1,NN);

lambda = 120/fs; %lambda pripada od 115 do 120 s^-1
tau = round(fs*4e-3);
k = 1;
%pt(1) = 200;
for k_win = 1:win/2:N-win+1
    x = m1(k_win:k_win+win-1);
    pt1(k) = estimator(x,lambda,tau,win,fs);
    x = m2(k_win:k_win+win-1);
    pt2(k) = estimator(x,lambda,tau,win,fs);
    x = m3(k_win:k_win+win-1);
    pt3(k) = estimator(x,lambda,tau,win,fs);
    x = m4(k_win:k_win+win-1);
    pt4(k) = estimator(x,lambda,tau,win,fs);
    x = m5(k_win:k_win+win-1);
    pt5(k) = estimator(x,lambda,tau,win,fs);
    x = m6(k_win:k_win+win-1);
    pt6(k) = estimator(x,lambda,tau,win,fs);
    pt(k) = nanmedian([pt1(k),pt2(k),pt3(k),pt4(k),pt5(k),pt6(k)]);
    k = k+1;
end
end