function [MatchingProb,BestPath]=scaledViterbiContObs(pi_init,A,B,X)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION
%   [MatchingProb,BestPath]=scaledViterbiContObs(pi_init,A,B,X)
% Implements the scaled  Viterbi algorithm for
% continuous-observation HMMs, for the case of l-dimensional observations
% (l-dimensional feature vectors). It is assumed that the observation pdf at each state
% is a Gaussian mixture.
%
% INPUT ARGUMENTS:
%   pi_init:        vector of initial state probalities.
%   A:              state transition matrix. The sum of each row equals 1.
%   B:              B can be:
%                   (a) a 2xN standard array, where N is the number of
%                   states. This case deals with 1-dimensional
%                   observations, i.e.,
%                   B(1,i) is the mean value and B(2,i) is the standard 
%                   deviation of the 1-dimensional Gaussian pdf of the i-th
%                   state.
%                   (b) a 3xN cell array, where N is the number of states.
%                   In this case, the pdf at each state is a gaussian
%                   mixture and the observations are l-dimensional feature
%                   vectors. Specifically: B{1,i} is a lxc matrix, whose columns contain the means of
%                   the normal distributions involved in the mixture,
%                   B{2,i} is a lxlxc matrix where S(:,:,k) is the covariance 
%                   matrix of the k-th normal distribution of the mixture
%                   and B{3,i} is a c-dimensional vector containing the mixing probabilities for
%                   the distributions of the mixture at the i-the state.                   
%   X:              sequence of feature vectors (one column per feature vector).
%
% OUTPUT ARGUMENTS:
%   MatchingProb:   Viterbi score (log-scaled).
%   BestPath:       Best-state sequence as a vector of complex numbers.
%                   The real part of each complex number stands for the
%                   y-coordinate of the node (state number) and the imaginary part is the
%                   x-coordinate (observation (time) index). Therefore, the real part
%                   of this output variable is the best-state sequence
%
% (c) 2014 T. Giannakopoulos, A. Pikrakis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initialization
T=size(X,2);
[N,N]=size(A);

pi_init(find(pi_init==0))=-inf;
pi_init(find(pi_init>0))=log10(pi_init(find(pi_init>0)));

A(find(A==0))=-inf;
A(find(A>0))=log10(A(find(A>0)));

alpha=zeros(N,T); % preallocate alpha to speed up execution

if ~iscell(B)
    for i=1:N
        alpha(i,1)=pi_init(i)+log10(normpdf(X(:,1),B(1,i),B(2,i)));
    end
    
    Pred(:,1)=zeros(N,1);
    
    % Construct the trellis diagram
    for t=2:T
        for i=1:N
            temp=alpha(:,t-1)+A(:,i)+log10(normpdf(X(:,t),B(1,i),B(2,i)));
            [alpha(i,t),ind]=max(temp);
            Pred(i,t)=ind+sqrt(-1)*(t-1);
        end
    end
else
    for i=1:N
        alpha(i,1)=pi_init(i)+log10(mixturepdf(B{1,i},B{2,i},B{3,i},X(:,1)));
    end    
    Pred(:,1)=zeros(N,1);
    
    % Construct the trellis diagram
    for t=2:T
        for i=1:N
            temp=alpha(:,t-1)+A(:,i)+log10(mixturepdf(B{1,i},B{2,i},B{3,i},X(:,t)));
            [alpha(i,t),ind]=max(temp);
            Pred(i,t)=ind+sqrt(-1)*(t-1);
        end
    end
end

[MatchingProb,WinnerInd]=max(alpha(:,T));

% Backtracking to extract the best-state sequence
BestPath=WinnerInd+sqrt(-1)*T;
while BestPath(1)~=0 %until fictitious node (0,0) has been reached
    newnode=Pred(real(BestPath(1)),imag(BestPath(1)));
    BestPath=[newnode;BestPath];
end
BestPath(1)=[]; % remove fictitious node from the beginning of the path

