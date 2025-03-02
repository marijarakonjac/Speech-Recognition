clear
close all
clc

%% Snimanje sekvence
duration = 20;
fs = 8000;

% x = audiorecorder(fs,16,1);
% disp('Start');
% recordblocking(x,duration);
% disp('End');
% y = getaudiodata(x);
% %sound(y,fs);
% audiowrite('C:\Users\Marija\Documents\MATLAB\opg\projekat\sekvenca1.wav',y,fs);

[y,fs] = audioread('C:\Users\Marija\Documents\MATLAB\opg\projekat\sekvenca1.wav');
T = 1/fs;
t = 0:T:(length(y)-1)*T;
%sound(y,fs);

figure()
plot(t,y)
xlabel('t[s]');
ylabel('y');
title('Govorna sekvenca');

%% Kratkovremenska energija i kratkovremenska brzina prolaska kroz nulu
window_length = fs*20e-3;
E = zeros(1,length(y)); 
Z = zeros(1,length(y));
for i = window_length:length(y)-1
   range = i-window_length+1:i;
   E(i) = sum(y(range).^2);
   Z(i) = sum(abs(sign(y(range+1))-sign(y(range))));
end
Z = Z/2/window_length;

figure()
plot(t,y,t,E);
title('Kratkovremenska energija');
figure()
plot(t,y,t,Z);
title('Zero-crossing rate');

%Algoritam za segmentaciju
ITU = max(E)*0.1;
ITL = max(E)*0.001;
beginning = [];
ending = [];

for i = 2:length(E)
   if(E(i-1)<ITU && E(i)>ITU)
       beginning = [beginning i];
   end
end

for i = 1:length(E)-1
   if(E(i)>ITU && E(i+1)<ITU)
      ending = [ending i]; 
   end
end

word = zeros(1,length(y));
for i = 1:length(beginning)
    word(beginning(i):ending(i)) = ones(1,ending(i)-beginning(i)+1);
end
figure()
plot(t,y,t,word);
ylim([0 1.5]);

%Prosirenje reci
for i = 1:length(beginning)
   while(E(beginning(i))>ITL)
      beginning(i) = beginning(i)-1;
   end
   while(E(ending(i))>ITL)
      ending(i) = ending(i)+1; 
   end
end
beginning = unique(beginning);
ending = unique(ending);
word = zeros(1,length(y));
for i = 1:length(beginning)
    word(beginning(i):ending(i)) = ones(1,ending(i)-beginning(i)+1);
end
figure()
plot(t,y,t,word);
ylim([0 1.5]);

%Preslusavanje segmentiranih reci
for i = 1:length(beginning)
   sound(y(beginning(i):ending(i)),fs); 
   pause
end

%% Pitch perioda
clear
clc
duration = 5;
fs = 8000;

% x = audiorecorder(fs,16,1);
% disp('Start');
% recordblocking(x,duration);
% disp('End');
% y = getaudiodata(x);
% sound(y,fs);
% audiowrite('C:\Users\Marija\Documents\MATLAB\opg\projekat\onomatopeja.wav',y,fs);
 
[y,fs] = audioread('C:\Users\Marija\Documents\MATLAB\opg\projekat\onomatopeja.wav');
sound(y,fs);

%Vizuelizacija signala
figure()
t = 0:1/fs:(length(y)-1)/fs;
plot(t,y)
xlabel('t[s]');
ylabel('y(t)');
title('Sekvenca za odredjivanje pitch periode');

%% Filtriranje signala
wn = [60 300]/(fs/2);
[b,a] = butter(6,wn,'bandpass');
yf = filter(b,a,y);
figure()
plot(t,yf)
xlabel('t[s]');
ylabel('yf(t)');
title('Sekvenca - filtrirana');

%% Metoda paralelnog procesiranja
[m1,m2,m3,m4,m5,m6] = formiranje_sekvenci(yf);
n = 1:500;
figure()
subplot(3,1,1)
stem(n,yf(n))
subplot(3,1,2)
stem(n,m1(n))
subplot(3,1,3)
stem(n,m2(n))

figure()
subplot(4,1,1)
stem(n,m3(n))
subplot(4,1,2)
stem(n,m4(n))
subplot(4,1,3)
stem(n,m5(n))
subplot(4,1,4)
stem(n,m6(n))

[p1,p2,p3,p4,p5,p6,p] = procena_periode(fs,length(yf),m1,m2,m3,m4,m5,m6);
figure()
hold on;
plot(1./p,'LineWidth',1.5);

disp(['Metoda paralelnog procesiranja: ',num2str(1/median(p)),'Hz']);

%% Procena na osnovu autokorelacione funkcije
cl = 0.3*max(abs(yf));
y_clipped = three_level_clipping(yf, cl);

figure()
plot(t,yf)
hold on;
plot(t,y_clipped*max(yf));
title('Three-level klipovanje');
legend('originalni','klipovani');
xlabel('t[s]'); 
ylabel('y(t)');

p = 150;
N = length(y_clipped);
rxx = zeros(2*p+1,1);
for k = (p+1):(2*p+1)
    rxx(k) = sum(conj(y_clipped(1:(N-k+p+1))).*y_clipped((1+k-(p+1)):N))/N;
end
rxx(p:-1:1) = conj(rxx(p+2:end));

figure()
plot(rxx(round(length(rxx)/2):end))
title('Autokorelaciona funkcija')
xlabel('k[odb]'); 
ylabel('r_x_x[k]')

figure()
plot(y,y_clipped,'*')
xlabel('y')
ylabel('y_c_l_i_p')
title('Three-level klipovanje')

disp(['Procena pomocu autokorelacione funkcije: ',num2str(fs/40),'Hz']);
disp(['Ugradjena metoda: ',num2str(median(pitch(yf,fs))),'Hz']);

