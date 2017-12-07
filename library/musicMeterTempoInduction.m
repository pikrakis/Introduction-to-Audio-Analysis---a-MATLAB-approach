function [Tempo, meterNum, meterDenom] = musicMeterTempoInduction(x,fs,LongSize, LongStep, winSize,winStep,maxerr,verbose)

%
% [Tempo, meterNum, meterDenom] = musicMeterTempoInduction(x,fs,LongSize, LongStep, winSize,winStep,maxerr,verbose)
%
% This function performs joint estimation of the music meter and tempo of a music recording,
% assuming that tempo remains approximately constant throughout the
% recording. It is a partial implementation of the method in [Pik04] with
% minor modifications.
%
% INPUT:
%   x:                  signal (sequence of samples)
%   fs:                 sampling frequency
%   LongSize:           length of the long-term moving window (in seconds)
%   LongStep:           step of the long-term moving window (in seconds)
%   winSize:            short-term window length (in seconds)
%   winStep:            short-term window step (in seconds). Avoid very
%                       small values (< 0.005) because they increase
%                       computational burden significantly
%                       Recommended values are 0.01 s or 0.005 s
%   maxerr:             controls the sensitivity of the algorithm.
%                       recommended values are in the range [0.1,0.3].
%   verbose:            if set to 1 exctracted values are printed on the
%                       screen
%
% RETURNS:
%   Tempo:              tempo of the recording (bpm) per long-term segment
%   meterNum:           music meter numerator per long-term segment
%   meterdeNom:         music meter denominator (4 or 8) per long-term segment
%
% Example:              [Tempo, meterNum, meterDenom]=musicMeterTempoInduction(x,fs,10,10,0.01,0.01,0.25,1);
%
% Dependencies:         stFeatureExtraction
%
% Reference:            [Pik04] A. Pikrakis, I. Antonopoulos and S.
%   Theodoridis, "Music Meter and Tempo Tracking from Raw Polyphonic Audio",
%   Proceedings of the International Conference on Music Information
%   Retrieval (ISMIR), 2004, Barcelona, Spain.

% if the algorithms fails to detect music meter and tempo, empty values are
% returned
meterNum=[];
meterDenom=[];
Tempo=[];

% SHORT-TERM FEATURE EXTRACTION
Features = stFeatureExtraction(x, fs, winSize, winStep);

% GET THE MFCCs:
MFCCgram = Features(9:21,:); % MFCCs start at position 9
LongSize = round(LongSize/winStep);
LongStep = round(LongStep/winStep);


% Break the recording into long-term segments. For each long-term segment,
% compute the upper triangle of the dissimilarity matrix
% using the Euclidean distance as the dissimilarity function. Analyze each
% matrix to infer music meter and tempo.

N = size(MFCCgram, 2);
counter=1;
Z = zeros(LongSize);
while counter+LongSize-1<=N
    lfeat=MFCCgram(:,counter:counter+LongSize-1);
    for i=1:LongSize
        for j=1:LongSize
            Z(i,j) = sqrt(sum((lfeat(:,i) - lfeat(:,j)).^2));
        end
    end
    for i=1:LongSize-1
        B(i)=mean(diag(Z,i));
    end
    y=estimateDerivative(estimateDerivative(B,3),3); % estimate second derivative
    maxima=findmaxima(y);
    if ~isempty(maxima) % music meter and tempo are determined here
        % Assumptions
        maxMeterLag=round(4/winStep); % this lag corresponds to the longest music meter (4 seconds long)
        minMeterLag=round(1.3/winStep); % this lag corresponds to the shortest meter duration (1.3 seconds)
        maxTempoLag=round(60/60/winStep); % this lag corresponds to the longest beat duration (60 bpm)
        indTempo=maxima(maxima<=maxTempoLag);
        indMeter=maxima(maxima>=minMeterLag & maxima<=maxMeterLag);        
        maxsum=0;
        localTempo=0;
        localmeterNum=0;
        localmeterDenom=0;
        for k1=1:length(indTempo)
            for k2=1:length(indMeter)
                ratio=indMeter(k2)/indTempo(k1);                
                err=ratio-floor(ratio);
                if err>=maxerr % ignore pair of peaks
                    continue;
                end               
                if floor(ratio)>12 || floor(ratio)==5 || floor(ratio)==11 || floor(ratio)==10 % ignore pair of peaks
                    continue;
                end
                localsum=y(indMeter(k2))+y(indTempo(k1));
                if localsum>maxsum                                        
                    localmeterNum=floor(ratio);
                    localTempo=round(60/(indTempo(k1)*winStep));                    
                    if localTempo>180
                        localmeterDenom=8;
                    else
                        localmeterDenom=4;
                    end
                    % some basic post processing to remove common errors
                    if localmeterNum>=6 && localTempo<180
                        localTempo=0;                        
                        continue;
                    end
                    if (localmeterNum==8 || localmeterNum==6 || localmeterNum==4) && localTempo>180
                        localTempo=round(localTempo/2);                        
                        localmeterNum=localmeterNum/2;
                        localmeterDenom=localmeterDenom/2;                        
                    end
                    
                    if localTempo>=60 && localTempo<70  && localmeterNum==2 && localmeterDenom==4
                        localTempo=round(localTempo*2);
                        localmeterNum=localmeterNum*2;
                    end
                    
                    maxsum=localsum;
                end
            end
        end
    end
    if localTempo>0
        Tempo=[Tempo localTempo];
        meterNum=[meterNum localmeterNum];
        meterDenom=[meterDenom localmeterDenom];
        if verbose
            fprintf('Tempo = %d (bpm), Meter = %d / %d\n',localTempo, localmeterNum, localmeterDenom);
        end
    end
    counter=counter+LongStep;
end


function y=estimateDerivative(x,k)

% Auxiliary function: computes an estimate of the first-order derivative of
% the input sequence.

Lx=length(x);
y=zeros(1,length(x));

limi=2;
for i=limi+1:Lx-limi
    if i<=k
        w=[1./[-i+1:-1] 0 1./[1:i-1]];
        y(i)=sum(x(1:2*i-1).*w);
    elseif i>length(x)-k
        w=[1./[-(length(x)-i):-1] 0 1./[1:length(x)-i]];
        y(i)=sum(x(i-(length(x)-i):end).*w);
    else
        w=[1./[-k:-1] 0 1./[1:k]];
        y(i)=sum(x(i-k:i+k).*w);
    end
end

function maxima=findmaxima(x)

% Auxiliary function: detects the local maxima of the one-dimensional input
% sequence. Scanning for maxima starts after the first zero crossing has
% been detected (upwards). After all maxima have been detected, only those
% which are locally dominant are preserved.

y=[];
% detect first zero crossing (upwards)
k=1;
while x(k)<=length(x)
    if x(k)<0 && x(k+1)>=0
        leftlimit=k;
        break;
    end
    k=k+1;
end

% detect all local maxima
for i=leftlimit:length(x)-1
    if (x(i)>x(i-1) && x(i)>=x(i+1) && x(i)>0) || (x(i)>=x(i-1) && x(i)>x(i+1) && x(i)>0)
        y=[y i];
    end
end

% preserve all dominant local maxima.
if isempty(y)
    return;
else
    maxima=[];
    if x(y(1))>x(y(2))
        maxima=[maxima y(1)];
    end
    for k=2:length(y)-1
        if x(y(k))>x(y(k-1)) && x(y(k))>x(y(k+1))
            maxima=[maxima y(k)];
        end
    end
    if x(y(end))>x(y(end-1))
        maxima=[maxima y(end)];
    end
end
