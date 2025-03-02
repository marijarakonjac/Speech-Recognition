function lpcs = feature_extraction(y,fs)
p = 16; 
win = 20e-3*fs;
num = round(length(y)/win);
lpcs = zeros(num,p+1);
k=1;

for i=1:win:(length(y)-win)
    lpcs(k,:) = aryule(y(i:(i+win-1)),p);
    k = k+1;
end

lpcs = median(lpcs,1);

end