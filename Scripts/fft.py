import matplotlib.pyplot as plt
from scipy.io import wavfile as wav
from scipy.fft import fft, fftfreq
import numpy as np
import sys

def plt_fft():
    if len(sys.argv) < 1:
        print("Please enter filenames")
        return

    for i,file in enumerate(sys.argv):
        if i == 0: 
            continue
        if not file.endswith(".wav"):
            print(f'Arg {file} does not contain a ".wav" ending')
            continue
        fs, data = wav.read(file)
        data = data.T[0]
        filename = file[:-4]
        duration = len(data)/fs
        time = np.arange(0,duration,1/fs) # time vector
        
        # Time domain plot
        plt.figure()
        plt.plot(time,data)
        plt.xlabel('Time [s]')
        plt.ylabel('Amplitude')
        plt.title(f'Time domain of {filename}')
        plt.savefig(f'figures/{filename}_Time')
        plt.close()

        # Freq domain after fft
        plt.figure()
        yf = fft(data)
        xf = fftfreq(len(data), 1 / fs)
        plt.plot(xf, np.abs(yf))
        plt.xlabel('Frequency Hz')
        plt.ylabel('Amplitude')
        plt.title(f'Frequency domain of {filename}')
        plt.savefig(f'figures/{filename}_FFT_Frequency')
        plt.close()

if __name__ == "__main__":
    plt_fft()

