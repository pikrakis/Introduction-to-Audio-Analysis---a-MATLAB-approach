function musicVisualizationDemo(FeaturesDir, FileNames, method)

% function musicVisualizationDemo(FeaturesDir, FileNames, method)
% 
% This function demonstrates three linear dimensionality reduction methods for
% music content visualization
%
%  ARGUMENTS:
%   - FeaturesDir:      a cell array that contains feature matrices (one
%                       for each track)
%   - FilaNames:        a cell array that contains paths to tracks
%   - method:           0: Random projection
%                       1: PCA
%                       2: LDA
%

%
% IMPORTANT: To be used after featureExtractionDir(), e.g:
% [FeaturesDir, FileNames] =  featureExtractionDir('data', ...
%             0.020, 0.020, 2.0, 2.0, {'mean','std'});;
%
% (c) 2014 T. Giannakopoulos, A. Pikrakis


switch method
    case 0  % RANDOM PROJECTION
        X  = []; 
        for i=1:length(FeaturesDir) 
            % long-term averaging:
            X = [X mean(FeaturesDir{i}, 2)]; 
        end
        X = X';
        % normalization is needed for random projection:
        MEAN = mean(X); STD = std(X);
        V = rand(size(X, 2), 2);
    case 1  % PCA
        X  = [];
        for i=1:length(FeaturesDir) 
            % long-term averaging:
            X = [X mean(FeaturesDir{i}, 2)]; 
        end
        X = X';  [COEFF, SCORE] = princomp(X);
        V = COEFF(:, 1:2);
    case 2  % FLD:
        X  = []; L = [];
        for i=1:length(FeaturesDir)
            X = [X FeaturesDir{i}];
            L = [L; i*ones(size(FeaturesDir{i}, 2), 1)];
        end

        X = X';
        [V, eigvalueSum] = fld(X, L, 2);
end


figure;
Selected = [];
while (1)
    clf;
    %subplot(2,1,1)
    hold on;
    for i=1:length(FeaturesDir)
        MeanFeatureVector = mean(FeaturesDir{i}, 2);
        if method>0
            SongCoords(i,:) = MeanFeatureVector' * V;        
        else % RANDOM PROJECTION NEEDS NORMALIZATION FIRST:
            SongCoords(i,:) = ((MeanFeatureVector' - MEAN) ./ STD) * V;        
        end
        [pathstr, name, ext] = fileparts(FileNames{i});
        
        if length(name)>15
            nameToPlot = strrep(name(1:15), '_', ' ');        
        else
            nameToPlot = name;
        end
        TT = text(SongCoords(i,1), SongCoords(i,2), nameToPlot);
        set(TT, 'HorizontalAlignment','center');
        if ismember(i, Selected)                        
            set(TT, 'Color', [1 0 0]);             
        end
    end
    RangeX = max(SongCoords(:,1)) - min(SongCoords(:,1));
    RangeY = max(SongCoords(:,2)) - min(SongCoords(:,2));
    axis([min(SongCoords(:,1))-0.1*RangeX max(SongCoords(:,1))+0.1*RangeX min(SongCoords(:,2))-0.1*RangeY max(SongCoords(:,2))+0.1*RangeY])
    set(gca,'xtick',[],'ytick',[])
    
    [x, y, button] = ginput(1);
    if button~=1 break; end
    
    Dists = pdist2([x y], SongCoords);
    [~, Selected] = min(Dists);    
    [a, fs ] = wavread(FileNames{Selected},'size');
    [pathstr, name, ext] = fileparts(FileNames{Selected});        
    TT = text(SongCoords(Selected,1), SongCoords(Selected,2), strrep(name, '_', ' '));
    set(TT, 'HorizontalAlignment','center');
    set(TT, 'Color', [1 0 0]); drawnow
    Length = a(1);
    [signal, fs] = wavread(FileNames{Selected}, round([Length/2 Length/2+5*fs]));
    soundOS(signal, fs);
end
