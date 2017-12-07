function [mtFeatures, shortFeaturesCell] = ...
    mtFeatureExtraction(stFeatures, mtWin, mtStep, listOfStatistics)

%
% This function is used for extracting mid-term statistics
%
% ARGUMENTS:
%  - stFeatures:        a matrix that contains all short-term feature vectors 
%                       (dimension: dFeatures x numOfShortTermWindows)
%  - mtWin:             mid-term window (as a multiple of short-term window)
%  - mtSteP:            mid-term step (as a multiple of short-term step)
%  - listOfStatistics:  a cell array that contains the names of the 
%                       statistics to be calculated
%
% RETURNS:
%  - mtFeatures:        an matrix whose collumns contains the mid-term
%                       feature statistics for each mid-term segment
%  - stFeaturesCell:    a cell array, whose, each element i is 
%                       a matrix that contains the feature vector sequences
%                       of the corresponding mid-term segment. 
%

[numOfFeatures, numOfStWins] = size(stFeatures);

curPos = 1;
% compute the total number of mid-term frames:
numOfMidFrames = ceil((numOfStWins)/mtStep);


mtFeatures = zeros(numOfFeatures * length(listOfStatistics), numOfMidFrames);
if (nargout==2)
    shortFeaturesCell = cell(1, numOfMidFrames);
end

for (i=1:numOfMidFrames) % for each mid-term frame
    % get current frame:
    N1 = curPos;
    N2 = curPos+mtWin-1;
    if (N2>size(stFeatures,2))
        N2 = size(stFeatures,2);
    end
    
    CurStFeatures  = stFeatures(:, N1:N2);
    if (nargout==2)
        shortFeaturesCell{i} = CurStFeatures;
    end
    for (j=1:length(listOfStatistics))
        mtFeatures( (j-1)*numOfFeatures + 1: j*numOfFeatures, i) = ...
            computeStatistic(CurStFeatures', listOfStatistics{j});
    end
    curPos = curPos + mtStep;
end

    
function S = computeStatistic(seq, statistic)
    if strcmpi(statistic, 'mean')
        S = mean(seq); return;
    end
    if strcmpi(statistic, 'median')
        S = median(seq); return;
    end
    if strcmpi(statistic, 'std')
        S = std(seq); return;
    end
    if strcmpi(statistic, 'stdbymean')
        S = std(seq) ./ (mean(seq)+eps); return;
    end
    if strcmpi(statistic, 'max')
        S = max(seq); return;
    end
    if strcmpi(statistic, 'min')
        S = min(seq); return;
    end    
    if strcmpi(statistic, 'meanNonZero')
        for i=1:size(seq, 2)
            curSeq = seq(:, i);
            S(i) = mean(curSeq(curSeq>0));
        end
        return;
    end
    if strcmpi(statistic, 'medianNonZero')
        for i=1:size(seq, 2)
            curSeq = seq(:, i);
            S(i) = median(curSeq(curSeq>0));
        end
        return;
    end
