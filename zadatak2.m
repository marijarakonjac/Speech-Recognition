clear
close all
clc

%% Snimanje sekvence
duration = 20;
fs = 8000;

% y = audiorecorder(fs,16,1);
% disp('Start');
% recordblocking(y,duration);
% disp('End');
% x = getaudiodata(y);
%sound(x,fs);
% audiowrite('C:\Users\Marija\Documents\MATLAB\opg\projekat\sekvenca2.wav',x,fs);
[x,fs] = audioread('C:\Users\Marija\Documents\MATLAB\opg\projekat\nikola_sekvenca2.wav');
T = 1/fs;
t = 0:T:(length(x)-1)*T;
L = length(t);

figure(1)
plot(t,x)
xlabel('t[s]');
ylabel('x');
title('Govorna sekvenca');

%% Mi kompanding kvantizator
mi_arr = [100 500];
b = [4 8 12];
Xmax = max(abs(x));

for j = 1:length(mi_arr)
    mi = mi_arr(j);
    for b = [4 8 12]
        aten = 0.01:0.01:1;
        M = 2^b;
        diff = 2*Xmax/M; 
        clear SNR xvar;
        SNR1 = [];
        xvar1 = [];
        for i=1:length(aten)
            x1 = aten(i)*x;
            xvar1 = [xvar1 var(x1)];
            x_comp = Xmax*log10(1+mi*abs(x1)/Xmax)/(log10(1+mi)).*(sign(x1));
            xq_mi = round(x_comp/diff)*diff; 
            x_mi_decomp =1/mi*sign(xq_mi).*((1+mi).^(abs(xq_mi)/Xmax)-1)*Xmax;
            SNR1 = [SNR1 10*log10(var(x1)/var(x1-x_mi_decomp))];
        end
        figure(j+1);
        semilogx(Xmax./(sqrt(xvar1)),SNR1);
        title(['Grafik za mi=',num2str(mi)]);
        hold on;
        legend('b=4','b=8','b=12')
    end
end

%% Delta kvantizator
Q = 0.01;
xmean = mean(x);

diff = zeros(1,L); %prirastaj
diff(1) = x(1);
c = zeros(1,L); %kodna rec
diff_q = zeros(1,L); %kvantizovani prirastaj
diff_q(1) = Q;
x_recon = zeros(1,L); %rekonstruisani signal
x_recon(1) = xmean + diff_q(1);

for i = 2:L
    diff(i) = x(i)-x_recon(i-1);
    if diff(i)>0
        c(i) = 0; 
        diff_q(i) = Q;
    else
        c(i) = 1;
        diff_q(i) = -Q;
    end
    x_recon(i) = x_recon(i-1)+diff_q(i);
end

%Histogram
figure()
histogram(diff)
title('Histogram prirastaja');
xlim([-0.03 0.03])

diff_abs = abs(diff);
diff_abs = sort(diff_abs);
Q_hist = diff_abs(round(0.9*length(diff_abs))); %trazimo delta da pokriva 90% povrsine

figure()
plot(t,x);
hold on;
plot(t,x_recon)
title('Delta kvantizator');
legend('originalni','rekonstruisani');

figure()
plot(t,diff_q,'x')
title('Korak kvantizacije');

%% Adaptivni delta kvantizator 
Qmin = 0.001; 
Qmax = 0.05; 
P = 1.5; %najcesce u intervalu (1.25,2)
%P*Q<=1
xmean = mean(x);

diff = zeros(1,L);
diff(1) = x(1);
c = zeros(1,L);
diff_q = zeros(1,L);
diff_q(1) = (Qmin+Qmax)/2;
x_recon = zeros(1,L);
x_recon(1) = xmean + diff_q(1);

for i = 2:L
    diff(i) = x(i)-x_recon(i-1);
    if diff(i)>0
        c(i) = 0;
    else
        c(i) = 1;
    end
    if c(i)==c(i-1)
        M = P;
    else
        M = 1/P;
    end
    diff_q(i) = M*diff_q(i-1);
    diff_q(i) = max(Qmin,min(Qmax,diff_q(i)));
    if c(i)==0
       x_recon(i) = x_recon(i-1)+diff_q(i); 
    else
        x_recon(i) = x_recon(i-1)-diff_q(i);
    end
end

figure()
plot(t,x);
hold on;
plot(t,x_recon);
legend('originalni','rekonstruisani');
title('Adaptivni delta kvantizator');

figure()
plot(t,diff_q,'x')
title('Korak kvantizacije');