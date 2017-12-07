function [acc_cost,row_pred,col_pred,maxv,bp]=smithWaterman(A,B,penalty,verbose,plotAlignment)
% Implements the well known Smith-Waterman algorithm which was proposed in
% the 80's in the context of molecular sequence alignment.
% Example of use:
% [acc_cost,row_pred,col_pred,maxv,bp]=SmithWaterman([1 -1 1 -1 1 1 2 1 2],[1 -1 1 -1 1 2 1 2],1/3,1,0);
%
% INPUT:
% A and B: the two one-dimensional feature sequences%
% penalty: gap penalty. Controls the extent to which symbol deletions are penalized.
% verbose: if set to 1, a text version of the alignment is printed on stdout.
% plotAlignment: if set to 1, a plot of the alignment is drawn in a figure.
%
% OUTPUT:
% acc_cost: is the accumulated cost at node (i,j). At the end of the processing stage,
% the maximum value of acc_cost will reveal the node from which backtracking will start.
% row_pred, col_pred: row-coordinate and column-coordinate of the predecesssor of node (i,j).
% These are needed for backtracking purposes.
% maxv: computed similarity, i.e., maximum value of acc_cost
% bp: best-path, i.e., sequence of node coordinates, one node at each row of bp.
% % (c) 2013 T. Giannakopoulos, A. Pikrakis

LA=length(A);
M=LA+1;

LB=length(B);
N=LB+1;

% Initialization
D=zeros(M,N);
for i=1:LA
    for j=1:LB
        if A(i)==B(j)
            D(i+1,j+1)=1;
        else
            D(i+1,j+1)=-penalty;
        end
    end
end
% eo initialization


acc_cost=zeros(M,N);
row_pred=zeros(M,N);
col_pred=zeros(M,N);

% start grid processing
for i=2:M %for every row (remember the first row is all zeros and stays like that till the end)
    for j=2:N %for every column (remember the first column is all zeros and stays like that till the end)
        temp_max=D(i,j);
        bestPredi=0;
        bestPredj=0;
        
        % Diagonal transition
        if acc_cost(i-1,j-1)+ D(i,j)>temp_max
            temp_max=acc_cost(i-1,j-1)+ D(i,j);
            bestPredi=i-1;
            bestPredj=j-1;
        end
        % Vertical scan: nodes (1,j),(2,j),...,(i-1,j)
        for row=1:i-1
            if acc_cost(row,j)-(1+(penalty)*(i-row))>temp_max
                temp_max=acc_cost(row,j)-(1+(penalty)*(i-row)); % the second term is the penalty term for the vertical transition
                bestPredi=row;
                bestPredj=j;
            end
            
        end
        
        % Horizontal scan: nodes (i,1),(i,2),...,(i,j-1)
        for col=1:j-1
            if acc_cost(i,col)-(1+(penalty)*(j-col))>temp_max
                temp_max= acc_cost(i,col)-(1+(penalty)*(j-col)); % the second term is the penalty term for the horizontal transition
                bestPredi=i;
                bestPredj=col;
            end
        end
        
        % Finished (i,j).There only remains to store the winner
        if temp_max>0
            acc_cost(i,j)=temp_max;
            row_pred(i,j)=bestPredi;
            col_pred(i,j)=bestPredj;
        end
    end
end
% eo grid processing


maxv=max(max(acc_cost)); % maximum accumulated similarity
if maxv==0
    bp=[];
    return;
end

[xc,yc]=find(acc_cost==maxv); % where maxv is located
xc=xc(1); yc=yc(1); % in case of ties

% Backtracking
bp=[xc yc];
while xc>0 && yc>0
    t_row=row_pred(xc,yc);
    t_col=col_pred(xc,yc);
    xc=t_row;
    yc=t_col;
    bp=[[xc yc];bp];
end
% eo backtracking

bp(1,:)=[];
bp=bp-1;

if verbose==1
    % Print Alignment on screen (can be skipped if verbose~=1)
    clc
    fprintf('Similarity = %5.2f\n\n',maxv);
    if ischar(A)
        fprintf('%5c <-> %-5c (match)\n',A(bp(1,1)),B(bp(1,2)));
    else
        fprintf('%5d <-> %-5d (match)\n',A(bp(1,1)),B(bp(1,2)));        
    end
    for i=2:size(bp,1)
        Ac=A(bp(i,1));
        Bc=B(bp(i,2));        
        if bp(i,1)==bp(i-1,1)+1 && bp(i,2)==bp(i-1,2)+1
            if Ac==Bc
                if ischar(A)
                    fprintf('%5c <-> %-5c (match)\n',Ac,Bc);
                else
                    fprintf('%5d <-> %-5d (match)\n',Ac,Bc);
                end
            else
                if ischar(A)
                    fprintf('%5c <-> %-5c (replacement)\n',Ac,Bc);
                else
                    fprintf('%5d <-> %-5d (replacement)\n',Ac,Bc);
                end
            end
            continue;
        end
        
        if bp(i,2)==bp(i-1,2)
            for k=bp(i-1,1)+1:bp(i,1)
                if ischar(A)
                    fprintf('%5c  <- %-5c (deleted)\n',A(k),' ');
                else
                    fprintf('%5d  <- %-5c (deleted)\n',A(k),' ');
                end
            end
            continue;
        end
        
        if bp(i,1)==bp(i-1,1)
            for k=bp(i-1,2)+1:bp(i,2)
                if ischar(A)
                    fprintf('%5c  -> %-5c (deleted)\n',' ',B(k));
                else
                    fprintf('%5c  -> %-5d (deleted)\n',' ',B(k));
                end
            end
        end
    end
    % eo print
end

if plotAlignment==1
    % Plot Alignment with graphics (can be skipped)
    clf;hold;
    axis([1 length(B) 1 length(A)]);
    plot(bp(:,2),bp(:,1),'r*');
    plot(bp(:,2),bp(:,1));
    grid on
    % eof plot
end
