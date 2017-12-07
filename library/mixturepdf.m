function [y]=mixturepdf(m,S,P,X)

% FUNCTION (auxiliary)
%   [y]=mixturepdf(m,S,P,X)
% Computes the value of a pdf that is given as a mixture of normal
% distributions, at a given point.
%
% INPUT ARGUMENTS:
%   m:  lxc matrix, whose columns contain the means of
%       the normal distributions involved in the mixture.
%   S:  lxlxc matrix. S(:,:,i) is the covariance matrix of the i-th
%       normal distribution.
%   P:  c-dimensional vector containing the mixing probabilities for
%       the distributions
%   X:  l-d data point (column vector)
%
% OUTPUT ARGUMENTS:
%   y:  pdf value
%
% (c) 2014 T. Giannakopoulos, A. Pikrakis

[l,c]=size(m); % number of dimensions x number of classes
y=0;
for j=1:c
    y=y+P(j)*mvnpdf(X',m(:,j)',S(:,:,j));
end



