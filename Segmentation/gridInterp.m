function Fg = gridInterp(Xg,Yg,F,meth)
% function Fg = gridInterp(Xg,Yg,F,meth)
%
% meth = 0 - nearest surrounding quad vertex value
% meth = 1 - average the surrounding quad vertices values 
% meth = 2 - bilinear interp of quad vertex values (default)
% meth = 3 - barycentric weighted mean of surr quad vert vals
%
% Xg,Yg - Matlab matrix index scaled values ([4.3,5.4] will be
%         interpolated by using values F([4:5,5:6]) under "method")
%
%
% Author: Timothy Herron, tjherron@ebire.org
% Veterans Affairs, 150 Muir Road, MTZ/151, Martinez, CA 94553
% This function is in the public domain.

if nargin<4
   meth=2;
end 
% size up F
[x,y]=size(F);
% keep track of out-of-bounds points and replace them with center
idxXY=(Xg<1)|(Xg>x)|(Yg<1)|(Yg>y);
Xg(idxXY)=x/2;
Yg(idxXY)=y/2;
% add some fuzz so there are no points on a grid line
idx=floor(Xg)==Xg;
Xg(idx)=Xg(idx)+randn(size(Xg(idx)))*1e-10;
idx=floor(Yg)==Yg;
Yg(idx)=Yg(idx)+randn(size(Yg(idx)))*1e-10;

% compute surround quad X and Y directions
fXg=floor(Xg(:));cXg=ceil(Xg(:));
X=[fXg,fXg,cXg,cXg];
%X=[floor(Xg(:)),floor(Xg(:)),ceil(Xg(:)),ceil(Xg(:))];
fXg=floor(Yg(:));cXg=ceil(Yg(:));
Y=[fXg,cXg,fXg,cXg];
%Y=[floor(Yg(:)),ceil(Yg(:)),floor(Yg(:)),ceil(Yg(:))];
len=size(X,1);
switch meth
case 0
	% compute distance from each of the quad vertices
   D=sqrt((X-Xg(:)*ones(1,4)).^2+(Y-Yg(:)*ones(1,4)).^2);
   % pick the least one to use
   [m,n]=min(D');
   Fg=F(X(len*(n-1)+(1:len))+(Y(len*(n-1)+(1:len))-1)*x);
case 1
   % just average them all together regardless of distance
   Fg=mean(reshape(F(X(:)+(Y(:)-1)*x),[len 4])')';
case 2
   % bilinear
   D=[X(:,3)-Xg(:),Y(:,2)-Yg(:)];
   Fg=(F(X(:,1)+(Y(:,1)-1)*x).*D(:,1)+F(X(:,3)+(Y(:,3)-1)*x).*(1-D(:,1))).*D(:,2)+...
      (F(X(:,2)+(Y(:,2)-1)*x).*D(:,1)+F(X(:,4)+(Y(:,4)-1)*x).*(1-D(:,1))).*(1-D(:,2));
case 3
   % barycentric
   D=sqrt((X-Xg(:)*ones(1,4)).^2+(Y-Yg(:)*ones(1,4)).^2);
   D=[prod(D(:,[2 3 4]),2),prod(D(:,[1 3 4]),2),prod(D(:,[1 2 4]),2),prod(D(:,[1 2 3]),2)];
   D=D./(sum(D,2)*ones(1,4));
   Fg=F(X(:,1)+(Y(:,1)-1)*x).*D(:,1)+...
      F(X(:,2)+(Y(:,2)-1)*x).*D(:,2)+...
      F(X(:,3)+(Y(:,3)-1)*x).*D(:,3)+...
      F(X(:,4)+(Y(:,4)-1)*x).*D(:,4);
end
Fg=reshape(Fg,size(Xg));
% replace out-of-bounds points w/ 0
Fg(idxXY)=0;