function [piTrained, ATrained, BTrained, AllProb] = viterbiTrainingMultiCoMix(pi_init, A, B, TrainingSet, maxEpoch, mindiff)

%   [piTrained, ATrained, BTrained, AllProb] = viterbiTrainingMultiCoMix(pi_init, A, B, TrainingSet, maxEpoch,mindiff)
% Viterbi training (scaled version) of a Continuous Observation HMM when
% the pdf at each state is a mixture of (multivariate) Gaussians. All
% covariance matrices are of the form s^2*I
%
% ARGUMENTS:
%   pi_init:        vector of initial state probalities upon initialization.
%   A:              state transition matrix (initialization).
%   B:              pdf (Gaussian mixture) at the each state. For the i-th state:
%                   B{i}{1} is lxc matrix, whose columns contain the means of
%                   the normal distributions involved in the mixture. B{i}{2} is a
%                   lxlxc matrix where S(:,:,k) is the covariance
%                   matrix of the k-th normal distribution of the mixture. 
%                   Each covariance matrix is diagonal, s^2*I. B{i}{3}
%                   is a c-dimensional vector containing the mixing probabilities for
%                   the distributions of the mixture at the i-the state.
%   TrainingSet:    vector of cells. Each cell contains an
%                   observation sequence (sequence of vectors)
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
for j=1:N
    Bt{1,j}=B{j}{1};
    Bt{2,j}=B{j}{2};
    Bt{3,j}=B{j}{3};
end

theEpoch=1;
AllProb=[];
while theEpoch<=maxEpoch
    
    % Initialize temporary matrices
    Atemp=zeros(N);
    pitemp=zeros(N,1);
    MatchingProb=zeros(1,L);
    auxCounter=zeros(1,N); % auxiliary counters, necessary for ML updates
    allPaths=cell(1,L);
    % convert format of B so that it complies with the calling format of
    % scaledViterbiContObs
    
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
    for j=1:N
        Atemp(j,:)=Atemp(j,:)/sum(Atemp(j,:));
    end
    A=Atemp; % propagate the estimate of A (Atemp) to the next epoch
    
    % update the pdf at each state using the EM algorithm
    % i) Gather all data that have been emitted by the j-th state
    data=[];
    statelabels=[];
    for k=1:length(allPaths)
        data=[data TrainingSet{k}];
        realPath=allPaths{k}';
        statelabels=[statelabels realPath];
    end
    
    % ii) prepare EM algorithm (EM_pdf_est);
    for j=1:N
        m_ini{j}=Bt{1,j};
        for k=1:length(Bt{2,j})
            s_ini{j}(k)=Bt{2,j}(1,1,k); %covariance matrix is diagonal with
            %identical elements
        end
        w_ini{j}=Bt{3,j};
    end
    % iii) execute EM
    [m_hat,s_hat,w_hat]=EM_pdf_est(data,statelabels,m_ini,s_ini,w_ini);
    % iv) convert EM output format and propagate the result to the next
    % epoch
    for j=1:N
        Bt{1,j}=m_hat{j};
        for k=1:length(s_hat{j})
            Bt{2,j}(:,:,k)=s_hat{j}(k)*eye(size(m_hat{j},1));
        end
        Bt{3,j}=w_hat{j};
    end
    
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
for j=1:N
    BTrained{j}{1}=Bt{1,j};
    BTrained{j}{2}=Bt{2,j};
    BTrained{j}{3}=Bt{3,j};
end
