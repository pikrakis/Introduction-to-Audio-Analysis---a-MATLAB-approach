function segmentationPlotResults(segs, classes, fileName)

%
% function segmentationPlotResults(segs, classes, fileName)
% 
% This function provides a simple user interface to view and listen the 
% results of a segmentation - classification procedure.
%
% The user is prompt with a simple graphical representation of the 
% classification-segmentation result and can select particular segments to 
% hear using the mouse. Stops when right click is pressed.
%
% ARGUMENTS:
%  - segs:          segment limits [numOfSegment x 2] (in seconds)
%  - classes:       class labels for each detected segment (numOfSegments)
%  - fileName:      the path of the WAV file being processed 
%
% EXECUTION EXAMPLE:
% [segs, classes, Labels, centers] = silenceRemoval('example.wav', 1, 0);
% segmentationPlotResults(segs, classes, 'example.wav');
%

classes = classes + 1;

[a, fs] = wavread(fileName, 'size');
totalDuration = a(1) / fs;    % get the input file's duration in seconds

Width = 1000; Height = 20;
Ratio = Width / totalDuration;

% Generate image to plot (from class labels):
plotLabels = [];
for i=1:size(segs,1)
    plotLabels = [plotLabels classes(i) * ones(Height, round(Ratio * (segs(i,2)-segs(i,1))))];
end

% choose a "lines" color mapping
map = colormap(lines(length(unique(classes))));   
%map = colormap(gray(length(unique(classes))));   

subplot(2,1,1)
imshow(plotLabels, map)
hold on;

% plot the time segment limits (text):
for i=1:size(segs, 1)    
    T = text(segs(i, 2) * (Width / totalDuration), -Height, sprintf('%.1f', segs(i,2)));
    set(T, 'HorizontalAlignment', 'center');
end

% let the user select segments:
while (1)
    % get the mouse selection:
    subplot(2,1,1)
    [x, y, m] = ginput(1);
    if m>1        
        break
    end    
    % transform to time index:
    TimeIndex = (x / Width) * totalDuration;
    % find in which segment does the TimeIndex belong to:
    Dists = TimeIndex - segs;
    PDist = prod(Dists, 2);
    Iselected = find(PDist<0);
    [a, fs] = wavread(fileName, 'size');        
    [xselected, fs] = wavread(fileName, round([segs(Iselected, 1) * fs + 1 segs(Iselected, 2) * fs]));
    timeaxis = round([segs(Iselected, 1) * fs + 1 : segs(Iselected, 2) * fs]) / fs;
    subplot(2,1,2)
    plot(timeaxis, xselected, 'k');
    xlabel('Time (sec)');
    ylabel('Signal values');
    sound(xselected, fs)
end

