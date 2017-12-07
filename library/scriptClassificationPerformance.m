function scriptClassificationPerformance(modelName)

% function scriptClassificationPerformance(modelName)
% 
% This function:
% A) Loads a kNN audio classification model and computes the 
%    respective performance measures using the repeated holdout 
%    and the leave-one-out validation methods.
% B) For the best k (for both evaluation methods), it prints the
%    respective confusion matrix and class-specific performance measures
%    (recall, precision and F1 measure).
%
% NOTEs: 
% - The optimization is based on the overall accuracy
% - The performance measures are based on the row-wise normalized CMs
%

% load classification model:
load(modelName); ks = [3:2:19]; % possible k values

% TESTING (EVALUATION)
for i=1:length(ks) % for each k value:
    % repeated hold-out validation:
	[CM1A{i}, Ac1A(i), Pr1A{i}, Re1A{i}, F11A{i}, ...
        CM2A{i}, Ac2A(i), Pr2A{i}, Re2A{i}, F12A{i}] = ...
            evaluateClassifier(Features, ks(i), 1, [0.90 20]);
    % leave-one-out:
	[CM1B{i}, Ac1B(i), Pr1B{i}, Re1B{i}, F11B{i}, ...
        CM2B{i}, Ac2B(i), Pr2B{i}, Re2B{i}, F12B{i}] = ...
            evaluateClassifier(Features, ks(i), 2, []);
end
% only CM-row-wise normalized measures are kept 
% (second arguments of evaluateClassifier):
F12Amean = mean(cell2mat(F12A(:)), 2); % (average F1 measure)
F12Bmean = mean(cell2mat(F12B(:)), 2);
% plot results
figure;  subplot(2,1,1); hold on; 
title('Results - repeated hold-out validation');
plot(ks, Ac2A);  plot(ks, F12Amean, 'r'); 
xlabel('k'); ylabel('Performance');
legend('Overall Accuracy', 'F1 measure'); 
subplot(2,1,2); hold on; 
title('Results - leave-one-out validation');
plot(ks, Ac2B);  plot(ks, F12Bmean, 'r');
xlabel('k'); ylabel('Performance');
legend('Overall Accuracy', 'F1 measure');
save([modelName '_results']); % save resultss

% PRINT LATEX CONFUSION MATRIX FOR THE BEST k HERE:
% for the repeated-hold-out validation method:
[MAXA, IMAXA] = max(Ac2A);
fprintf('\n\n * * *   repeated-hold-out (bestK=%d)* * * \n\n', ks(IMAXA));
printPerformanceMeasures(CM2A{IMAXA}, Ac2A(IMAXA), ...
    Pr2A{IMAXA}, Re2A{IMAXA}, F12A{IMAXA}, ClassNames);
% for the leave-one-out validation method:
[MAXB, IMAXB] = max(Ac2B);
fprintf('\n\n * * *   leave-one-out (bestK=%d)* * * \n\n', ks(IMAXB));
printPerformanceMeasures(CM2B{IMAXB}, Ac2B(IMAXB), ...
    Pr2B{IMAXB}, Re2B{IMAXB}, F12B{IMAXB}, ClassNames);