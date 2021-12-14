import matplotlib.pyplot as plt
from scipy.io import wavfile as wav
from scipy.fft import fft, fftfreq
import numpy as np
import sys

def plt_fft():
    if len(sys.argv) < 1:
        print("Please enter filenames")
        return

    for file in sys.argv:
        if not file.endswith(".wav"):
            print(f'Arg {file} does not contain a ".wav" ending')
            continue
        fig = plt.figure()
        fs, data = wav.read(file)
        data = data.T[0]
        yf = fft(data)
        xf = fftfreq(len(data), 1 / fs)
        plt.plot(xf, np.abs(yf), figure=fig)
    plt.show()

if __name__ == "__main__":
    plt_fft()
