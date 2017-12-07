function musicVisualizationDemoSOM(FeaturesDir, FileNames, nGrid, method)

% function musicVisualizationDemo(FeaturesDir, FileNames, method)
% 
% This function demonstrates SOM-based content visualization
%
%  ARGUMENTS:
%   - FeaturesDir:      a cell array that contains feature matrices (one
%                       for each track)
%   - FilaNames:        a cell array that contains paths to tracks
%   - nGrid:            SOM grid size
%   - method:           0 for no preprocessing
%                       1 for LDA-based preprocessing
%

%
% IMPORTANT: To be used after featureExtractionDir(), e.g:
% [FeaturesDir, FileNames] =  featureExtractionDir('data', ...
%             0.020, 0.020, 2.0, 2.0, {'mean','std'});;
%

if (method==0)
    X = [];
    for i=1:length(FeaturesDir)
        X = [X mean(FeaturesDir{i},2)];
    end
    % normalization is needed:
    MEAN = mean(X'); STD = std(X');
    
    for i=1:size(X,2)
        X(:,i) = (X(:,i)  - MEAN') ./ STD';
    end
    
    net = selforgmap([nGrid nGrid], 1000, 3, 'gridtop');
    net = train(net, X);
    y = net(X);
    classes = vec2ind(y);
else
    X  = []; L = [];
    for i=1:length(FeaturesDir)
        X = [X FeaturesDir{i}];
        L = [L; i*ones(size(FeaturesDir{i}, 2), 1)];
    end
    X = X'; [V, eigvalueSum] = fld(X, L, 10);
    for i=1:length(FeaturesDir)
        MeanFeatureVector = mean(FeaturesDir{i}, 2);
        SongCoords(i,:) = MeanFeatureVector' * V;
    end
    
    X = SongCoords';
    net = selforgmap([nGrid nGrid], 1000, 3, 'gridtop');
    net = train(net, X);
    y = net(X);
    classes = vec2ind(y);    
end

    plotsomhits(net, X);

    % make subplot:
    fig1 = gcf; h = get(fig1, 'children'); fig2 = figure;    
    figure(fig2); g = subplot(1, 2, 1);    
    set(h, 'pos', get(g, 'pos')); delete(fig2); figure(fig1);
    
    subplot(1,2,1); title('Visualization');
    while (1)    
        subplot(1,2,1); 
        set(gca,'xtick',[],'ytick',[])        
        [xx, yy, button] = ginput(1);
        if button~=1 break; end       
        if exist('PP') delete(PP); end
        xx = round(xx) + 1; yy = round(yy) + 1;            
        PP = rectangle('Position',[xx-1.5, yy-1.5 , 1, 1], 'LineWidth', 3, 'EdgeColor', [0.5 0.0 0.7]);
        clusterIndex = (yy - 1) * nGrid  + xx;
        filesIndex = find(classes==clusterIndex);
        
        subplot(1,2,2);
        cla
        songsList = {};
        for i=1:length(filesIndex)
            [pathstr, songname, ext] = fileparts( FileNames{filesIndex(i)}) ;
            songsList{i} = songname;
            text(0.1, i, songsList{i}, 'interpreter','none')
        end
        axis([0 2 0 length(filesIndex)+1]);
        set(gca,'xtick',[],'ytick',[])
    end
