function Tp = estimator(x,lambda,tau,win,fs)
idx = find(x,1); %prvi nenulti odbirak, maksimum
pocetak = idx + tau; %tau u broju odbiraka
A = x(idx);
kraj = 0;

for i = pocetak:win
   if x(i)>=A*exp(-lambda.*(i-pocetak))
       kraj = i;
       break;
   end
end
if kraj == 0
    Tp = win/fs; %delimo sa fs da bi bilo u sekundama; win je bilo u odbircima
else
    Tp = (kraj-idx)/fs;
end

end