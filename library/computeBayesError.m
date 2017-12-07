function [Error, H, range] = computeBayesError(Features, featureInd)

nClasses = length(Features);

% A.  Compute histograms:
% A1. Get feature range
featuresAll = [];

for i=1:nClasses
    featuresAll = [featuresAll; Features{i}(featureInd, :)'];
end

nBins = 20;

featuresAll = sort(featuresAll);

MIN = min(featuresAll);
MAX = max(featuresAll);

range = MIN : (MAX-MIN) / (nBins-1): MAX;

% A2. Get Hists:
for i=1:nClasses
    [H{i}] = hist(Features{i}(featureInd, :), range);
    H{i} = H{i} / sum(H{i});
end

% B. Compute Bayes Error:
histMatrix = zeros(nClasses, length(range));
for i=1:nClasses
    for j=1:length(range)
        histMatrix(i,j) = H{i}(j);
    end
end

for i=1:nClasses
    countError = 0;
    for j=1:length(range)
        curHistArray = histMatrix(:, j);
        [MAX, IMAX] = max(curHistArray);
        if IMAX~=i
            countError = countError + histMatrix(i,j);
        end
    end
    Error(i) = countError;
end
Error = mean(Error);