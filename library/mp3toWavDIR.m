function mp3toWavDIR(dirName)

% function mp3toWavDIR(dirName)
%
% This function transcodes all MP3s of a given folder to WAV.
%
% ARGUMENTS:
%  - dirName:       the path of the directory that contains the MP3 files
%

D = dir([dirName filesep '*.mp3']);

for i=1:length(D)
    curNameMp3 = [dirName filesep D(i).name];
    curNameWAV = [curNameMp3(1:end-3) 'wav'];
    mp3toWav(curNameMp3, curNameWAV);
end
