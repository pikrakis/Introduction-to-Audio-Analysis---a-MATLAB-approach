function path = viterbiBestPath(priors, transMat, probEst)


% path = viterbiBestPath(priors, transMat, probEst)
%
% This function finds the most-likely state sequence
% 
% ARGUMENTS:
% priors:       an array of initial (prior) probabilities for each state
% transMat:     a matrix of transition probabilities from state i to 
%               state j
% probEst:      a matrix of probability estimations P(observation|state)
%               of size [numOfStates x numOfObservations]
%
% RETURNS:
% path:         labels of the states that compose the most likely path
%
% (c) 2014 T. Giannakopoulos, A. Pikrakis

priors = priors(:);     
numOfObservations = size(probEst, 2);   % time length
numOfStates = length(priors);           % number of states
T1 = zeros(numOfStates, numOfObservations);
T2 = zeros(numOfStates, numOfObservations);
path = zeros(1,numOfObservations);
t=1;
T1(:,t) = priors .* probEst(:,t);
T2(:,t) = 0; 
for t=2:numOfObservations               % for each observation in time
    for j=1:numOfStates                 % for each state
        [T1(j,t), T2(j,t)] = max(T1(:,t-1) .* transMat(:,j));
        T1(j,t) = T1(j,t) * probEst(j,t);
    end
end
[p, path(numOfObservations)] = max(T1(:,numOfObservations));
for t=numOfObservations-1:-1:1
    path(t) = T2(path(t+1),t+1);
end

