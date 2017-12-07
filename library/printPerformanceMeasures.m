function printPerformanceMeasures(CM, Ac, Pr, Re, F1, ClassNames)

%
% This function prints a table of classification performance results
% (confusion matrix, recall, precision, etc) in Latex format
%

numOfClasses = size(CM, 1);

fprintf('\\begin{table}[htbp]\n');
fprintf('\t\\caption{Overall accuracy: %.1f, Average Precision: %.1f, Average Recall: %.1f, Average F1 measure: %.1f}\n', 100*Ac, mean(Pr*100), mean(Re*100), mean(F1*100));
fprintf('\t\\begin{center}\n');
fprintf('\t\t\\begin{tabular}{c|');
for i=1:numOfClasses 
    fprintf('c'); end;
fprintf('}\n');
fprintf('\t\t \\multicolumn{%d}{c}{Confusion Matrix} \\\\ \n', numOfClasses+1);
% print the class names column-wise:
fprintf('\t\t\\hline\n');
fprintf('\t\t\t& \\multicolumn{%d}{c}{Predicted} \\\\ \n', numOfClasses);
fprintf('\t\t%15s', 'True $\Downarrow$');
for i=1:numOfClasses 
    fprintf('&\\begin{sideways}%s\\end{sideways}', ClassNames{i}); 
end;
fprintf('\\\\ \\hline \n');


% print the rest of the CM:
for i=1:numOfClasses
    fprintf('\t\t%15s',ClassNames{i});
    for j=1:numOfClasses
        fprintf('&%15.1f',100*CM(i,j));
    end
    fprintf('\\\\ \n');
end

fprintf('\\hline \n');
% print recall, precision and F1 measure:
fprintf('\t\t \\multicolumn{%d}{c}{ } \\\\ \n', numOfClasses+1);
fprintf('\t\t \\multicolumn{%d}{c}{Performance Measures (per class)} \\\\ \n', numOfClasses+1);
fprintf('\t\t\\hline\n');
fprintf('\t\t%15s','Precision:');
for i=1:numOfClasses fprintf('&%15.1f', 100*Pr(i)); end
fprintf('\t\t \\\\ \n');
fprintf('\t\t%15s','Recall:');
for i=1:numOfClasses fprintf('&%15.1f', 100*Re(i)); end
fprintf('\t\t \\\\ \n');
fprintf('\t\t%15s','F1:');
for i=1:numOfClasses fprintf('&%15.1f', 100*F1(i)); end
fprintf('\t\t \\\\ \n');
fprintf('\t\t\\hline\n');


fprintf('\t\t\\end{tabular}\n');
fprintf('\t\\end{center}\n');
fprintf('\t\\label{tab:???}\n');
fprintf('\\end{table}\n');
