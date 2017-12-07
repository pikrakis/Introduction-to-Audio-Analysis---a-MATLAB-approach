function F = feature_spectral_flux(windowFFT, windowFFTPrev)

% function F = feature_spectral_flux(windowFFT, windowFFTPrev)
%
% Computes the spectral flux feature
% ARGUMENTS:
% - windowFFT:             the abs(FFT) of the current audio frame
%                          (computed by getDFT() function)
% - windowFFTPrev:         the abs(FFT) of the previous frame
%
% RETURNS:
% - F:                     the spectral flux value for the input frame
%

% normalize the two spectra:
windowFFT = windowFFT / sum(windowFFT);
windowFFTPrev = windowFFTPrev / sum(windowFFTPrev+eps);

% compute the spectral flux as the sum of square distances:
F = sum((windowFFT - windowFFTPrev).^2);
