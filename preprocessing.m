function y_proc = preprocessing(y,fs)
T = 1/fs;
t = 0:T:(length(y)-1)*T;

window_length = fs*20e-3;
E = zeros(1,length(y)); 

for i = window_length:length(y)-1
   range = i-window_length+1:i;
   E(i) = sum(y(range).^2);
end

% figure()
% plot(t,y,t,E);
% title('Kratkovremenska energija');

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

%Prosirenje reci
for i = 1:length(beginning)
   while(E(beginning(i))>ITL)
      beginning(i) = beginning(i)-1;
   end
   while(E(ending(i))>ITL)
      ending(i) = ending(i)+1; 
   end
end

word_new = zeros(1,length(word));
word_new(beginning(1):ending(end)) = 1;
% figure()
% plot(t,y,t,word_new);
% ylim([0 1.5]);

y_proc = y(beginning(1):ending(end));

%Filtriranje
[b, a] = butter(6, 3000/(0.5*fs), 'low');
y_proc = filter(b, a, y_proc);

end

