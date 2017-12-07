function F = showHistogramFeatures2D(matFile, featureIndex, featureName, ClassIndexes, statisticsToUse)

% Example:
% showHistogramFeatures2D('model8', 4, 'Spectral Centroid', [3:5],[1 4])
%

load(matFile);
if length(statisticsToUse)~=2
    return;
end

numOfStatistics = length(Statistics);
numOfClasses = length(ClassNames);
numOfFeatures = size(Features{1}, 1) / numOfStatistics;

Colors = [0 0 0;...
          0 0 1;...
          0 1 0;...
          1 0 0;...
          0 1 1;...
          1 0 1;...
          1 1 0;...
          0.5 0.5 0.5;...
          0.5 0 1];
size(Features)
for i=1:length(ClassIndexes)        
    F{i} = Features{ClassIndexes(i)}(featureIndex + (statisticsToUse-1)*numOfFeatures, :);
end

hold on;
for i=1:length(F)
    for j=1:size(F{i},2)
        P = plot(F{i}(1,j), F{i}(2,j), '*');
        set(P, 'Color', Colors(i, :));
    end
end
