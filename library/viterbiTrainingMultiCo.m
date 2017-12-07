function [piTrained, ATrained, BTrained, AllProb] = viterbiTrainingMultiCo(pi_init, A, B, TrainingSet, maxEpoch, mindiff)

% [piTrained, ATrained, BTrained, AllProb] = viterbiTrainingMultiCo(pi_init, A, B, TrainingSet, maxEpoch,mindiff)
% Viterbi training (scaled version) of a Continuous Observation HMM when
% the pdf at each state is a multivariate Gaussian. 
%
% ARGUMENTS:
%   pi_init:        vector of initial state probalities upon initialization.
%   A:              state transition matrix (initialization).
%   B:              pdf at the each state. For the i-th state:
%                   B{i}{1} is the mean vector of the pdf. B{i}{2} is the
%                   respective covariance matrix.
%   TrainingSet:    vector of cells. Each cell contains an
%                   observation sequence (sequence of vectors).
%   maxEpoch:       maximum number of training epochs
%   mindiff:        minimum acceptable change between successive epochs
%
% RETURNS:
%   piTrained:      vector of initial state probalities at the output of
%                   the training stage.
%   ATrained:       state transition matrix at the output of the training stage.
%   BTrained:       trained pdf at the each state. For the i-th state:
%                   B{i}{1} is the mean vector of the pdf. B{i}{2} is the
%                   respective covariance matrix.
%   AllProb:        vector, each element of which contains the sum of the
%                   scaled Viterbi scores of all observation sequences at each epoch.
%
% (c) 2014 T. Giannakopoulos, A. Pikrakis

L=length(TrainingSet);
[N,n]=size(A);

% convert format of B so that it complies with the calling format of
% scaledViterbiContObs
for i=1:N
    Bt{1,i}=B{i}{1};
    Bt{2,i}=B{i}{2};
    Bt{3,i}=1;
end

theEpoch=1;
AllProb=[];
while theEpoch<=maxEpoch
    
    % Initialize temporary matrices
    Atemp=zeros(N);
    pitemp=zeros(N,1);
    for k=1:N
        Btemp{1,k}=zeros(size(Bt{1,k}));
        Btemp{2,k}=zeros(size(Bt{2,k}));
        Btemp{3,k}=1;
    end
    MatchingProb=zeros(1,L);
    auxCounter=zeros(1,N); % auxiliary counters, necessary for ML updates
    allPaths=cell(1,L);
    
    i=1;
    while i<=L
        X=TrainingSet{i};
        [MatchingProb(i),BestPath]=scaledViterbiContObs(pi_init,A,Bt,X);
        realPath=real(BestPath);
        % store each best-state sequence in allPaths to update the pdfs
        allPaths{i}=realPath;
        
        % update transition matrix
        for k=1:length(realPath)-1
            Atemp(realPath(k),realPath(k+1))=Atemp(realPath(k),realPath(k+1))+1;
        end
        % update initial probabilities
        pitemp(realPath(1))=pitemp(realPath(1))+1;
        i=i+1;
    end
    
    % Normalize pitemp so that it sums to unity and propagate the result to
    % the next epoch
    pi_init=pitemp/sum(pitemp);
    
    % Normalize each row of Atemp so that it sums to unity
    for k=1:N
        Atemp(k,:)=Atemp(k,:)/sum(Atemp(k,:));
    end
    A=Atemp; % propagate the estimate of A (Atemp) to the next epoch
    
    % update the mean vector of the pdf at each state
    for j=1:length(allPaths)
        realPath=allPaths{j};
        for k=1:length(realPath)
            Btemp{1,realPath(k)}=Btemp{1,realPath(k)}+TrainingSet{j}(:,k);
            auxCounter(realPath(k))=auxCounter(realPath(k))+1;
        end
    end
    
    for k=1:N
        if auxCounter(k)>0
            Btemp{1,k}=Btemp{1,k}/auxCounter(k);
        end
    end
    
    % update the covariance matrix of the pdf at each state
    for j=1:length(allPaths)
        realPath=allPaths{j};
        for k=1:length(realPath)
            Btemp{2,realPath(k)}=Btemp{2,realPath(k)}+...
                (TrainingSet{j}(:,k)-Btemp{1,realPath(k)})*(TrainingSet{j}(:,k)-Btemp{1,realPath(k)})';
        end        
    end
    for k=1:N
        if auxCounter(k)>0
            Btemp{2,k}=Btemp{2,k}/auxCounter(k);
        end
    end    
    Bt=Btemp; % propagate the estimate of B (Btemp) to the next epoch
        
    AllProb(theEpoch)=sum(MatchingProb);
    % if the sum of probabilities changes insignificantly then stop the
    % training procedure
    if theEpoch>1 && abs(AllProb(theEpoch)-AllProb(theEpoch-1))<=mindiff
        break;
    end
    fprintf('Epoch : %d, Sum %f= \n',theEpoch, AllProb(theEpoch));
    
    theEpoch=theEpoch+1;
end

piTrained=pi_init;
ATrained=A;
% Convert Bt to the format of input argument B for compatibility purposes
for i=1:N
    BTrained{i}{1}=Bt{1,i};
    BTrained{i}{2}=Bt{2,i};
end
