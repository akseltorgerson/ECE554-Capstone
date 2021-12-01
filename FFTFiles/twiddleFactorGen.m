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
    if (fm == 1)
        fprintf(fid,'[');
    end
    fprintf(fid,'%.10f, %.10f,\n',real_twiddle(fm), im_twiddle(fm));
    if (fm == fft_length/2)
        fprintf(fid,']');
    end
end
fclose(fid);