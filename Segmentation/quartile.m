function s=quartile(s,n)
%
% i bet you can guess what value(s) this returns
%
% Author: Timothy Herron, tjherron@ebire.org
% Veterans Affairs, 150 Muir Road, MTZ/151, Martinez, CA 94553
% This function is in the public domain.
if isempty(s) s=0; return; end
sz=size(s);
s=reshape(s,[sz(1) prod(sz(2:end))]);
s=sort(s);
s=(s(max(1,floor(n*sz(1)/4)),:)+s(min(sz(1),ceil(n*sz(1)/4)),:))/2;
s=reshape(s,[1 sz(2:end)]);
   