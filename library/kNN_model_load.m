function [Features, ClassNames, MEAN, STD, Statistics, ...
    stWin, stStep, mtWin, mtStep] = ...
    kNN_model_load(matFileName)

% This function loads a kNN audio segment classification model
%
% ARGUMENT:
% - matFileName:    the path of the model 
%
% RETURNS:
% - Features:       a cell array that contains the audio features.
%                   e.g. Features{1} contains the features of the 1st class
% - MEAN:           the mean feature vector (to be used for normalization)
% - STD:            the std feature vector
% - stWin, stStep:  short-term window size and step
% - mtWin, mtStep:  mid-term window size and step
%

load(matFileName);
[MEAN, STD] = computeMeanStd(Features);
Features = normalize(Features, MEAN', STD');


function Features = normalize(Features, MEAN, STD)

for (i=1:length(Features))
    for (j=1:size(Features{i}, 2))        
        Features{i}(:,j) = (Features{i}(:,j) -  MEAN) ./ STD;
    end
end


function [MEAN, STD] = computeMeanStd(Features)

Fall = [];
for (i=1:length(Features)) % for each class dataset:
    Fall = [Fall Features{i}];
end

MEAN = mean(Fall');
STD = std(Fall');