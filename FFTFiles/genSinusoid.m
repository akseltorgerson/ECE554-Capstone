Fs = 1024;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = 1024;             % Length of signal
t = (0:L-1)*T;        % Time vector

S = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t);

fid = fopen('testSignalDec.txt','wt');

for fm = 1:1:(L)
    fprintf(fid,'%.10f\n',S(fm));
    fprintf(fid,'%.10f\n',S(1));
end
fclose(fid);

