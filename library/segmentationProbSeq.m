function [segs, classes, Labels] = segmentationProbSeq(Probabilities, Centers, totalDuration, method)

%
% function [segs, classes, Labels] = segmentationProbSeq(Probabilities, ...
%           Centers, totalDuration, method)
%
% This function segments an audio stream based on estimated probability
% sequences for each class.
%
% ARGUMENTS:
% - Probabilities:      a [numOfWindows x numOfClasses] matrix, each 
%                       element (i,j) of which, contains the probability
%                       that window i belongs to class j
% - Centers:            an [numOfWindows x 1 ] array that contains the TIME
%                       centers of the respective windows
% - totalDuration:      the total duration of the segmented signal (in seconds)
% - method:             0 for simple merging, 1 for viterbi-based smoothing
% 
% RETURNS:
% - segs:               segment limits [numOfSegment x 2] (in seconds)
% - classes:            class labels (0 for silence, 1 for speech) for each
%                       detected segment (numOfSegments)
% - Labels:             Labels array ([numOfWindows x 1]) for each mid-term window
%
% (c) 2014 T. Giannakopoulos, A. Pikrakis


[numOfWindows, numOfClasses] = size(Probabilities);
if (numOfWindows~=length(Centers))
    error 'Number of probabilities must be equal to the number of corresponding centers';
end

switch method
    case 0      % Simple thresholding (no smoothing done):                
        [MAXPs, Labels] = max(Probabilities, [], 2);        
        [segs, classes] = labels2segments(Labels, Centers, totalDuration);                       
    case 1        % Viterbi - smoothing:                
        % estimate the priors and initial transition matrix:
        [MAXPs, HardLabels] = max(Probabilities, [], 2);    % get the hard labels 
        
        for i=1:numOfClasses   % priors estimation:
            priors(i) = length(find(HardLabels==i)) / numOfWindows;
        end
        
        transMatrix = zeros(numOfClasses);
        for i=2:numOfWindows            
            transMatrix(HardLabels(i-1), HardLabels(i)) = ...
                transMatrix(HardLabels(i-1), HardLabels(i)) + 1;
        end        
        transMatrix = transMatrix / sum(sum(transMatrix));
        
        % run the viterbi smoothing:
        Labels = viterbiBestPath(priors, transMatrix, Probabilities');
        
        % segment the (smoothed) labels:
        [segs, classes] = labels2segments(Labels, Centers, totalDuration);
        
    otherwise
        error 'Wrong method ID!'
end

function [segs, classes] = labels2segments(Labels, Centers, totalDuration)
% function to convert labels to segments (merging)
numOfWindows = length(Labels);
segs = []; classes = [];
curIndex = 1; 
segs(curIndex, 1) = 0;
curLabel = Labels(curIndex);                

while curIndex < numOfWindows-1
    prevLabel = curLabel; % keep previous label
    curIndex = curIndex + 1;
    curLabel = Labels(curIndex);
    if curLabel == prevLabel
        continue
    end
    classes(end+1) = Labels(curIndex-1);
    segs(end, 2) = mean([Centers(curIndex); Centers(curIndex-1)]);
    segs(end+1, 1) = mean([Centers(curIndex); Centers(curIndex-1)]);            
end
classes(end+1) = Labels(curIndex);
segs(end, 2) = totalDuration;
classes = classes - 1;
