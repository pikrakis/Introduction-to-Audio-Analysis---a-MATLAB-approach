function [segs, classes] = speakerDiarization(fileName, nSpeakers)

%
% function [segs, classes] = speakerDiarization(fileName, nSpeakers)
%
% This function implements a simple speaker diarization procedure.
% 
% ARGUMENTS:
%  - fileName:      the path of the WAV file to be analyzed
%  - nSpeakers:     the number of speakers (prior knowledge provided by
%                   the user)
%
% RETURNS:
%  - segs:          segment limits [numOfSegment x 2] (in seconds)
%  - classes:       class labels for each detected segment (numOfSegments)
% 
% EXAMPLE:
% [segs, classes] = speakerDiarization('../data/diarizationExample', 4);
%
% (c) 2014 T. Giannakopoulos, A. Pikrakis

[a, fs] = wavread(fileName, 'size');
totalDuration = a(1) / fs;    % get the input file's duration in seconds

% STEP A: feature extraction
[mtFeatures, centers] = featureExtractionFile(fileName,  ...
    0.040, 0.040, 2.0, 1.0, {'mean','std'});
mtFeatures = mtFeatures';

% STEP B: feature normalization:
MEAN = mean(mtFeatures);
STD = std(mtFeatures);
mtFeatures = (mtFeatures - repmat(MEAN, [size(mtFeatures,1) 1])) ...
    ./ repmat(STD, [size(mtFeatures,1) 1]  );

% STEP C: Clustering of audio segments
[IDXs, Centr, SUMD, D] = kmeans(mtFeatures, nSpeakers, ...
    'MaxIter', 500, 'Replicates', 10);

% STEP D: Distance to probability estimation:
Ps = 1 ./ D;
% smoothing
for i=1:size(Ps, 2)
    Ps(:,i) = filter([1/3 1/3 1/3], 1, Ps(:,i));
end
Ps = Ps./repmat(sum(Ps,2), [1 size(Ps, 2)]);

% STEP E: Probability to segment extraction (single-merging segmentation)
[segs, classes, Labels] = segmentationProbSeq(...
    Ps, centers, totalDuration, 0); 

