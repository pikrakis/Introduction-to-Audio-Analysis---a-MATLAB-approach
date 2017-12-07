function [ViterbiScore,BestPath]=scaledViterbiDisObs(pi_init,A,B,X)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION
%   [ViterbiScore,BestPath]=scaledViterbiDisObs(pi_init,A,B,X)
% Implements the scaled viterbi algorithm for the case of HMMs
% which emit discrete observations from a finite alphabet. Scaling is
% necessary when long sequences are analysed. If scaling is not employed,
% numerical underflow is likely to occur after the first few symbols have
% been processed.
%
% INPUT ARGUMENTS:
%   pi_init:        vector of initial state probalities.
%   A:              state transition matrix. The sum of each row equals 1.
%   B:              observation probability matrix. The sum of each columns equals 1.
%   X:              observation sequence, i.e., sequence of symbol ids.
%
% OUTPUT ARGUMENTS:
%   ViterbiScore:   Viterbi score (scaled).
%   BestPath:       Best-state sequence as a vector of complex numbers.
%                   The real part of each complex number stands for the
%                   y-coordinate of the node (state number) and the imaginary part is the
%                   x-coordinate (observation (time) index). Therefore, the real part
%                   of this output variable is the best-state sequence
%
% (c) 2014 T. Giannakopoulos, A. Pikrakis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initialization
T=length(X);
[M,N]=size(B);

pi_init(find(pi_init==0))=-inf;
pi_init(find(pi_init>0))=log10(pi_init(find(pi_init>0)));

A(find(A==0))=-inf;
A(find(A>0))=log10(A(find(A>0)));

B(find(B==0))=-inf;
B(find(B>0))=log10(B(find(B>0)));

alpha=zeros(N,T); % preallocating alpha to speed up execution

% First observation
alpha(:,1)=pi_init + B(X(1),:)';
Pred(:,1)=zeros(N,1);

% Construct the trellis diagram
for t=2:T
    for i=1:N
        temp=alpha(:,t-1)+A(:,i)+B(X(t),i);
        [alpha(i,t),ind]=max(temp);
        Pred(i,t)=ind+sqrt(-1)*(t-1);
    end
end

[ViterbiScore,WinnerInd]=max(alpha(:,T));

% Backtracking to extract the best-state sequence
BestPath=WinnerInd+sqrt(-1)*T;
while BestPath(1)~=0 %until fictitious node (0,0) has been reached
    newnode=Pred(real(BestPath(1)),imag(BestPath(1)));
    BestPath=[newnode;BestPath];
end
BestPath(1)=[]; % remove fictitious node from the beginning of the path





