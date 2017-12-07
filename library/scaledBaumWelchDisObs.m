function [BWScore]=scaledBaumWelchDisObs(pi_init,A,B,X)

%   [BWScore]=scaledBaumWelchDisObs(pi_init,A,B,X)
% Implements the scaled Baum-Welch (any-path) score for the case of HMMs
% which emit discrete observations from a finite alphabet. Scaling is
% necessary when long sequences are analysed. If scaling is not employed,
% numerical underflow is likely to occur after the first few symbols have
% been processed.
%
% INPUT ARGUMENTS:
%   pi_init:        initial state probalities.
%   A:              state transition matrix.
%   B:              observation probabilities per state.
%   X:              symbol sequence (discrete alphabet)
%
% OUTPUT ARGUMENTS:
%   BWScore:   Baum-Welch score for sequence X.
%
% (c) 2014 T. Giannakopoulos, A. Pikrakis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Initialization
T=length(X);
c=zeros(size(X));
[M,N]=size(B);
alpha=zeros(N,T); % pre-allocate alpha to speed up execution

% t=1
alpha(:,1)=pi_init.* B(X(1),:)';
c(1)=1/(sum(alpha(:,1))); % scaling coefficient ;
alpha(:,1)=c(1)*alpha(:,1); % scale alpha(:,1)

% t>1
for t=2:T
    for i=1:N
        alpha(i,t)=sum((alpha(:,t-1).* A(:,i)) * B(X(t),i));        
    end
    c(t)=1/(sum(alpha(:,t))); %scaling coef at the t-th time instant
    alpha(:,t)=c(t)*alpha(:,t); % scale alpha sequence
end

[BWScore]=-sum(log10(c));

