function [CM1, Ac1, Pr1, Re1, F11, CM2, Ac2, Pr2, Re2, F12] = ...
                evaluateClassifier(Features, kNN, ...
                    evaluationMethod, evalMethodParams)

%               
% function [CM1, Ac1, Pr1, Re1, F11, CM2, Ac2, Pr2, Re2, F12] = ...
%                evaluateClassifier(Features, kNN, ...
%                    evaluationMethod, evalMethodParams)
% 
% Implements the classifier evaluation process.
% In particular, two validation methods have been implemented:
% (a) the repeated hold out validation and (b) the leave-one-out method.
%
% ARGUMENTS:
% - Features:           A cell array that contains all features
%                       of the model 
% - kNN:                The k parameter of the kNN classifier
% - evaluationMethod:   1 for repeated hold-out validation
%                       2 for leave-one-out
% - evalMethodParams:   Used only for the 1st method. This array
%                       contains the params of the repeated-hold-out
%                       evaluation method. The first element is the 
%                       proportion of train data used in each iteration
%                       (e.g. 0.80) and the second is the number
%                       of experimental iterations.
%
% RETURNS:
% - CM1:                the confusion matrix (general normalization)
% - Ac1, Pr1, Re1, F11: overall accuracy,  precision rates, recall rates
%                       and f1 measures (general normalization)
% - CM2:                the confusion matrix (row-wise normalization)
% - Ac2, Pr2, Re2, F12: overall accuracy,  precision rates, recall rates
%                       and f1 measures (row-wise normalization)
%
% EXAMPLE:
% load model8
% [CM1B, Ac1B, Pr1B, Re1B, F11B, CM2B, Ac2B, Pr2B, Re2B, F12B] = ...
%           evaluateClassifier(Features, 23, 2, []);
%

% number of classes:
nClasses = length(Features);

% transpose from cell to matrix:
Fall = [];
C = [];
for i=1:nClasses
    Fall = [Fall; Features{i}'];
    C    = [C; ones(size(Features{i}, 2), 1) * i];
end
nSamples = length(C);

% evaluate the classifier:
switch evaluationMethod
    case 1 % repeated hold-out validation:        
        perTrain = evalMethodParams(1);
        nExp = evalMethodParams(2);
        CMall = zeros(nClasses);
        predictedAll = [];
        realAll = [];
        for k=1:nExp
            RandPerm = randperm(nSamples);
            nTrain = round(nSamples * perTrain);
            Ftrain = Fall(RandPerm(1:nTrain), :);
            Ctrain = C(RandPerm(1:nTrain));
            Ftest = Fall(RandPerm(nTrain+1:end), :);
            Ctest = C(RandPerm(nTrain+1:end));

            % build kNN classifier:
            MEAN = mean(Ftrain);
            STD = std(Ftrain);    
            for i=1:nClasses % for each class:
                FeaturesTrain{i} = Ftrain(Ctrain==i, :)';
                % normalize data and store:
                for j=1:size(FeaturesTrain{i}, 2)
                    FeaturesTrain{i}(:, j) = (FeaturesTrain{i}(:, j) - MEAN') ./ STD';
                end
            end

            % test:
            predicted = zeros(length(Ctest), 1);
            for i=1:length(Ctest)
                testSample = Ftest(i,:)';        
                testSample = (testSample - MEAN') ./ STD';
                [Ps, predicted(i)] = classifyKNN_D_Multi(FeaturesTrain, testSample, kNN, 1);        
            end
            predictedAll = [predictedAll; predicted];
            realAll =      [realAll; Ctest];    
            % these temporary measures are kept for standard deviation calculation:
            % [CMt, Act(k), Prt(k, :), Ret(k, :), F1t(k, :)] = computePerformanceMeasures(predicted, Ctest, 1);    
        end
        
    case 2 % leave-one-out  
        MEAN = mean(Fall);
        STD = std(Fall);    
        for i=1:nClasses % for each class:
            % normalize
            for j=1:size(Features{i}, 2)
                Features{i}(:, j) = (Features{i}(:, j) - MEAN') ./ STD';
            end
        end
        
        count = 0;
        realAll = zeros(nSamples, 1);
        predictedAll = zeros(nSamples, 1);
        for i=1:nClasses           
            for j=1:size(Features{i}, 2)
                count = count + 1;
                FeaturesTrain = Features;               
                FeaturesTrain{i}(:, j) = [];
                
                % test:                        
                testSample = Features{i}(:, j);   % (sample is already normlaized)
                [Ps, predictedAll(count)] = classifyKNN_D_Multi(FeaturesTrain, testSample, kNN, 1);            
                realAll(count) = i;
            end
        end
end

% Compute the performance measures:
[CM1, Ac1, Pr1, Re1, F11] = computePerformanceMeasures(predictedAll, realAll, 1);
[CM2, Ac2, Pr2, Re2, F12] = computePerformanceMeasures(predictedAll, realAll, 2);