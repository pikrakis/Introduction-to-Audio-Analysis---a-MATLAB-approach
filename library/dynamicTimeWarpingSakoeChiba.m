function [DTWCost,BestPath] = dynamicTimeWarpingSakoeChiba(B,A,tonorm)

% Computes the Dynamic Time Warping cost between the m-dimensional feature
% sequences B(test) and A (reference), based on the Sakoe-Chiba local path
% constraints. The Euclidean distance is used as a local distance metric.
% Sequence A is placed on the horizontal axis.
% ARGUMENTS:
%   - A:        reference sequence (mxI)
%   - B:        test sequence (mxJ)
%   - tonorm:   if set to 1 then the matching cost is normalized, i.e., divided
%               by the length of the best path.
% RETURNs:
%   - DTWCost:  the matching cost is normalized, i.e., it is divided with the length of the best path.
%   - BestPath: the best path after backtracking has been performed. Each row of BestPath represents 
%               one node and consists of two numbers: the row and column index of the node in the cost grid.
%
% (c) 2013 T. Giannakopoulos, A. Pikrakis

%Initialization
[m,J]=size(B);
[m,I]=size(A);

LocalCost=zeros(J,I);
Predi=zeros(J,I);
Predj=zeros(J,I);
AccCost=zeros(J,I);

for j=1:J        
    for i=1:I
        %Euclidean distance
        LocalCost(j,i)=sqrt(sum((B(:,j)-A(:,i)).^2));
    end
end

%Initialization
AccCost(1,1)=LocalCost(1,1);
Predi(1,1)=0;
Predj(1,1)=0;

% Initialization
% First column of the cost matrix
for j=2:J
    AccCost(j,1)=AccCost(j-1,1)+LocalCost(j,1);
    Predj(j,1)=j-1;
    Predi(j,1)=1;
end
% First row of the cost matrix
for i=2:I
    AccCost(1,i)=AccCost(1,i-1)+LocalCost(1,i);
    Predj(1,i)=1; 
    Predi(1,i)=i-1;
end
% EOF Initialization

% Grid Processing
for j=2:J    
    for i=2:I        
        [AccCost(j,i),ind]=min([AccCost(j-1,i-1) AccCost(j-1,i) AccCost(j,i-1)]+LocalCost(j,i)); 
        if ind==1
            Predj(j,i)=j-1;
            Predi(j,i)=i-1;
        elseif ind==2
            Predj(j,i)=j-1;
            Predi(j,i)=i;
        else
            Predj(j,i)=j;
            Predi(j,i)=i-1;
        end
    end 
end 
%End of Grid Processing

% Backtracking starts from node (J,I) and ends at fictitious node (0,0)
DTWCost=AccCost(J,I);
curnodej=J;
curnodei=I;
BestPath=[curnodej curnodei];
while curnodej~=0 && curnodei~=0
    prevnodej=Predj(curnodej,curnodei);
    prevnodei=Predi(curnodej,curnodei);
    BestPath=[[prevnodej prevnodei]; BestPath];
    curnodej=prevnodej;
    curnodei=prevnodei;
end
BestPath(1,:)=[]; % remove fictitious node, (0,0), from BestPath
if tonorm==1
    DTWCost=DTWCost/size(BestPath,1);
end
