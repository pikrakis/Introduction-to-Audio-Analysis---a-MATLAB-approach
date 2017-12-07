function [FeaturesDir, FileNames] =  featureExtractionDir(dirName, stWin, stStep, mtWin, mtStep, featureStatistics)

%
% function [FeaturesDir, FileNames] =  featureExtractionDir(dirName, stWin, stStep, mtWin, mtStep, featureStatistics)
%
% Extracts mid term features for a list of WAV files stored in a given path
% 
% ARGUMENTS:
%  - dirName:           path of the folder that contains the WAV files
%  - stWin, stStep:     short-term window size and step (seconds)
%  - mtWin, mtStep:     mid-term window size and step (seconds)
%  - featureStatistics: list (cell array) of mid term statistics
%
% RETURNS:
%  - FeaturesDir:       cell array whose elements are feature matrices 
%                       e.g., FeaturesDir{10} contains the mid-term 
%                       feature matrix of the 10th file in the given
%                       directory +++
%  - FileNames:         cell array that contains the full paths of the 
%                       WAV files in the provided folder
% 
% (c) 2014 T. Giannakopoulos, A. Pikrakis

D = dir([dirName filesep '*.wav']);

for i=1:length(D)       % for each WAV file
    fprintf('Feature extraction for file %50s\n', D(i).name)
    curName = [dirName filesep D(i).name];    
    FileNames{i} = curName;  % get current filename
    % extract mid-term features:
    [midFeatures, Centers, stFeaturesPerSegment] = ...
        featureExtractionFile(curName, stWin, stStep, mtWin, mtStep, featureStatistics);
    FeaturesDir{i} = midFeatures;
end
