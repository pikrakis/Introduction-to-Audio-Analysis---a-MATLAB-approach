function x = dctDecompress(DCTcoeffs, INDcoeffs, win, fs)

% function x = dctDecompress(DCTcoeffs, INDcoeffs, win, fs)
%
% This function demonstrates how to de-compress an audio signal from
% its DCT compressed coefficients
% 
% ARGUMENTS
%  - DCTcoeffs          a numOfSamples x numOfFinalDCTCoefficients
%                       matrix: each row corresponds to the kept dct
%                       coefficients
%  - INDcoeffs          indexes of the kept DCT coefficients
%  - win:               window analysis size (in seconds)
%  - fs:                sampling freq (in Hz)
%
% RETURNS:
%  - x:                 reconstructed signal samples
%

numOfFrames = size(DCTcoeffs, 1);
windowLength = round(win * fs);
x = [];

for i=1:numOfFrames % for each frame
    curDCT = zeros(1, windowLength);
    curDCT(INDcoeffs(i,:)) = DCTcoeffs(i, :);
    x = [x;dct(curDCT)'];
end
