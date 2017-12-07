function [DTWCost,BestPath]=dynamicTimeWarpingItakura(B,A,tonorm)

% Computes the Dynamic Time Warping cost between the m-dimensional feature
% sequences B (test) and A (reference), based on the Itakura local path
% constraints. The Euclidean distance is used as a local distance metric.
% Sequence A is placed on the horizontal axis.
% INPUT:
% A: reference sequence (mxI)
% B: test sequence (mxJ)
% tonorm: if set to 1 then the matching cost is normalized, i.e., divided
% by the length of the best path.
% OUTPUT:
% DTWCost: the matching cost is normalized, i.e., it is divided with the
% length of the best path. Inf is returned if the alignment is not
% feasible.
% BestPath: the best path after backtracking has been performed. Each row of BestPath represents
% one node and consists of two numbers: the row and column index of the node in the cost grid.
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
AccCost(1,2)=AccCost(1,1)+LocalCost(1,2);
Predj(1,2)=1;
Predi(1,2)=1;
if I>2
    for i=3:I % forbidden transitions
        AccCost(1,i)=inf;
        Predj(1,i)=inf;
        Predi(1,i)=inf;
    end
end
for j=2:J % forbidden transitions
    AccCost(j,1)=inf;
    Predj(j,1)=inf;
    Predi(j,1)=inf;
end
% EOF Initialization

% Grid Processing
for j=2:J
    for i=2:I
        if j>=3
            if Predj(j-1,i)~=j
                [AccCost(j,i),ind]=min([AccCost(j-1,i-1) AccCost(j,i-1) AccCost(j-2,i-1) ]+LocalCost(j,i));
            elseif Predj(j,i-1)==j
                [AccCost(j,i),ind]=min([AccCost(j-1,i-1) inf AccCost(j-2,i-1) ]+LocalCost(j,i));
            end
        elseif j==2
            if Predj(j-1,i)~=j
                [AccCost(j,i),ind]=min([AccCost(j-1,i-1) AccCost(j,i-1) inf]+LocalCost(j,i));
            elseif Predj(j,i-1)==j
                [AccCost(j,i),ind]=min([AccCost(j-1,i-1) inf inf]+LocalCost(j,i));
            end
        end
        if ind==1
            Predj(j,i)=j-1;
            Predi(j,i)=i-1;
        elseif ind==2
            Predj(j,i)=j;
            Predi(j,i)=i-1;
        else
            Predj(j,i)=j-2;
            Predi(j,i)=i-1;
        end
    end
end
%End of Grid Processing

% Backtracking starts from node (J,I) and ends at fictitious node (0,0)
DTWCost=AccCost(J,I);
if isinf(DTWCost)
    BestPath=[];
    return;
end
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
