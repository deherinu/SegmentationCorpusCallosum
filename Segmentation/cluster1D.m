function [clustNums,szes]=cluster1D(vals) 
%
% function [clustNums,szes]=cluster1D(vals) 
% takes in a logical "vals" and spits out the "1" clusters
% with ordered labels "clustNums" and their sizes "szes".
%
%
% Author: Timothy Herron, tjherron@ebire.org
% Veterans Affairs, 150 Muir Road, MTZ/151, Martinez, CA 94553
% This function is in the public domain.


%if sum(double(vals))==0 clustNums=zeros(size(vals));szes=[];return; end
[n,m]=size(vals);vals=vals(:)';
chng=[1,find(vals(1:(end-1))~=vals(2:end))+1];
clus=cumsum(double(vals(chng)));
clus(vals(chng)==0)=-clus(vals(chng)==0);
clustNums=zeros(size(vals));
clustNums(chng)=clus;
clustNums=cumsum(clustNums);
szes=[chng(2:end),length(vals)+1]-chng;
szes=szes((2-(vals(1)==1)):2:end);
clustNums=reshape(clustNums,[n m]);
if n>m szes=szes(:); end
