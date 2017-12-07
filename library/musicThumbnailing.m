function t = musicThumbnailing(x,fs,winSize,winStep,thumbnailLength,numofPairs,todraw,stpoints,toler)

%
% t = musicThumbnailing(x,fs,winSize,winStep,thumbnailLength,numsegments,todraw)
%
% This function extracts pairs of thumbnails from music recordings. It is a
% variant of the algorithm in [Bar01].
%
% INPUT:
%   x:                  signal (sequence of samples)
%   fs:                 sampling frequency
%   winSize:            moving window length (in seconds)
%   winStep:            moving window step (in seconds). Avoid small values
%                       because they increase computational burden significantly.
%                       Recommended value is 0.25 s
%   thumbnailLength:    approximate desired thumbnail length (in seconds)
%   numofPairs:         number of pairs of thumbnails (maximum value is 3)
%   to draw:            if set to 1, the self similarity matrix of the
%                       recording and the result of the application
%                       of the moving average filter are drawn on the screen.
%
% RETURNS:
%   t:                  four-column matrix. Each row, (t1,t2,t3,t4),
%                       represents a pair of thumbnails.
%                       t1 and t2 (t3 and t4) are the start and end
%                       times (in seconds) of the first (second)
%                       thumbnail of the pair.
%
% Example:              t=MusicThumbnailing(x, fs, 0.25, 0.25, 20, 1, 1);
%
% Dependencies:         stFeatureExtraction, nlfilter (MATLAB)
%
% Reference:            [Bar01] M. Bartch and G. Wakefield, "TO CATCH A CHORUS:
%                       USING CHROMA-BASED REPRESENTATIONS FOR AUDIO
%                       THUMBNAILING", IEEE Workshop on Applications of
%                       Signal Processing to Audio and Acoustics, 2001.

% SHORT-TERM FEATURE EXTRACTION
Features = stFeatureExtraction(x, fs, winSize, winStep);

%Chromagram=load('1.8.wav_PSF.csv')';
%Chromagram(:,1)=[];

% GET THE CHROMAGRAM:
Chromagram = Features(23+1:23+12, :); % feature starts at row 23+1

M = round(thumbnailLength/winStep);   % convert thumbnail length to an odd number of frames
if rem(M,2)==0
    M = M+1;
end

stpoints=round(stpoints/winStep);%+(M-1)/2;
toler=round(toler/winStep);

% Compute the upper triangle of the self similarity matrix
% using correlation as the similarity function. Ignore all diagonals whose
% index is less than M.
N = size(Chromagram, 2);
Z = zeros(N);
for i=1:N
    for j=i+M+1:N
        Z(i,j) = sum(Chromagram(:,i) .* Chromagram(:,j));
    end
end

% Display similarity matrix (optional)
if nargin>6
    if todraw==1
        figure(1);
        imagesc(Z);
        Xticks = get(gca,'XTickLabel'); Yticks = get(gca,'XTickLabel');
        set(gca,'XTickLabel', {str2num(Xticks) * winStep})
        set(gca,'YTickLabel', {str2num(Yticks) * winStep})
    end
end

% if numofPairs>3
%     numofPairs = 3;
%     fprintf('Number of pairs of thumbnails was set to 3\n');
% end

%matr = eye(M);
matr = eye(M)+diag(1/2*ones(1,M-1),1)+diag(+1/2*ones(1,M-1),-1); % filter mask
%vec=[1./((M-1)/2:-1:1) 0 1./(1:1:(M-1)/2)];
%matr = diag(vec); % filter mask

% Apply moving average filter
tic
B = nlfilter(Z, [M M], @aux,matr);
toc

% Display the result of applying the moving average filter(optional)
if nargin>6
    if todraw==1
        figure(2);
        imagesc(B);
    end
end

% Detect pairs of thumbnails iteratively. After a pair is detected, the
% corresponding region of matrix B is set to zero. This is done to avoid
% selecting the same pair again.
t = zeros(numofPairs, 4);
k=0;
while k<numofPairs
    maxvalue = max(max(B));
    [xc, yc] = find(B==maxvalue);
    xc=xc(1); yc=yc(1);
    if ~isempty(find(abs(xc-(M-1)/2-stpoints)<=toler)) && ~isempty(find(abs(yc-(M-1)/2-stpoints)<=toler))
        k=k+1;
        t(k,1) = xc-(M-1)/2;
        t(k,2) = xc+(M-1)/2;
        t(k,3) = yc-(M-1)/2;
        t(k,4) = yc+(M-1)/2;
        B(t(k,1):t(k,2),t(k,3):t(k,4)) = 0;
    else
        B(xc-(M-1)/2:xc+(M-1)/2,yc-(M-1)/2:yc+(M-1)/2) = 0;
    end        
end

% Superimpose segments on the image of matrix B (optional)
if nargin>6
    if todraw==1
        figure(2);
        hold;
        for k=1:size(t,1)
            plot([t(k,3) t(k,4)], [t(k,1) t(k,2)], 'LineWidth', 4, 'Color', [0 0 1], 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdgeColor', [0 0 1], 'MarkerFaceColor', [0 0 1]);
        end
        Xticks = get(gca,'XTickLabel'); Yticks = get(gca,'XTickLabel');
        set(gca,'XTickLabel', {str2num(Xticks) * winStep})
        set(gca,'YTickLabel', {str2num(Yticks) * winStep})
    end
end

% Convert to seconds
t(:,[1 3]) = (t(:,[1 3])-1) * winStep;
t(:,[2 4]) = t(:,[2 4]) * winStep;

function z=aux(X,Y)
% Auxiliary function. It is used to implement the moving average filter.
%z = mean2(X.*Y);
z=sum(diag(X))+(1/2)*sum(diag(X,1))+(1/2)*sum(diag(X,-1));

