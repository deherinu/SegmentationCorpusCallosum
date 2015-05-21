function [b,c] = mgso(a,eo)
% function [b,c] = mgso(a,eo)
%
% modified gram-schmidt orthonormalization where columns
% are the vectors to preserve, and where we return the coeffs, too
%
% a - columns of functional values you want to orthonormalize w.r.t. each other
% eo - (optional) 1=keep original even odd vectors divided up that way 
%      (1/2 # of computations) while =0 is default routine
%
% b - othonormalized versions of input functional values (in columns)
% c - matrix of coefficients used to do the orthonormalization
% 
% e.g. "x=(1:100)'; [b,c]=gso([ones(size(x)),x,x.^2,x.^3,x.^4,x.^5,x.^6]);"
% returns the orthonormalized 0th - 6th order finite polynomials for
% 100 values (to look at them use "plot(b)").
%
% Author: Timothy Herron, tjherron@ebire.org
% Veterans Affairs, 150 Muir Road, MTZ/151, Martinez, CA 94553
% This function is in the public domain.

if nargin<2 
   eo=0;
end
% measure size of matrix
[m,n]=size(a);
% set coefficient matrix
c=zeros(n,n);b=a;
% loop over all columns
for k=1:n
   % orthog the matrix
   c(k,k) = sqrt(b(:,k)'*b(:,k));
	b(:,k) = b(:,k)/c(k,k);
   for j=(k+1+eo):(eo+1):n
      c(k,j) = b(:,k)'*b(:,j);
      b(:,j) = b(:,j) - b(:,k)*c(k,j);
   end
end 