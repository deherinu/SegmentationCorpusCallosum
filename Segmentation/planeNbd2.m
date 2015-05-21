function [nbd,dst] = planeNbd2(Hg,H)
% function [nbd,dst] = planeNbd2(Hg,H)
%
% outputs indices for all 8 nearest neighbors 
% (self, then 4 edge nbrs, then 4 point nbrs)
% of every point in a 2D slice, wrapping
% around the ends just for fun (and ease of use)
%
% Author: Timothy Herron, tjherron@ebire.org
% Veterans Affairs, 150 Muir Road, MTZ/151, Martinez, CA 94553
% This function is in the public domain.

pd=[size(Hg,1),size(Hg,2)];
nbd=(1:prod(pd))';
% edge nbrs top to bottom and left to right
nbd(:,2)=nbd(:,1)-1+pd(1)*double(mod(nbd(:,1)-1,pd(1))==0);
nbd(:,3)=nbd(:,1)-pd(1)+prod(pd)*double(nbd(:,1)<=pd(1));
nbd(:,4)=nbd(:,1)+pd(1)-prod(pd)*double(nbd(:,1)>(pd(1)*(pd(2)-1)));
nbd(:,5)=nbd(:,1)+1-pd(1)*double(mod(nbd(:,1),pd(1))==0);
% same for the pt nbrs
nbd(:,6)=nbd(:,2)-pd(1)+prod(pd)*double(nbd(:,2)<=pd(1));
nbd(:,7)=nbd(:,2)+pd(1)-prod(pd)*double(nbd(:,2)>(pd(1)*(pd(2)-1)));
nbd(:,8)=nbd(:,5)-pd(1)+prod(pd)*double(nbd(:,5)<=pd(1));
nbd(:,9)=nbd(:,5)+pd(1)-prod(pd)*double(nbd(:,5)>(pd(1)*(pd(2)-1)));
% then the distances
dst=ones(prod(pd),1)*[0 H(1) H(2) H(2) H(1) ones(1,4)*sqrt(sum(H.^2))];