function I = bloat(I,dirs,dims)
%
% puff up a logical 3D image by adding neighbors
%
% Author: Timothy Herron, tjherron@ebire.org
% Veterans Affairs, 150 Muir Road, MTZ/151, Martinez, CA 94553
% This function is in the public domain.

if nargin>2 I=reshape(I,dims); end
[x,y,z]=size(I);
if prod(size(dirs))==1
   if dirs==7
      dirs=zeros(3,3,3);
      dirs([5 11 13 14 15 17 23])=1;
   elseif dirs==27
      dirs=ones(3,3,3);
   elseif dirs==5
      dirs=zeros(3,3,3);
      dirs([5 11 14 17 23])=1;
   elseif dirs==9
      dirs=zeros(3,3,3);
      dirs([2 5 8 11 14 17 20 23 26])=1;
   end
end
I([1 x],:,:)=logical(0);
I(:,[1 y],:)=logical(0);
I(:,:,[1 z])=logical(0);
xd=repmat((-1:1)',[1 size(dirs,2) size(dirs,3)]);xd=xd(find(dirs==1));
yd=repmat(-x:x:x,[size(dirs,1) 1 size(dirs,3)]);yd=yd(find(dirs==1));
zd=repmat(reshape((-x*y:x*y:x*y)',[1 1 3]),[size(dirs,1) size(dirs,2) 1]);zd=zd(find(dirs==1));
xd=xd+yd+zd;
idx=find(I==logical(1));
for p=1:length(xd)
   I(idx+xd(p))=logical(1);
end

