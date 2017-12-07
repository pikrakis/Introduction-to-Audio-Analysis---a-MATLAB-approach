function [segs] = segmentationSignalChange(fileName, PLOT)

%
% function [segs] = segmentationSignalChange(fileName, PLOT)
% 
% Detects changes in audio signal (no classification needed)
% 
% ARGUMENTS:
%  - fileName:      path of the input WAV file
%  - PLOT:          1 if results are to be plotted
%
% RETURNS:
%  - segs:          matrix that contains the extracted segment limits
%
% (c) 2014 T. Giannakopoulos, A. Pikrakis

% mid-term feature extraction:
mtWin = 2.0; mtStep = 1.0; stWin = 0.040; stStep = 0.040; 
featureStatistics = {'mean', 'std'};
[midFeatures, Centers, stFeaturesPerSegment] = ...
    featureExtractionFile(fileName, stWin, stStep, mtWin, mtStep, ...
    featureStatistics);

% get total signal duration:
[a, fs] = wavread(fileName, 'size'); duration = a(1) / fs;

% normalization:
midFeatures = midFeatures';
MEAN = mean(midFeatures); STD = std(midFeatures);
midFeatures = (midFeatures - repmat(MEAN, [size(midFeatures,1) 1])) ...
    ./ repmat(STD, [size(midFeatures,1) 1]  );
[numOfWindows, ~] = size(midFeatures);

% distance calculation
Dist = zeros(numOfWindows, 1);
for i=2:numOfWindows-1
    Dist(i) = (pdist2(midFeatures(i, :), midFeatures(i-1, :)));
end
Dist(1) = Dist(2); Dist = Dist ./ max(Dist);    % distance normalization

% local maxima detection:
[maxDist, iMaxDist] = findpeaks(Dist);

% thresholding:
distMEAN = mean(Dist);
itemp = find(maxDist<1.0*distMEAN); maxDist(itemp) = []; 
iMaxDist(itemp) = []; Time = 0:mtStep:(numOfWindows-1) / mtStep;

if nargin==2
    plot(Time, Dist); hold on;
    for i=1:length(iMaxDist) plot(Time(iMaxDist(i)), maxDist(i), '*'); end
    xlabel('time (sec)');
    ylabel('Distance function');
end

% generate segment limits:
segs = zeros(length(iMaxDist) + 1, 2); 
for i=1:length(iMaxDist)
    segs(i,2) = Time(iMaxDist(i));
    segs(i+1,1) = Time(iMaxDist(i));
end
segs(end, 2) = duration;
