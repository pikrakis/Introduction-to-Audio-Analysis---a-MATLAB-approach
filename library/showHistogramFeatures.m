function showHistogramFeatures(matFile, featureIndex, featureName, ClassIndexes)


% function showHistogramFeatures(matFile, featureIndex, featureName, ClassIndexes)
%
% This function loads a particular feature from a feature set
% stored in a .mat file and plots the histograms for each feature statistic
% and each class
%
% ARGUMENTS:
%  - matFile:       path of the mat file where the features are stored
%  - featureIndex:  index of the feature to be plotted
%  - featureName:   name (string) of the feature to be ploted
%  - ClassIndexes:  indeces of the classes to be used in the histograms
%
% Example:
% showHistogramFeatures('model8', 4, 'Spectral Centroid', [3:5])

load(matFile);
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

for i=1:numOfStatistics
    figure(i);
    strTitle = [featureName ' - ' Statistics{i}];
    title(strTitle);

    hold on;

    if length(ClassIndexes)==1 % one vs all binary task:
        F{1} = Features{ClassIndexes};
        F{2} = [];
        for j=1:numOfClasses
            if j~=ClassIndexes
                F{2} = [F{2} Features{j}];
            end
        end
        [Error, H, range] = computeBayesError(F, featureIndex + (i-1)*numOfFeatures);
    else
        [Error, H, range] = computeBayesError(Features(ClassIndexes), featureIndex + (i-1)*numOfFeatures);
    end
    
    for j=1:length(H);
        P = plot(range, H{j});
        set(P, 'Color', Colors(j,:));
    end
    
    if length(ClassIndexes)==1 % one vs all binary task:
        legend({ClassNames{ClassIndexes}, ['non-' ClassNames{ClassIndexes}]});
    else
        legend(ClassNames(ClassIndexes));
    end
    Error
end