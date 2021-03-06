% Program for generating n-length FFT's twiddle factor


fft_length = input('Enter FFT length:');

for mm = 0:1:(fft_length-1)
    theta = (-2*pi*mm*1/fft_length);
    
    twiddle(mm+1) = cos(theta) + (1i*(sin(theta)));

    real_twiddle = real(twiddle);
    real_twiddle = real_twiddle';
    im_twiddle = imag(twiddle);
    im_twiddle = im_twiddle';
end

fid = fopen('twiddleFactors.txt','wt');

for fm = 1:1:(fft_length/2)
    fprintf(fid,'%.10f\n',real_twiddle(fm));
    fprintf(fid,'%.10f\n',im_twiddle(fm));
end
    fclose(fid);