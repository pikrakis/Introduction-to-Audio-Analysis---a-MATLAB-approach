function [BWScore]=scaledBaumWelchContObs(pi_init,A,B,X)

%   [BWScore]=scaledBaumWelchContObs(initProbs,A,B,X)
% Implements the scaled Baum-Welch (any-path) score for the case of HMMs
% which emit continuous multidimensional observations. Scaling is
% necessary when long sequences are analysed. If scaling is not employed,
% numerical underflow is likely to occur after the first few symbols have
% been processed.It is assumed that the pdf at each state
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
%   BWScore:   Baum-Welch score (scaled).
%
% (c) 2014 T. Giannakopoulos, A. Pikrakis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

T=size(X,2);
c=zeros(1,size(X,2));
[N,n]=size(A);
alpha=zeros(N,T);    
    
if ~iscell(B)
    %Initialization, t=1
    for i=1:N
        alpha(i,1)=pi_init(i)*normpdf(X(:,1),B(1,i),B(2,i));
    end    
    c(1)=1/(sum(alpha(:,1))); % scaling coef at t=1;    
    alpha(:,1)=c(1)*alpha(:,1); % scale alpha sequence    
       
    % Iteration, t>1
    for t=2:T
        for i=1:N
            alpha(i,t)=sum((alpha(:,t-1).* A(:,i)) * normpdf(X(:,t),B(1,i),B(2,i)));
        end
        c(t)=1/(sum(alpha(:,t))); %scaling coef at the t-th time instant
        alpha(:,t)=c(t)*alpha(:,t); % scale alpha sequence
    end    
else
    %Initialization, t=1
    for i=1:N
        alpha(i,1)=pi_init(i)*mixturepdf(B{1,i},B{2,i},B{3,i},X(:,1));
    end
    c(1)=1/(sum(alpha(:,1))); % scaling coef at t=1;
    alpha(:,1)=c(1)*alpha(:,1); % scale alpha sequence    
    
    % Iteration, t>1
    for t=2:T
        for i=1:N
            alpha(i,t)=sum((alpha(:,t-1).* A(:,i)) * mixturepdf(B{1,i},B{2,i},B{3,i},X(:,t)));
        end
        c(t)=1/(sum(alpha(:,t))); %scaling coef at the t-th time instant
        alpha(:,t)=c(t)*alpha(:,t); % scale alpha sequence
    end
end
[BWScore]=-sum(log10(c));

