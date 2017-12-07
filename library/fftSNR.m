function fftSNR(Fs, f, duration, SNR)

%
% function fftSNR(Fs, f, duration, SNR)
%
% ARGUMENTS:
% - Fs: sampling frequency
% - f:  frequencies of the tones (the signal is generated as sum of
%       sinusoidal signals)
% - duration: the duration of the signal (in seconds)
% - SNR: the signal to noise ratio (in dBs)
% 

t = 0:1/Fs:duration;                % time vector
% signal definition:
x = cos(2*f(1)*pi*t);               % a. clean signal:
for (i=2:length(f)) x = x + cos(2*f(i)*pi*t);  end
x = x / length(f);                  % signal normalization
y = awgn(x, SNR, 'measured');       % b. noisy signal:

% compute the magnitude of the spectrum of x and y:
[X, FreqX] = getDFT(x, Fs); [Y, FreqY] = getDFT(y, Fs);

% plot the results:
figure; subplot(2,1,1); plot(FreqX, log10(X), 'k');
axis([1 max(FreqX) -5 0]);
title('Log-magnitude of the Spectrum of the original (clean) signal');
xlabel('Frequency (Hz)');
subplot(2,1,2); plot(FreqY, log10(Y), 'k');
axis([1 max(FreqX) -5 0]);
title('Log-magnitude of the Spectrum of the noisy signal');
xlabel('Frequency (Hz)');
