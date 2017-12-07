function fftExample(Fs, f, duration)

% function fftExample(Fs, f, duration)
%
% Demonstrates the use of the getDFT() function. 
% Generates a sum of sinusoidal signals and computes-plots its DFT amplitude.
%
% ARGUMENTS:
% - Fs: sampling frequency
% - f:  frequencies of the tones (the signal is generated 
%       as a sum of sinusoidal signals)
% - duration: the duration of the signal (in seconds)
%
% (c) 2014 T. Giannakopoulos, A. Pikrakis

t = 0:1/Fs:duration;                % time vector                                   
x = cos(2*f(1)*pi*t);               % create the signal
for (i=2:length(f)) x = x + cos(2*f(i)*pi*t);  end
x = x / length(f);                  % signal normalization

% compute the magnitude spectrum:
[X, FreqX] = getDFT(x, Fs);          % freq range: 0->fs/2
[X2, FreqX2] = getDFT(x, Fs, 1);     % freq range: -fs/2->fs/2

% plot the results:
figure; subplot(2,1,1); plot(FreqX, X, ' k'); title('Magnitude of DFT');
xlabel('Hz'); title('Positive part of spectrum');
subplot(2,1,2); plot(FreqX2, X2, ' k'); title('Magnitude of DFT');
xlabel('Hz'); title('Spectrum in range - f_s / 2 -> f_s / 2');
