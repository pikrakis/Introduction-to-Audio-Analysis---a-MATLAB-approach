function [label, P, classNames] = ...
    fileClassification(wavFileName, kNN, modelFileName)

%
% function [label, P, classNames] = ...
%       fileClassification(wavFileName, kNN, modelFileName)
%
% This function demonstrates the classification of an audio segment,
% stored in a wav file.
%
% ARGUMENTS:
% - wavFileName:    the path of the wav file to be classified
% - kNN:            the k parameter of the kNN algorithm
% - modelFileName:  the path of the kNN classification model
%
% RETURNS:
% - label:          the label of the winner class
% - P:              a vector that contains all estimated probabilities
%                   for each audio class contained in the model
% - classNames:     a cell array that contains the names of the 
%                   audio classes of the classification model
%
% NOTE: This function classifies the WHOLE audio file, i.e., we
%       assume that the file contains a homogeneous audio segment.
%       For mid-term classification, please use mtFileClassification().
% 

% load classification model:
[Features, classNames, MEAN, STD, Statistics, ...
    stWin, stStep, mtWin, mtStep] = kNN_model_load(modelFileName);

[x, fs] = wavread(wavFileName);         % read wav file
% short-term feature extraction:
stF = stFeatureExtraction(x, fs, stWin, stStep);      
mtWinRatio = mtWin / stWin; mtStepRatio =  mtStep / stStep;
% mid-term feature statistic calculation:
[mtFeatures] = mtFeatureExtraction(...
    stF, mtWinRatio, mtStepRatio, Statistics);
% long term averaging of the mid-term statistics:
mtFeatures = mean(mtFeatures,2);
% kNN classification
[P, label] = classifyKNN_D_Multi(Features, ...
    (mtFeatures - MEAN') ./ STD', kNN, 1);