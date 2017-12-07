function mp3toWav(mp3Path, wavPath)

% function mp3toWav(mp3Path, wavPath)
% 
% This function converts an mp3 file to WAV, by using the FFMPEG
% command-line.
%
% ARGUMENTS:
%  - mp3Path:   path of the (input) MP3 file
%  - wavPath:   path of the WAV file (output)
%
% NOTE: FFMPEG needs to be installed. For Windows, ffmpeg.exe needs to be
% placed in the current directory.
%

if exist(mp3Path, 'file') ~= 2    
    error('No such file found!\n');    
end

if isunix | ismac
    commandToExecute = ['ffmpeg -i "' mp3Path '" -ac 1 -ar 16000 "' wavPath '"'];
else
    commandToExecute = ['ffmpeg.exe -i "' mp3Path '" -ac 1 -ar 16000 "' wavPath '"'];
end
commandToExecute
system(commandToExecute)
