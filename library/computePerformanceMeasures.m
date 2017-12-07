function [CM, Ac, Pr, Re, F1] = ...
    computePerformanceMeasures(labels, realLabels, normalizationMode)

%
% function [CM, Ac, Pr, Re, F1] = ...
%   computePerformanceMeasures(labels, realLabels, normalizationMode)
%
% This function computes the confusion matrix and performance measures
% of a classification process.
% 
% ARGUMENTS:
% - labels:             resulting labels
% - realLabels:         real labels (ground truth)
% - normalizationMode:  1-->standard normalization
%                       2-->row-wise normalization
%                       0ther-->no normalization
%
% RETURNS:
% - CM:                 confusion matrix
% - Ac:                 overall accuracy
% - Pr:                 vector of precision for all classes
% - Re:                 vector of recall for all classes
% - F1:                 vector of F1 measures for all classes
%
% (c) 2014 T. Giannakopoulos, A. Pikrakis

if length(labels)==length(realLabels)
    nSamples = length(labels);
else
    error('True and result labels must be of the same length');
    CM = [];
    Ac = [];
    Pr = [];
    Re = [];
    F1 = [];
end

% number of classes:
nClasses = max(realLabels);

% confusion matrix initilization:
CM = zeros(nClasses, nClasses);

% compute original confusion matrix:
for i=1:nSamples
    CM(realLabels(i), labels(i)) = CM(realLabels(i), labels(i)) + 1;
end

% confusion matrix normalization:
switch normalizationMode
    case 1 % standard normalization:
        CM = CM / sum(sum(CM));
    case 2 % row-wise normalization:
        for i=1:nClasses
            CM(i, :) = CM(i,:) / sum(CM(i,:));
        end
    otherwise
        % no normalization
end

% compute overal accuracy:
Ac = sum(diag(CM)) / sum(sum(CM));

% compute class precision:
for i=1:nClasses
    Pr(i) = CM(i,i) / sum(CM(:, i));
end

% compute class recall:
for i=1:nClasses
    Re(i) = CM(i,i) / sum(CM(i, :));
end

% compute F1:
F1 = 2.*Re.*Pr ./ (Re + Pr);
