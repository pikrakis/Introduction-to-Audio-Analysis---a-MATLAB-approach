function [C,S] = feature_spectral_centroid(window_FFT, fs)

% function C = feature_spectral_centroid(window_FFT, fs)
%
% Computes the spectral centroid and spread of a frame
%
% ARGUMENTS:
% - window_FFT: the abs(FFT) of an audio frame
%               (computed by getDFT() function)
% - fs:         the sampling freq of the input signal (in Hz)
% 
% RETURNS:
% - C:          the value of the spectral centroid
%               (normalized in the 0..1 range)
% - S:          the value of the spectral spread 
%               (normalized in the 0..1 range)
%

% number of DFT coefs
windowLength = length(window_FFT);
% sample range
m = ((fs/(2*windowLength))*[1:windowLength])';
% normalize the DFT coefs by the max value:
window_FFT = window_FFT / max(window_FFT);
% compute the spectral centroid:
C = sum(m.*window_FFT)/ (sum(window_FFT)+eps);
% compute the spectral spread
S = sqrt(sum(((m-C).^2).*window_FFT)/ (sum(window_FFT)+eps));

% normalize by fs/2 
% (so that 1 correponds to the maximum signal frequency, i.e. fs/2):
C = C / (fs/2);
S = S / (fs/2);

