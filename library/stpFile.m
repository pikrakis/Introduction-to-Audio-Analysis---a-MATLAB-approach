function stpFile(wavFile, windowLength, step)
%
% stpFile.m
%
% This function demonstrates the short-term processing of an audio signal
%
% ARGUMENTS:
% - wavFile: the name of the WAV file to be processed
% - windowLength: the length of the window (in seconds)
% - step: the window step (in seconds)
%
% (c) 2014 T. Giannakopoulos, A. Pikrakis

[x,fs] = wavread(wavFile);                      % read the WAV file

% convert window and step from seconds to samples:
windowLength = round(windowLength * fs); step = round(step * fs);
curPos = 1; L = length(x);
% compute the total number of frames:
numOfFrames = floor((L-windowLength)/step) + 1;
figure;
for (i=1:numOfFrames) % for each frame    
    frame  = x(curPos:curPos+windowLength-1);   % get current frame:    
    % multiply the frame with the hamming window:
    frameW = frame .* window(@hamming, length(frame));
    subplot(2,1,1); plot(frame); title('Current frame (original)');
    axis([0 length(frameW) -1 1])

    % plot windowed frame:
    subplot(2,1,2); plot(frameW); title('Current frame (windowed)');
    axis([0 length(frameW) -1 1]); drawnow;  pause(0.1);
    % DO SOMETHIN WITH 'frameW' HERE:
    % ...
    % ...
    curPos = curPos + step;
end
