function [m1,m2,m3,m4,m5,m6] = formiranje_sekvenci(x)
N = length(x);
maxs = zeros(1,N);
mins = zeros(1,N);
maxidx = [];
minidx = [];
m1 = zeros(1,N);
m2 = zeros(1,N);
m3 = zeros(1,N);
m4 = zeros(1,N);
m5 = zeros(1,N);
m6 = zeros(1,N);

%Formiranje m1 i m4
for i = 2:N-1 %jer razmatramo prethodnika i sledbenika za svakog
    if x(i)>x(i-1) && x(i)>x(i+1)
       maxs(i) = x(i);
       maxidx = [maxidx i];
       m1(i) = max(0,x(i));
    end
    if x(i)<x(i-1) && x(i)<x(i+1)
       mins(i) = x(i);
       minidx = [minidx i];
       m4(i) = max(0,-x(i));
    end
end

%Formiranje m2 i m3
maxp = 0;
for i = maxidx
    if isempty(find(minidx<i,1,'last'))
        minp = 0;
    else
        idx = find(minidx<i,1,'last');
        minp = mins(idx);
    end
    m2(i) = max(0,maxs(i)-minp);
    m3(i) = max(0,maxs(i)-maxp);
    maxp = maxs(i);
end

%Formiranje m5 i m6
minp = 0;
for i = minidx
   if isempty(find(maxidx<i,1,'last'))
       maxp = 0;
   else
       idx = find(maxidx<i,1,'last');
       maxp = maxs(idx);
   end
   m5(i) = max(0,-mins(i)+maxp);
   m6(i) = max(0,-mins(i)+minp);
   minp = mins(i);
end

end