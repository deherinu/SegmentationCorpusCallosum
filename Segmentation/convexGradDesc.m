function out = convexGradDesc(in,mx,bsn,w,dup)
%
% function out = convexGradDesc(in,mx,bsn,w,dup)
%
% a gradient-direction-controlled gradient descent search for finding the 
% Frechet median under the Frobenius metric for a collection of vectors or 
% matrices of values 
%
% in  - input vectors ([n m l]=size(in) for finding l medians for
%       n sized sets of m-vectors)
% mx  - maximum number of directions to search (scalar)
% bsn - number of bisections to do in each direction
% w   - weights for the median filter (an n vector)
% dup - shortcut for processing symmetric matrices as vector
%
% out - a 1 x m x l matrix of l median m-vectors
%
%
% Author: Timothy Herron, tjherron@ebire.org
% Veterans Affairs, 150 Muir Road, MTZ/151, Martinez, CA 94553
% This function is in the public domain.

if nargin<2
    mx=15;  % # of lines to search in looking for minima
end
if nargin<3
    bsn=5; % # of different locations along a search line to do a bisection search
end
    
% neighbors x vector size x replications 
[n m l] = size(in);
% get rid of funky data
in(isnan(in))=0;
in(isinf(in))=max(in(find(~isinf(in))));
% default weights
if nargin<4
    w=ones(n,1);
end
w=w(:)/sum(w(:));
% flag any duplicate entries for the gradient computation
lop=1:m;
if nargin<5
    dup=[];
else
    lop(dup(2,:))=0;
    lop=lop(lop>0);
end
% get the best neighbor as the initial median candidate
in=real(in);
mvs1=(Es2(in,in(1,:,:),n,l,w));
s=mvs1;
bestsimplex = in(1,:,:);
cnt1=ones(1,m,l);
for p=2:n
    mvs=(Es2(in,in(p,:,:),n,l,w));
    s=s+mvs;
    ind=find(mvs<mvs1);
    mvs1(ind)=mvs(ind);
    bestsimplex(1,:,ind)=in(p,:,ind);
    cnt1(1,:,ind)=1;
    ind=find(mvs==mvs1);
    if ~isempty(ind)
        bestsimplex(1,:,ind)=(cnt1(1,:,ind).*bestsimplex(1,:,ind)+in(p,:,ind))./(cnt1(1,:,ind)+1);
        cnt1(1,:,ind)=cnt1(1,:,ind)+1;
    end 
end
s=squeeze(s);mvs1=squeeze(mvs1); 
s0=(s/n);
s=(s0/mx);
% start the gradient descent
for p=1:mx
   % test out new hull using gradient
   [lastgradient,lowmvs]=getgrad(bestsimplex,in,s,n,m,l,w,lop,dup);
   simplex = bestsimplex - reshape(ones(m,1)*s',[1 m l]).*lastgradient;
   % test the new point and gradient
   domin=logical(ones(size(s))*double(mod(p,3)==0)); % do energy minimization every 3rd time
   cross=logical(zeros(size(s)));
   ind2=logical(zeros(size(s)));
   lows=zeros(size(s));
   highs=s;
   highmvs=lowmvs;
   s1=s;
   % binary search along gradient line for minima
   for q=1:bsn
       % get normalized gradient direction and energy for first point
       [gradient,nowmvs] = getgrad(simplex,in,s,n,m,l,w,lop,dup);
       % have we overshot (or drawn even with) the minima along the line
       % by overshooting the tangent gradient?
       ind=squeeze(sign(sum(gradient.*lastgradient,2))<0);
       if q==2
          % have we failed to cross the tangent gradient and gotten two 
          % increase median energies in a row?  If so then start looking
          % for the minimum energy along the line
          domin=(ind2&(nowmvs>lowmvs)&~cross)|domin;
          cross=cross|domin;
          highmvs(domin)=nowmvs(domin);
          nowmvs(domin)=prevmvs(domin);
          s(domin)=s(domin)/2;
       end
       % see which endpoint energy is lower
       ind(domin)=lowmvs(domin)<highmvs(domin);
       % if you cross the minumum for the first time
       highs(ind&~cross)=s(ind&~cross);
       % if you still haven't crossed the minimum yet
       s(~ind&~cross)=2*s(~ind&~cross);
       % w/ hi + low set, if the gradient is on same side as original
       % or if the high point energy is lower than the low point energy
       lows(~ind&cross)=s(~ind&cross);
       lowmvs(domin&~ind)=nowmvs(domin&~ind);
       s(~ind&cross)=(s(~ind&cross)+highs(~ind&cross))/2;
       % w/ hi + low set, if the gradient is on other side of original
       % or if the low point energy is lower than the high point energy
       highs(ind&cross)=s(ind&cross);
       highmvs(domin&ind)=nowmvs(domin&ind);
       % split the difference in second case
       s(ind)=(s(ind)+lows(ind))/2;
       % update the crossed tracker
       cross=cross|ind;
       % do revision of formula
       simplex = bestsimplex - reshape(ones(m,1)*s',[1 m l]).*lastgradient;
       if q==1
       	% record increased median energy for next time around
        ind2=nowmvs>lowmvs;
       	% save energy for next time around
       	prevmvs=nowmvs;
       end
   end
   % store the gradient of the test vector
   mvs=squeeze(Es2(in,simplex,n,l,w));
   % only replace current answer w/ better (=lower median energy) ones 
   % [except on first go around in order to fight energy seams]
   ind=(mvs<mvs1)|logical(double(p==1)*ones(size(mvs)));
   % and quit if none were replaced this loop
   if isempty(find(ind))&(p>3)
           break; 
   end
   mvs1(ind)=mvs(ind);
   bestsimplex(1,:,ind)=simplex(1,:,ind);
   % try a different tactic for ones where nothing worked
   %
   % when we were looking for the lowest energy - look farther out
   s(~ind&domin)=s1(~ind&domin)*4;
   % when we found a gradient direction turn, try smaller steps
   s(~ind&~domin)=s1(~ind&~domin)/8;
end
% out
out=bestsimplex;


function [gradient,fixedEs]=getgrad(simplex,in,s,n,m,l,w,lop,dup)
s = reshape(s(:),[1 1 l])/100;
fixedEs = Es2(in,simplex,n,l,w);
gradient = zeros(1,m,l);
for p=lop
    newsimplex = simplex;
    newsimplex(1,p,:) = newsimplex(1,p,:)+s;
    gradient(1,p,:) = (Es2(in,newsimplex,n,l,w)-fixedEs)./s;
end
if prod(size(dup))>0
    gradient(1,dup(2,:),:)=gradient(1,dup(1,:),:);
end
% output the central energy
fixedEs=squeeze(fixedEs);
% normalize the gradient length
ln=sqrt(sum(gradient.^2,2));ln(ln==0)=1;
gradient=gradient./repmat(ln,[1 m 1]);


function out = copyrows(in,n)
out = repmat(in,[n 1 1]);


function value = Es(in,simplex,n,l,w)
value = reshape(w'*squeeze(sqrt(sum((copyrows(simplex,n)-in).^2,2))),[1 1 l]);

