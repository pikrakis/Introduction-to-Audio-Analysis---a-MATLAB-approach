function plotFeaturesFile(wavFileName, featureToPlot)

%
% function plotFeaturesFile(wavFileName, featureToPlot)
%
% This function is used to plot feature sequences and 
% respective mid-term statistics
% 
% Example:
% plotFeaturesFile('diarizationExample.wav',6)

% feature extraction parameters (windows and statistics):
shortTermSize = 0.050; shortTermStep = 0.025;
midTermSize = 2.0; midTermStep = 1.0;
Statistics = {'mean','median','std','stdbymean','max','min'};
% feature extraction (mid-term and short-term):
[midFeatures, Centers, stFeaturesPerSegment] = featureExtractionFile(...
    wavFileName, shortTermSize, shortTermStep, midTermSize, midTermStep, Statistics);
numOfShortFeatures = size(stFeaturesPerSegment{1}, 1); 
% Plot results:
figure; hold on; Colors = {'r', 'g', 'k', 'm', 'y','c'};
% Plot mid-term feature statistics:
for s=1:length(Statistics) % for each statistic:
    P = plot(Centers, ...
        midFeatures(featureToPlot + numOfShortFeatures * (s-1), :), Colors{s});
    set(P, 'linewidth', 2);
end
% Plot short-term feature sequence:
for i=1:length(stFeaturesPerSegment) % for each mid-term window:
    % get current short-term feature sequence to be plotted:
    curSFeature = stFeaturesPerSegment{i}(featureToPlot, :);    
    % create time array:
    stTime = (i-1) * midTermStep : shortTermStep : ...
        (i-1) * midTermStep + (length(curSFeature)-1)*shortTermStep;
    % plot the respective short-term feature sequence:        
    plot(stTime, curSFeature);
end
legend([Statistics, 'short-term sequence']);
xlabel('Time (seconds)'); ylabel('Feature Values');
title(['Feature ' num2str(featureToPlot)]);
