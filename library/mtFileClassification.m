function [labels, Ps, Conf, centers, classNames] = ...
    mtFileClassification(wavFileName, kNN, modelFileName)

%
% function [labels, Ps, Conf, centers, classNames] = ...
%       mtFileClassification(wavFileName, kNN, modelFileName)
%
% Splits an audio signal into fix-sized segments and 
% classifies each segment separately (fixed-size window segmentation)
%
% ARGUMENTS:
% - wavFileName:    path of the audio stream
% - kNN:            k parameter of the kNN algorithm
% - modelFileName:  path of the model
%
% RETURNS:
% - labels:         vector that contains the mid-term class labels
% - Ps:             each row i of that matrix contains the 
%                   class probabilities for the i-th mid-term segment
% - Conf:           vector that contains the confidences ...
%                   of each mid-term segment
% - centers:        vector that contains the (time, in seconds)
%                   centers of the mid-term segments
% - classNames:     the names of the classes of the model
%


% load classification model:
[Features, classNames, MEAN, STD, Statistics, ...
    stWin, stStep, mtWin, mtStep] = ...
        kNN_model_load(modelFileName);

% mid-term feature extraction:
[mtFeatures, centers] = featureExtractionFile(...
    wavFileName,  stWin, stStep, mtWin, mtStep, Statistics);

% mid-term classification
numOfClasses = length(Features);
numOfMidTermWindows = size(mtFeatures,2);
labels = zeros(numOfMidTermWindows, 1);
Ps = zeros(numOfMidTermWindows, numOfClasses);

for i=1:numOfMidTermWindows
    [Ps(i,:), labels(i)] = classifyKNN_D_Multi(...
        Features, (mtFeatures(:,i) - MEAN') ./ STD', kNN, 1);
end

Conf = zeros(numOfMidTermWindows, 1);
for (i=1:numOfMidTermWindows)
    psTemp = Ps(i,:);
    psTemp(labels(i)) = -1;
    maxOthers = max(psTemp);
    Conf(i) = Ps(i, labels(i)) - maxOthers;
end
