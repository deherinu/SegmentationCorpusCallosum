function [orthvecs,polys] = opregset(vec,lev,eo)
% [orthvecs,polys] = opregset(vec,lev,eo)
% 
% the setup routine for doing orthogonal 
% polynomial regression (single variable)
%
% inputs are "vec" the row vector of x
% variables for the regression, and "lev"
% the highest order polynomial on which 
% to do the regression. "eo"=1 indicates
% that the input level is an odd function
% centered around 0 and that the modified
% Gram-Schmidt should take advantage of that
%
% outputs are "orthvecs", the orthogonal
% rows vectors associated with each level
% of polynomial to do regression over,
% and "polys", the orthogonal polynomials
% which will be used in the regression
% (to which we apply the coefficients
% that have been solved for).
%
% The output one gets satisfies the 
% following equation for j=1:(lev+1)
%
% orthovecs(:,j)' = polyval(polys(j,:),vec)
%
% Author: Timothy Herron, tjherron@ebire.org
% Veterans Affairs, 150 Muir Road, MTZ/151, Martinez, CA 94553
% This function is in the public domain.

% initialize the monomial vectors
% of every level
if (nargin<2)
   lev = 1;
else   
   lev = max(lev,1);
end
if (nargin<3)
   eo=0;
end
xpts = zeros(length(vec),lev+1);
xpts(:,1) = ones(length(vec),1);
xpts(:,2) = vec';
for p=2:lev
   xpts(:,p+1) = xpts(:,p).*xpts(:,2);
end

% do Gram-Schmidt to orthogonalize
[orthvecs,rec] = mgso(xpts,eo);

% convert the recursion coefficients
% into polynomial coefficients
polys = eye(lev+1);
for p=1:(lev+1)
   if (p>1)
      polys(p,:) = polys(p,:)-(rec(p,1:(p-1))*polys(1:(p-1),:));
   end
   polys(p,:) = polys(p,:)/rec(1,p);
end
polys = fliplr(polys);