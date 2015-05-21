function value = Es(in,simplex,n,l,w)
value = reshape(w'*squeeze(sqrt(sum((copyrows(simplex,n)-in).^2,2))),[1 1 l]);

function out = copyrows(in,n)
[a b c] = size(in);
out = reshape(ones(n,1)*in(:)',[n b c]);

