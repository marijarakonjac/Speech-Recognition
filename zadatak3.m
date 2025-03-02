clear
close all
clc

%% Ucitavanje i predobrada
[y,fs] = audioread('C:\Users\Marija\Documents\MATLAB\opg\projekat\cifre\Osam8.m4a');
T = 1/fs;
t = 0:T:(length(y)-1)*T;
%sound(y,fs)

figure()
plot(t,y)
xlabel('t[s]');
ylabel('y');
title('Jedan');

y_proc = preprocessing(y,fs);
%sound(y,fs)

figure()
plot(y_proc)
ylabel('y');
title('Predobrada');

%% LPC koeficijenti
koef = [9 11 16];
broj_koef = length(koef);
K1 = zeros(10,broj_koef);
K2 = zeros(10,broj_koef);
K3 = zeros(10,broj_koef);

for i = 1:3
   for j = 1:10
      if(i==1)
          cifra = 'Jedan';
      end
      if(i==2)
          cifra = 'Pet';
      end
      if(i==3)
          cifra = 'Osam';
      end
      broj = num2str(j);
      [y,fs] = audioread(['C:\Users\Marija\Documents\MATLAB\opg\projekat\cifre\',cifra,broj,'.m4a']);
      T = 1/fs;
      t = 0:T:(length(y)-1)*T;
      
      y_proc = preprocessing(y,fs);
      lpcs = feature_extraction(y_proc,fs);
      
      if(i==1)
         K1(j,:) = lpcs(koef);
      end
      if(i==2)
         K2(j,:) = lpcs(koef);
      end
      if(i==3)
         K3(j,:) = lpcs(koef);
      end
   end
end

figure()
scatter3(K1(:,1),K1(:,2),K1(:,3))
hold on;
scatter3(K2(:,1),K2(:,2),K2(:,3))
scatter3(K3(:,1),K3(:,2),K3(:,3))
title('Klase cifara na osnovu 9., 11. i 16. koeficijenta');
legend('Jedan','Pet','Osam');

%% KNN
true_labele = [];
prediktovane_labele = [];

for m = 1:3
   for j = 1:5
        if(m==1)
          cifra = 'Jedan';
          true_labela = 1;
        end
        if(m==2)
          cifra = 'Pet';
          true_labela = 2;
        end
        if(m==3)
          cifra = 'Osam';
          true_labela = 3;
        end
        broj = num2str(j+10);
        [x_test,fs] = audioread(['C:\Users\Marija\Documents\MATLAB\opg\projekat\cifre\',cifra,broj,'.m4a']);
        
        x_test_proc  = preprocessing(x_test,fs);
        lpcs = feature_extraction(x_test_proc,fs);
        lpcs_test = lpcs(koef);

        k = 10;

        lista1 = [];
        lista2 = [];
        lista3 = [];

        for i=1:10
            d1 = (sum(lpcs_test-K1(i,:)).^2)^0.5;
            d2 = (sum(lpcs_test-K2(i,:)).^2)^0.5;
            d3 = (sum(lpcs_test-K3(i,:)).^2)^0.5;

            lista1 = [lista1 d1];
            lista2 = [lista2 d2];
            lista3 = [lista3 d3];
        end

        distance = [lista1, lista2, lista3];

        [sortirane_distance, sortirani_indeksi] = sort(distance);
        k_min_distanci = sortirane_distance(1:k);
        k_indeksa = sortirani_indeksi(1:k);

        n = length(lista1); 
        lista_brojac = [0, 0, 0];

        for i = 1:k
            if k_indeksa(i) <= n
                lista_brojac(1) = lista_brojac(1) + 1;
            elseif k_indeksa(i) <= 2 * n
                lista_brojac(2) = lista_brojac(2) + 1;
            else
                lista_brojac(3) = lista_brojac(3) + 1;
            end
        end

        [~, max_liste] = max(lista_brojac);

        if max_liste == 1
            disp('Jedan');
            prediktovana_labela = 1;
        elseif max_liste == 2
            disp('Pet');
            prediktovana_labela = 2;
        else
            disp('Osam');
            prediktovana_labela = 3;
        end
        true_labele = [true_labele; true_labela];
        prediktovane_labele = [prediktovane_labele; prediktovana_labela];
   end
end

confMat = confusionmat(true_labele,prediktovane_labele);
disp('Confusion Matrix:');
disp(confMat);

figure()
confusionchart(confMat,{'Jedan','Pet','Osam'});
title('Konfuziona matrica');

