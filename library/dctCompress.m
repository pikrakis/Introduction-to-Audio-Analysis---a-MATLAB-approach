function [DCTcoeffs, INDcoeffs] = dctCompress(signal, win, fs, cR)

% function [DCTcoeffs, INDcoeffs] = dctCompress(signal, win, fs, compressRatio)
%
% This function demonstrates audio compression using DCT%
%
% ARGUMENTS:
%  - signal:            vector that contains the signal samples
%  - win:               window analysis size (in seconds)
%  - fs:                sampling freq (in Hz)
%  - CR:                required DCT compression ratio
%
% RETURNS:
%  - DCTcoeffs          a numOfSamples x numOfFinalDCTCoefficients
%                       matrix: each row corresponds to the kept dct
%                       coefficients
%  - INDcoeffs          indexes of the kept DCT coefficients
%

if (size(signal,2)>1) signal = (sum(signal,2)/2); end
windowLength = round(win * fs); curPos = 1; L = length(signal);
dctToKeep = round((cR/2) * windowLength);
% note that compression ratio is the half of the desired ratio since
% the compression process returns TWO matrices (dct coefficients and
% indeces)
numOfFrames = floor((L-windowLength)/windowLength) + 1;

for i=1:numOfFrames % for each frame
    frame  = signal(curPos:curPos+windowLength-1);
    Dct = dct(frame);   % DCT
    [~, Isort] = sort(abs(Dct), 'descend'); % sort DCT coeffs
    Isort = Isort(1:dctToKeep);             % keep indeces
    DCTcoeffs(i, :) = Dct(Isort);
    INDcoeffs(i, :) = Isort;
    curPos = curPos + windowLength;
end
