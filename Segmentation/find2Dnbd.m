function [clustHg,cHg]=find2Dnbd(slice,pt,nt,H,thresh)
%
% search out a cluster and it's boundaries in a 2D image
%
% Author: Timothy Herron, tjherron@ebire.org
% Veterans Affairs, 150 Muir Road, MTZ/151, Martinez, CA 94553
% This function is in the public domain.

if nargin<5
   thresh=0;
end

% first, we need to get the cluster

% get the neighborhoods
[nbd,dst] = planeNbd2(slice,H(4:5));
nbd=nbd(:,1:(nt+1));

% then find the cluster
% go to it
clustHg=zeros(size(slice));
cHg=clustHg;
ind2=find(slice>thresh);
cHg(ind2)=-2; % signifies not already visited
r=zeros(size(ind2(:)));
% tackle one cluster of the input pts
tc=size(pt,1);cc=tc;
r(1:tc)=sub2ind(size(slice),pt(:,1),pt(:,2));
% mark out possible cluster numbers
cHg(r(1:tc))=tc:-1:1;
while(cc>0) % while cluster is not fully explored
     rn=nbd(min(find(nbd(:,1)==r(cc))),2:end); % find neighbors
     % mark the boundary values surrounding the cluster
     cHg(rn(cHg(rn)==0))=-1;val=cHg(r(cc));
     % find and mark the members of a cluster not already visited
     rn=rn((cHg(rn)<-1)|(cHg(rn)>val));cHg(rn)=val;  
     % then overwrite the current point from the cue with new cluster points
     lrn=length(rn);r(cc:(cc+lrn-1))=rn(:);cc=cc+lrn-1;
end
% mark the cluster and surroundings by its original values
clustHg(cHg>0|cHg==-1)=slice(cHg>0|cHg==-1); 
