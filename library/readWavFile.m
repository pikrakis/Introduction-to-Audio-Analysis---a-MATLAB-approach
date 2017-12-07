function totalTime = readWavFile(fileName, BLOCK)

% function totalTime = readWavFile(fileName, BLOCK)
%
% This function demonstrates how to read the contents of a WAV file, using two
% different modes:
% - Mode 1: all the contents of the WAV file are loaded in memory using the
% standard wavread() function
% - Mode 2: BLOCKS of data are read and each BLOCK can be processed
% separatelly
%
% ARGUMENTS:
% - fileName: the name of the WAV file
% - BLOCK: (if provided) the length of the processing block (in seconds).
% If this argument is NOT provided, then the 1st mode is used
% RETURNS:
% - totalTime: the time (in secs) of the reading procedure (for
% experimental purposes)
%

if (nargin==1) % simple wavread:
    C1 = clock;
    [x,fs] = wavread(fileName);
    % DO SOME PROCESS ON x 
    % ...
    % ...
    C2 = clock;
    totalTime = etime(C2, C1);
else 
    if (nargin==2)
        % block-wise wavread:
        C1 = clock;
        [a, fs] = wavread(fileName, 'size');
        numOfSamples = a(1);
        nChannels = a(2);
        BLOCK_SIZE = round(BLOCK * fs);
        curSample = 1;

        % while the end of file has not been reahed
        while (curSample <= numOfSamples) 
            N1 = curSample;
            N2 = curSample + BLOCK_SIZE - 1;
            if (N2>numOfSamples)
                N2 = numOfSamples;
            end
            % read current block from the WAV file:
            tempX = wavread(fileName, [N1, N2]);        
            % DO SOME PROCESS ON THE CURREN BLOCK 
            % ...
            % ...
            
            % update counter:
            curSample = curSample + BLOCK_SIZE;
        end
        C2 = clock;
        totalTime = etime(C2, C1);
    end
end

