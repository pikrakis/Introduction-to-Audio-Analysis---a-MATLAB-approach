function En = feature_spectral_entropy(windowFFT, numOfShortBlocks)

% function En = feature_spectral_entropy(windowFFT, numOfShortBlocks)
% 
% This function computes the spectral entropy of the given audio frame
%
% ARGUMENTS:
% - windowFFT:       the abs(FFT) of an audio frame
%                    (computed by getDFT() function)
% - numOfShortBins   the number of bins in which the spectrum
%                    is divided
%
% RETURNS:
% - En:              the value of the spectral entropy
%

% number of DFT coefs
fftLength = length(windowFFT);

% total frame (spectral) energy 
Eol = sum(windowFFT.^2);

% length of sub-frame:
subWinLength = floor(fftLength / numOfShortBlocks);
if length(windowFFT)~=subWinLength* numOfShortBlocks
    windowFFT = windowFFT(1:subWinLength* numOfShortBlocks);
end

% define sub-frames:
subWindows = reshape(windowFFT, subWinLength, numOfShortBlocks);

% compute spectral sub-energies:
s = sum(subWindows.^2) / (Eol+eps);

% compute spectral entropy:
En = -sum(s.*log2(s+eps));
