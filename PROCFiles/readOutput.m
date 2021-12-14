Fs = 1024;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = 1024;             % Length of signal
t = (0:L-1)*T;        % Time vector

S = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t);

fidi=fopen('fftOutputIntegrationDec.txt','r');
fidj=fopen('fftOutputSoftwareDec.txt','r');

Y=cell2mat(textscan(fidi, '%f'));
Z=cell2mat(textscan(fidj, '%f'));

%Expected FFT
W=fft(S,1024);

fclose(fidi);
fclose(fidj);

%frequency
f = Fs*(0:(L/2))/L;

%Integration
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

plot(f,P1) 
title('Integrated Accelerator FFT Plot')
xlabel('f (Hz)')
ylabel('|P1(f)|')

%Software
P3 = abs(Z/L);
P4 = P3(1:L/2+1);
P4(2:end-1) = 2*P4(2:end-1);

plot(f,P4);
title('Software FFT Plot')
xlabel('f (Hz)')
ylabel('|P1(f)|')

%Exptected
P5 = abs(W/L);
P6 = P5(1:L/2+1);
P6(2:end-1) = 2*P6(2:end-1);

plot(f,P6);
title('Expected FFT Plot')
xlabel('f (Hz)')
ylabel('|P1(f)|')
