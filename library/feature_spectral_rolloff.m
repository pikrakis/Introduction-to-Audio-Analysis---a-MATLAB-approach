function mC = feature_spectral_rolloff(windowFFT, c)

% function mC = feature_spectral_rolloff(windowFFT, c)
% 
% Computes the spectral rolloff feature. 
% ARGUMENTS:
% - windowFFT:             the abs(FFT) of the current audio frame
%                          (computed by getDFT() function)
% - c:                     the spectral rolloff parameter
%
% RETURNS:
% - mC:                    the spectral rolloff value for the input frame
%


% compute total spectral energy:
totalEnergy = sum(windowFFT.^2);
curEnergy = 0.0;
countFFT = 1;
fftLength = length(windowFFT);

% find the spectral rolloff as the frequency position where the 
% respective spectral energy is equal to c*totalEnergy
while ((curEnergy<=c*totalEnergy) && (countFFT<=fftLength))
    curEnergy = curEnergy + windowFFT(countFFT).^2;
    countFFT = countFFT + 1;
end
countFFT = countFFT - 1;

% normalization:
mC = ((countFFT-1))/(fftLength);
