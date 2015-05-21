function [line,slice,Xg,Yg] = extractLines(I,H,slice,center,angle,len,spacing)
% function [line,slice] = extractLines(I,H,slice,center,angle,len,spacing)
%
% I,H     - as in imgRead, etc
% slice   - 2 vector of (dim,loc) where loc is in mm
% center  - in mm^3
% angle   - in [-pi,pi]
% len     - in mm
% spacing - in mm
%
% Author: Timothy Herron, tjherron@ebire.org
% Veterans Affairs, 150 Muir Road, MTZ/151, Martinez, CA 94553
% This function is in the public domain.

perms=[2 3 1;1 3 2;1 2 3];

% permute slice to 3rd dim
if slice(1)>0
  I = (reshape(I,H(1:3)));
  I = permute(I,perms(slice(1),:));
else
  slice(1)=-slice(1);
end
H(1:3)=H(perms(slice(1),:));
H(4:6)=H(3+perms(slice(1),:));
H(10:12)=H(9+perms(slice(1),:));

% extract slice at any position
slice(2)=slice(2)/H(6)+H(12);
sl=[ceil(slice(2)),floor(slice(2))];
uplo=[ceil(slice(2))-slice(2),slice(2)-floor(slice(2))];
if sum(uplo)==0 uplo=[0,1]; end
slice=double(I(:,:,sl(1)))*uplo(2)+double(I(:,:,sl(2)))*uplo(1);

% duplicate singleton inputs to match the multiple one
if size(center,1)>1
   sz=size(center,1);
   angle=repmat(angle,[size(center,1)/size(angle,1) 1]);
elseif size(angle,1)>1
   sz=size(angle,1);
   center=repmat(center,[size(angle,1)/size(center,1) 1]);
else 
   sz=1;
end

% finally we get around to doing something
if len<0
   len=len:spacing:-len;
else
   len=0:spacing:len;
end
sz2=length(len);
Xg=ones(sz2,1)*(center(:,1)+i*center(:,2)).';
Xg=Xg+((len')*ones(1,sz)).*exp(i*ones(sz2,1)*angle.');
Yg=imag(Xg);
Xg=real(Xg);
[Xg0,Yg0]=convMMtoMI(Xg,Yg,H);
line = gridInterp(Xg0,Yg0,slice,2);



function [Xg,Yg]=convMMtoMI(Xg,Yg,H)
%mi=(ones(size(mm,1),1)*H(10:11))+mm./(ones(size(mm,1),1)*H(4:5));
Xg=H(10)+Xg/H(4);
Yg=H(11)+Yg/H(5);

%function mm=convMItoMM(mi,H)
%mm=(mi-ones(size(mi,1),1)*H(10:11)).*(ones(size(mi,1),1)*H(4:5));

