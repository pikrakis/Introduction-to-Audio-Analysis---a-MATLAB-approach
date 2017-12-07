function Entropy = feature_energy_entropy(window, numOfShortBlocks)

% function Entropy = feature_energy_entropy(window, numOfShortBlocks)
%
% This function computes the energy entropy of the given frame
%
% ARGUMENTS:
% - window: 	an array that contains the audio samples of the input frame
% - numOfShortBlocks:     number of sub-frames
%                         (used in the entropy computation)
%
% RETURNS:
% - Entropy:    the energy entropy value
%
% (c) 2014 T. Giannakopoulos, A. Pikrakis

% total frame energy:
Eol = sum(window.^2);
winLength = length(window);
subWinLength = floor(winLength / numOfShortBlocks);

if length(window)~=subWinLength* numOfShortBlocks
    window = window(1:subWinLength* numOfShortBlocks);
end
% get sub-windows:
subWindows = reshape(window, subWinLength, numOfShortBlocks);

% compute normalized sub-frame energies:
s = sum(subWindows.^2) / (Eol+eps);

% compute entropy of the normalized sub-frame energies:
Entropy = -sum(s.*log2(s+eps));
