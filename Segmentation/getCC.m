function [Thickness,Area,clustHg0,Aux1,Aux2]=getCC(sub,changes)
% [Thickness,Area,clustHg0,Aux1,Aux2]=getCC(sub,changes)
%
% get yourself some CC measurements from MNI affine normalized WM
% segmenetations that are in NIFTI or Analyze format.
%
% sub - an n x 3 (or n x 4 or n x 5) sized cell array of file
%       names specifying the required (and optional) files
%       that C8 uses to make callosal measurements on n #s of subjects.
%       a) sub{n,1} contains the original T1 image name (*.nii or *.img)
%       b) sub{n,2} contains the normalized, segmented WM image name
%       c) sub{n,3} contains the affine normalization .mat file name
%          with the affine matrix variable 'M' or 'Affine'
%          (the output _sn.mat from SPM5, SPM2, etc works fine)
%       d) sub{n,4} an optional filename specifying a file coregistered
%          to the file in sub{n,2} whose CC values will be sampled
%       e) sub{n,5}  an 2nd optional filename specifying a file coregistered
%          to the file in sub{n,2} whose CC values will be sampled
%
% Thickness - Structure containing CC thickness measurements of various
%             types
% Area      - Structure containing CC thickness measurements of various
%             types
% clustHg0  - 2D file of image values specifying CC location and boundary
% Aux1      - CC values from optional coregistered image #1 (sub{n,4})
% Aux2      - CC values from optional coregistered image #2 (sub{n,5})
%
% Some parameters you can change with the 'changes' 
%
% thisDir=pwd;       % directory to operate in
% thresh=0.55;       % threshold that defines a connected CC component
% downthresh=0.4;    % get WM segmentation lower threshold that defines clusters of 
%                    % the non-boundary portion of the CC
% numclust=1;        % number of clusters of the CC to look for (ideally)
%                    % WM segmentation threshold to look for more CC clusters
% minlen=59;         % minimum Ant-Pos (MNI y) length of CC so as not to reduce the 
%                    % distance in mm to look for CC away from midline - will compute
% sidesl=1;          % 2*sidesl+1 CC cross-sections 1 is normal
% stand=50;          % Number of thickness, etc to output in standard coordinates
% ybox=[-52,42];     % coordinates of box that usually contains the CC in MNI space - used to
% zbox=[-8,40];      % extract CC clusters when the CC is in more clusters than expected
% MNIrot=0;          % should we rotate the CC out of MNI space to make it lie flat?
% AuxFilt=1;         % should we linearly detrend the auxiliary image values?
% pureCoM=0;         % use alternative centroids for angle defs - pure center of mass
% safeCentroid=0;    % center of mass y and mean of genu splenium minimum in z
% centerFixed=0;     % centroid of angle sweep a fixed MNI point [y,z]=CCcenter
% CCcenter=[-4,10];  % default MNI [y,z] center for unwrapping
%
% Author: Timothy Herron, tjherron@ebire.org
% Veterans Affairs, 150 Muir Road, MTZ/151, Martinez, CA 94553
% This function is in the public domain.

% starting parameters
thisDir=pwd;       % directory to operate in
thresh=0.55;       % threshold that defines a connected CC component
downthresh=0.4;    % get WM segmentation lower threshold that defines clusters of 
                   % the non-boundary portion of the CC
numclust=1;        % number of clusters of the CC to look for (ideally)
                   % WM segmentation threshold to look for more CC clusters
minlen=59;         % minimum Ant-Pos (MNI y) length of CC so as not to reduce the 
                   % distance in mm to look for CC away from midline - will compute
sidesl=1;          % 2*sidesl+1 CC cross-sections 1 is normal
stand=50;          % Number of thickness, etc to output in standard coordinates
ybox=[-52,42];     % coordinates of box that usually contains the CC in MNI space - used to
zbox=[-8,40];      % extract CC clusters when the CC is in more clusters than expected
MNIrot=0;          % should we rotate the CC out of MNI space to make it lie flat?
AuxFilt=1;         % should we linearly detrend the auxiliary image values?
pureCoM=0;         % use alternative centroids for angle defs - pure centoer of mass
safeCentroid=0;    % center of mass x and mean of genu splenium minimum
centerFixed=0;     % centroid of angle sweep a fixed MNI point [y,z]=CCcenter
CCcenter=[-4,10];  % default MNI [y,z] center for unwrapping
% any changes?
if nargin>1
   eval(changes);
end   
thresh=repmat(thresh,[1 size(sub,1)]);
if ~isempty(findstr('\',thisDir)) slash='\'; else slash='/'; end

% any optional files to process?
if nargout>3&size(sub,2)>3 doAux1=logical(1); else doAux1=logical(0); end
if nargout>4&size(sub,2)>4 doAux2=logical(1); else doAux2=logical(0); end

% initialize output variables
Thickness=initThick(sub,stand);
Area=initArea(sub);
%
if doAux1
   Aux1=initAux(sub,stand);
   if doAux2 
       Aux2=initAux(sub,stand);
   end
end
%
% cycle through all subjects
for z=1:size(sub,1)
   
% get the normalized image's white matter part
% first, get the WMimage from the disk
  orighdr=load_nii_hdr(sub{z,1});
  HO0=[orighdr.dime.dim(2:4),abs(orighdr.dime.pixdim(2:4))];
  nii=load_nii(sub{z,2});
  H=[nii.hdr.dime.dim(2:4),abs(nii.hdr.dime.pixdim(2:4)),1, ...
     nii.hdr.dime.datatype,0,nii.hdr.hist.originator(1:3)];
  D=nii.hdr.hist.descrip;
  % convert to actual values (0-1)
  I=double(nii.img);%*H(7);
  if MNIrot
     % if you insist in leveling out the CC rather than working in pure MNI space
     ang=-12/80;y00=-2;z00=+1;
    for pp=1:H(1)
      I(pp,:,:)=reshape(PolarScaleTranslate(squeeze(I(pp,:,:)),[1 ang H(11) H(12)],[1 1],[y00 z00],1),[1 H(2) H(3)]);
    end
     % set the angled rays from the center
     angle2=linspace(-1.5*pi/8,9.5*pi/8,150)';
  else      
     % just do computations in MNI space so that Y=Ant-Pos axis
     % set the angled rays from the center at ~1.65 degree spacing
     angle2=linspace(-2*pi/8,9*pi/8,150)';
  end
        
% make sure WM fibers could be in the x direction (up to 45 degs away from y/z axis)
nbdawy=2;pawy=0.33;
I0=reshape(I,H(1:3));
I1=bloat(I0>pawy,5);
I2=double(bloat(I1,5));I1=double(I1);
I0=ones(size(I0));
for xes=(1+nbdawy):(H(1)-nbdawy)
   I0(xes,:,:)=I2(xes-2,:,:).*I1(xes-1,:,:).*I2(xes+2,:,:).*I1(xes+1,:,:);
end
clear I2;
I1=I;
I1(I0==0)=0;clear I0;
% throw away outer parts of files to save memory and time
[I1,H1]=pruneOuter(I1,H,sidesl);
[I,H]=pruneOuter(I,H,sidesl);

% get other data to sample, if so desired, and pare it back laterally
if doAux1
  % get the auxilliary coregistered file #1
  [IAux1,HAux1,DAux1,mvsAux1]=getAuxFile(sub,4,z,angle2,sidesl,AuxFilt,thisDir);
  [IAux1,HAux1]=pruneOuter(reshape(IAux1,HAux1(1:3)),HAux1,sidesl);
     if doAux2
       % get the auxilliary coregistered file #2
       [IAux2,HAux2,DAux2,mvsAux2]=getAuxFile(sub,5,z,angle2,sidesl,AuxFilt,thisDir);
       [IAux2,HAux2]=pruneOuter(reshape(IAux2,HAux2(1:3)),HAux2,sidesl);
     end
end

% get normalization parameters and get affine scaling values
clear Affine;clear M;clear VG;
load([sub{z,3}]);
if ~exist('Affine','var') Affine=M; end
if exist('VG','var')&isfield(VG,'mat') TmpH=abs(diag(VG.mat)); else TmpH=ones(4,1); end; TmpH=TmpH(1:3);
if exist('VF','var')&isfield(VF,'mat') TmpI=abs(VF.mat(1:3,1:3)); else TmpI=eye(3); end;
WOexp=diag(HO0(4:6))*(TmpI*Affine(1:3,1:3))*diag(1./(TmpH(:)'));

% some initialization of median line values on the unwrapped CC
mvs=zeros(length(angle2),3,2*sidesl+1);
mvsO=zeros(length(angle2),3,2*sidesl+1);
Xmvs=zeros(length(angle2),3,2*sidesl+1);
Ymvs=zeros(length(angle2),3,2*sidesl+1);


% measure CC along midline and nearby cross-sections for robustness
for xslice=-sidesl:sidesl

% readjust the threshold to assure clustering
thresh(z)=max(thresh(z),downthresh);
% drop lines starting from (xslice,-40:tsp:34,45) in order to find
% CC clusters assuming that CC is in a very roughly MNI position
slce=[1 xslice];
tsp=8;
center=[(-40:tsp:34)',ones(1+floor(74/tsp),1)*45]+0.5;
angle=-pi/2;
len=40;
spacing=1.9;
[line,slice,Xg,Yg] = extractLines(I1,H,slce,center,angle,len,spacing);
[nothin,slice2] = extractLines(I,H,slce,center,angle,len,spacing);clear nothin;
if doAux1
   [lineAux1,sliceAux1,XgAux1,YgAux1] = extractLines(IAux1,HAux1,slce,center,angle,len,spacing);
   if doAux2
      [lineAux2,sliceAux2,XgAux2,YgAux2] = extractLines(IAux2,HAux2,slce,center,angle,len,spacing);
   end   
end
% find the maximal value to use as c.c. cluster seed pt
[mm,miy]=max(line);
mix=find(mm>thresh(z));
if size(mix(:),1)<2
  mix=find(mm>median(mm));
end
miy=miy(mix);
mix=mix(:);miy=miy(:);
%pt=[H(11)+center(1,1)/H(5)+(mix-1)*tsp/spacing,H(12)+center(1,2)/H(6)-(miy-1)];
pt=[H(11)+center(mix,1)/H(5),H(12)+(center(mix,2)-(miy-1)*spacing)/H(6)];

% find the c.c. cluster(s) and the cluster(s) boundary(ies)
br=0;
while (thresh(z)>=downthresh)
   [clustHg,cHg]=find2Dnbd(slice,round(pt),8,H([1:3 5,6]),thresh(z));
   % add in below threshold points at the edge
   clustHg((cHg>0|cHg==-1)&slice==0)=slice2((cHg>0|cHg==-1)&slice==0); 
   % solidify the interior to be prob=1
   cHg0=logical(zeros(size(cHg)));cHg0(cHg==-1)=logical(1);
   cHg0=bloat(permute(repmat(cHg0,[1 1 3]),[3 1 2]),5);
   clustHg(cHg>0&permute(cHg0(2,:,:),[2 3 1])==0)=1;
   % and force the next-to-boundary layer be at least 0.5
   clustHg(cHg>0)=max(0.5,clustHg(cHg>0));
   % try to make sure that a single cluster is long enough to be the c.c. (Ant-Pos)
   for qq=1:max(cHg(:))
      cHg0=zeros(size(cHg));
      cHg0(cHg==qq)=1;%cHg(cHg==qq)/qq;
      [ACCT(qq),PCCT(qq)]=getACCPCC(cHg0,H,0.1);
      % if big enough, then stop
      if ((max(ACCT)-min(PCCT))>minlen)&(qq<=numclust) br=1; break; end
   end
   if br break; end
   % else we lower clustering threshold and try again
   thresh(z)=thresh(z)-0.025;
end
% if we never found a big enough clusters then use predefined box
if br==0 
   yb=round((ybox/H(5))+H(11));
   zb=round((zbox/H(6))+H(12));
   PCCT=round(min(PCCT)/H(5)+H(11));
   ACCT=round(max(ACCT)/H(5)+H(11));
   clustHg(min(PCCT,yb(1)):max(ACCT,yb(2)),(zb(1)):(zb(2)))=max(...
   clustHg(min(PCCT,yb(1)):max(ACCT,yb(2)),(zb(1)):(zb(2))),...
   slice(min(PCCT,yb(1)):max(ACCT,yb(2)),(zb(1)):(zb(2))));
end

% get rid of fornix if we see a gap (clear minima) in the CC cluster values
% assuming that the CC is superior and generally larger 
Zees=(1:H(3))*H(6)-H(12);numdely=0;
for p=round((CCcenter(1)-24)/H(5)+H(11)):round((CCcenter(1)+10)/H(5)+H(11))
   [clloc,mnt]=cluster1D((cHg(p,:)>=1|cHg(p,:)==1)');
   if length(mnt)==3 
       clloc(clloc==2)=1; clloc(clloc==3)=2;
       mnt(2)=sum(mnt(2:3));mnt=mnt(1:2);
   end
   if length(mnt)==2
      mn2clc=min(find(clloc==2));mx1clc=max(find(clloc==1));mn1clc=min(find(clloc==1));
      if (sum(clustHg(p,clloc==2))*(1.0+numdely*0.05)>sum(clustHg(p,clloc==1)))|...
         ((mn2clc-mx1clc)*H(6)>6&min(Zees(clloc==1))<(CCcenter(2)+5))
         cHg(p,clloc==1)=0;clustHg(p,clloc==1)=0; % kill lower center
         idclc=cHg(p,:)==-1;idclc((mx1clc+2):end)=0;
         cHg(p,idclc)=0;clustHg(p,idclc)=0; % kill lower boundaries
         idclc=cHg(p+1,:)==-1;idclc((mx1clc+2):end)=0;idclc(1:(mn1clc-2))=0;
         cHg(p+1,idclc)=0;clustHg(p+1,idclc)=0; % kill eastern boundaries
         numdely=numdely+1;
         % kill down back diagonal on first detection
         if numdely==1
             ffx=max(find(clloc==1))-1;ffn=min(find(clloc==1))-1;
             for p0p=1:(ffx-ffn)
                 cHg(p-p0p,(ffn-1):(ffx-p0p))=0;clustHg(p-p0p,(ffn-1):(ffx-p0p))=0;
             end
         end
      end
   end   
end

% isolate the c.c. segmentation values
Iclst=zeros(size(I));
Iclst(ceil(H(10)+xslice/H(4)),:,:)=reshape(clustHg,[1 H(2) H(3)]);
Iclst(floor(H(10)+xslice/H(4)),:,:)=reshape(clustHg,[1 H(2) H(3)]);
% isolate the c.c. boundary values
Ilayr=zeros(size(I));
cHg0=zeros(size(cHg));
cHg0(cHg==-1)=-1;
Ilayr(ceil(H(10)+xslice/H(4)),:,:)=reshape(cHg0,[1 H(2) H(3)]);
Ilayr(floor(H(10)+xslice/H(4)),:,:)=reshape(cHg0,[1 H(2) H(3)]);
% save for area computation
clustHgA(:,:,xslice+sidesl+1)=clustHg;
cHgA(:,:,xslice+sidesl+1)=cHg;
% save the auxilliary values, too
if doAux1
 Aux10(:,:,xslice+sidesl+1)=sliceAux1;
 if doAux2
  Aux20(:,:,xslice+sidesl+1)=sliceAux2;
 end 
end

% go from c.c.'s center axis and fan lines to the inner c.c. surface every 2 degrees
%
% first, pick out the centroid of the fan
center2=CCcenter; % start out safe
if ~centerFixed
 x0x=repmat(H(5)*((1:H(2))-H(11))',[1 H(3)]);
 y0y=repmat(H(6)*((1:H(3))-H(12)),[H(2) 1]);
 x00=sum(x0x(:).*clustHg(:))/sum(clustHg(:)); % center of mass y
 y00=sum(y0y(:).*clustHg(:))/sum(clustHg(:)); % center of mass z
 y03=mean([max(y0y(clustHg>0)),min(y0y(clustHg>0))]);  % midpoint of anterior and posterior
 y02=mean([min(y0y(clustHg>0&x0x>x00)),min(y0y(clustHg>0&x0x<x00))]);  % midpoint of splenium and genu z coord
 y01=max([min(y0y(clustHg>0&x0x>x00)),min(y0y(clustHg>0&x0x<x00))]);   % go up to splenium for better centroid
 center23=round([x00,y00]);
 center22=round([x00,y02]);
 if ~isempty(y00)
    center2=round([mean([min(PCCT),max(ACCT)]),min(y01,y00)]); % midpoint of ACC+PCC
 else
    center2=round([mean([min(PCCT),max(ACCT)]),min(y01,y03)]); % midpoint of ACC+PCC
 end
 if (safeCentroid|(center2(1)<-11)|(center2(1)>5))&~isempty(y02) center2=center22; end
 if pureCoM center2=center23; end
end
len2=60; % length of lines in fan (in mm)
spacing2=1; % spacing in mm
minValSweep=0.75;
protrec=2;    % the values on the ends to skip when measuring thickness
[line2,slice2,Xg2,Yg2] = extractLines(Ilayr,H,slce,center2,angle2,len2,spacing2);
[line2C,slice2C,Xg2C,Yg2C] = extractLines(Iclst,H,slce,center2,angle2,len2,spacing2);
% determine the maximum and minimum intersecting ray
afc=[10,10,10];       % minimum distance to look for CC inner surface
mxr=max(find(sum(line2C(afc(1):end,:))>minValSweep));
mnr=min(find(sum(line2C(afc(1):end,:))>minValSweep));
% get rid of fornix/etc if we see a gap (clear minima) in the CC cluster values
for p=(mnr+protrec+10):(mxr-protrec-10)
   [clloc,mnt]=cluster1D(line2C(:,p)>=thresh(z));
   if length(mnt)>1
      if prod(double((mnt(end)/0.75)>mnt(1:(end-1))))==1
         line2C(clloc<length(mnt),p)=0;
      end
   end   
end
% extract auxiliary file values
if doAux1
   IclstAux1=zeros(size(I));
   IclstAux1(ceil(H(10)+xslice/H(4)),:,:)=reshape(sliceAux1,[1 H(2) H(3)]);
   IclstAux1(floor(H(10)+xslice/H(4)),:,:)=reshape(sliceAux1,[1 H(2) H(3)]);
   [line2Aux1,slice2Aux1,Xg2Aux1,Yg2Aux1] = extractLines(IclstAux1,H,slce,center2,angle2,len2,spacing2);
   if doAux2
   	IclstAux2=zeros(size(I));
   	IclstAux2(ceil(H(10)+xslice/H(4)),:,:)=reshape(sliceAux2,[1 H(2) H(3)]);
   	IclstAux2(floor(H(10)+xslice/H(4)),:,:)=reshape(sliceAux2,[1 H(2) H(3)]);
   	[line2Aux2,slice2Aux2,Xg2Aux2,Yg2Aux2] = extractLines(IclstAux2,H,slce,center2,angle2,len2,spacing2);
   end   
end

% plots to keep us amused
figure(854);
subplot(2,2,1);
image(flipud(clustHg'*50));title(z);
axis([H(11)+ybox/H(5),H(12)+zbox/H(6)]);axis equal
subplot(2,2,2);
cHg(round(center2(1)/H(5))+H(11),round(center2(2)/H(6))+H(12))=-0.50;
cHg(round(center22(1)/H(5))+H(11),round(center22(2)/H(6))+H(12))=-0.33;
cHg(round(center23(1)/H(5))+H(11),round(center23(2)/H(6))+H(12))=-0.17;
image(flipud(-cHg'*50));title(xslice);
subplot(2,2,3);
image(flipud(fliplr(-line2*50)));title(mxr-mnr);

% take the rays one by one and determine the minimum crossing distance
sweepang=[15,15,45];
extraang=[0,pi,0];
len3=[16,16,-8];     % length of lines to look for thickness
spacing3=[1,1,1];  % spacing of thickness measurement sampling
mnty=[];
% the following helps speed the program
perms0=[2 3 1;1 3 2;1 2 3];
IclstPerm = permute(reshape(Iclst,H(1:3)),perms0(slce(1),:));
% loop over CC length
for p=(mnr+protrec):(mxr-protrec)
  % loop over outer, inner, and median of CC
   for qq=1:3
    [clloc,mnt]=cluster1D(line2(:,p)<0); % find the clusters of CC boundary values
    if (qq==1)&length(mnt)>1
     % go from the closest CC boundary surface (inferior surface) away from center
     mnt=max(1,min(find(clloc==max(1,length(mnt)-1)))-1);
    elseif (qq==2)&length(mnt)>0
     % do again from the furthest away (superior) boundary back towards center (w/ sweep)
     mnt=min(size(line2,1),max(find(clloc==length(mnt)))+1);
    elseif (qq==3)&length(mnt)>0
     mnt=round(convexGradDesc(repmat((1:size(line2C,1))',[2*protrec+1 1]),7,7,reshape(line2C(:,(p-protrec):(p+protrec)).^2,[size(line2C,1)*(2*protrec+1) 1])));
     if ~isnan(mnt) mnty(p)=mnt;  end
    end 
    if ~isempty(mnt)&~isnan(mnt)
     center3=[Xg2(mnt,p),Yg2(mnt,p)];
     angle3=linspace(extraang(qq)+angle2(p)+pi*sweepang(qq)/180,extraang(qq)+angle2(p)-pi*sweepang(qq)/180,22)';
     [line3,slice3,Xg3,Yg3] = extractLines(IclstPerm,H,[-slce(1) slce(2)],center3,angle3,len3(qq),spacing3(qq));
     mvs(p,qq,xslice+sidesl+1)=min(sum(line3))*spacing3(qq);
     mvsO(p,qq,xslice+sidesl+1)=min(sum(line3).*sqrt(sum((WOexp(:,2:3)*[cos(angle3');sin(angle3')]).^2)))*spacing3(qq);
     Xmvs(p,qq,xslice+sidesl+1)=center3(1);
     Ymvs(p,qq,xslice+sidesl+1)=center3(2);
     if (doAux1)
       ididx11=min(size(line2Aux1,1),max(1,(mnt-double(qq>1)):(mnt+double(qq~=2))));
       ididx22=min(size(line2Aux1,2),max(1,(p-protrec):(p+protrec)));
       mvsAux1(p,qq,xslice+sidesl+1)=mean(mean(line2Aux1(ididx11,ididx22).*line2C(ididx11,ididx22)));
       if doAux2
         ididx11=min(size(line2Aux2,1),max(1,(mnt-double(qq>1)):(mnt+double(qq~=2))));
         ididx22=min(size(line2Aux2,2),max(1,(p-protrec):(p+protrec)));
         mvsAux2(p,qq,xslice+sidesl+1)=mean(mean(line2Aux2(ididx11,ididx22).*line2C(ididx11,ididx22)));
       end
     end
    end
   end
end
lkj=zeros(size(mnty));
% last plot
for p=1:length(mnty) if mnty(p)>0 line2C(mnty(p),p)=2; end; end
figure(854);subplot(2,2,4);
image(flipud(fliplr(line2C*25)));drawnow;
%Thickness.mnty{:,xslice+sidesl+1,z}=int16(mnty(:));
%
if xslice==0
 % get the ACC + PCC
 [ACC,PCC,ACCz,PCCz]=getACCPCC(clustHg,H,0.01);
 % get the ACCI (inner one)
 [ACCI,ACCIp]=max(Xmvs(:,1,xslice+sidesl+1)); 
end
[z,xslice,max(ACCT),min(PCCT)]
end %xslice

% take the median of the multiple saggital measurements
mvsf=squeeze(median(permute(mvs,[3 1 2]),1));
mvsfO=squeeze(median(permute(mvsO,[3 1 2]),1));
clustHg=squeeze(median(permute(clustHgA,[3 1 2]),1));
% extract MNI locations
Xmean=squeeze(median(permute(Xmvs(:,2,:),[3 2 1]),1)); % the outer surface lengths ant-pos
Ymean=squeeze(median(permute(Xmvs(:,3,:),[3 2 1]),1)); % the median surface lengths ant-pos
Zmean=squeeze(median(permute(Ymvs(:,3,:),[3 2 1]),1)); % the mediansurface lengths sup-inf
% figure out where the CC begins and ends by ridding of huge/tiny distance jumps
YZ=[Ymean((mnr+protrec):(mxr-protrec))';Zmean((mnr+protrec):(mxr-protrec))'];
stand3=sqrt(sum((WOexp(:,2:3)*(YZ(:,1:end-1)-YZ(:,2:end))).^2,1));
standx=find(~(stand3>3|stand3<(1/10)));
stind=logical(zeros([length(Ymean) 1]));
stind((min(standx):(max(standx)+1))+mnr+protrec-1)=logical(1);
% equal angle measuring/sampling
stand2=sum(double(stind));%mxr-mnr-2*protrec+1;
for q=1:3
 Thickness.EqualAngle(z,:,q)=interp1(linspace(0,1,stand2),mvsfO(stind,q)',linspace(0,1,stand),'spline');
 Thickness.EqualAngleMNI(z,:,q)=interp1(linspace(0,1,stand2),mvsf(stind,q)',linspace(0,1,stand),'spline');
% Thickness.EqualAngle(z,:,1)=resample(mvsfO(stind,1)',stand,stand2);
end
if doAux1
	mvsfOAux1=squeeze(median(permute(mvsAux1,[3 1 2]),1));
	if doAux2 mvsfOAux2=squeeze(median(permute(mvsAux2,[3 1 2]),1)); end
	for q=1:3
	 Aux1.EqualAngle(z,:,q)=interp1(linspace(0,1,stand2),mvsfOAux1(stind,q)',linspace(0,1,stand),'spline');
	 if doAux2
	   Aux2.EqualAngle(z,:,q)=interp1(linspace(0,1,stand2),mvsfOAux2(stind,q)',linspace(0,1,stand),'spline');
	 end
	end
end
Thickness.EqualAngleyMNI(z,:)=interp1(linspace(0,1,stand2),Ymean(stind)',linspace(0,1,stand),'spline');
Thickness.EqualAnglezMNI(z,:)=interp1(linspace(0,1,stand2),Zmean(stind)',linspace(0,1,stand),'spline');
Thickness.EqualAngletMNI(z,:)=interp1(linspace(0,1,stand2),angle2(stind),linspace(0,1,stand),'spline');
% equal distance model
YZ=[Ymean(stind)';Zmean(stind)'];
stand3=sqrt(sum((WOexp(:,2:3)*(YZ(:,1:end-1)-YZ(:,2:end))).^2,1));stand3(stand3==0)=0.001;
for q=1:3
 Thickness.EqualDist(z,:,q)=interp1([0,cumsum(stand3(:)')],mvsfO(stind,q)',linspace(0,sum(stand3),stand),'spline');
 Thickness.EqualDistMNI(z,:,q)=interp1([0,cumsum(stand3(:)')],mvsf(stind,q)',linspace(0,sum(stand3),stand),'spline');
end
if doAux1
   for q=1:3
    Aux1.EqualDist(z,:,q)=interp1([0,cumsum(stand3(:)')],mvsfOAux1(stind,q)',linspace(0,sum(stand3),stand),'spline');
    if doAux2
       Aux2.EqualDist(z,:,q)=interp1([0,cumsum(stand3(:)')],mvsfOAux2(stind,q)',linspace(0,sum(stand3),stand),'spline');
    end
   end
end
Thickness.EqualDistyMNI(z,:)=interp1([0,cumsum(stand3(:)')],Ymean(stind)',linspace(0,sum(stand3),stand),'spline');
Thickness.EqualDistzMNI(z,:)=interp1([0,cumsum(stand3(:)')],Zmean(stind)',linspace(0,sum(stand3),stand),'spline');
Thickness.EqualDisttMNI(z,:)=interp1([0,cumsum(stand3(:)')],angle2(stind),linspace(0,sum(stand3),stand),'spline');
% equal area sampling
stand4=mvsfO(stind,3);
stand4=stand3(:)'.*mean([stand4(1:end-1)'; stand4(2:end)'],1);stand4(stand4==0)=0.001;
for q=1:3
 Thickness.EqualArea(z,:,q)=interp1([0,cumsum(stand4(:)')],mvsfO(stind,q)',linspace(0,sum(stand4),stand),'spline');
 Thickness.EqualAreaMNI(z,:,q)=interp1([0,cumsum(stand4(:)')],mvsf(stind,q)',linspace(0,sum(stand4),stand),'spline');
end
if doAux1
   for q=1:3
    Aux1.EqualArea(z,:,q)=interp1([0,cumsum(stand4(:)')],mvsfOAux1(stind,q)',linspace(0,sum(stand4),stand),'spline');
    if doAux2
       Aux2.EqualArea(z,:,q)=interp1([0,cumsum(stand4(:)')],mvsfOAux2(stind,q)',linspace(0,sum(stand4),stand),'spline');
    end
   end
end
Thickness.EqualAreayMNI(z,:)=interp1([0,cumsum(stand4(:)')],Ymean(stind)',linspace(0,sum(stand4),stand),'spline');
Thickness.EqualAreazMNI(z,:)=interp1([0,cumsum(stand4(:)')],Zmean(stind)',linspace(0,sum(stand4),stand),'spline');
Thickness.EqualAreatMNI(z,:)=interp1([0,cumsum(stand4(:)')],angle2(stind),linspace(0,sum(stand4),stand),'spline');

% Calculate CC Lengths
xyz9=[repmat(0,[1 stand]);Thickness.EqualAngleyMNI(z,:);Thickness.EqualAnglezMNI(z,:)];
Thickness.LengthMNI(z)=sum(sqrt(sum((xyz9(:,1:(stand-1))-xyz9(:,2:(stand))).^2,1)));
xyz9=WOexp*[repmat(0,[1 stand]);Thickness.EqualAngleyMNI(z,:);Thickness.EqualAnglezMNI(z,:)];
Thickness.Length(z)=sum(sqrt(sum((xyz9(:,1:(stand-1))-xyz9(:,2:(stand))).^2,1)));
Thickness.center(z,:)=center2(:)';

% preliminay partition stuff for doing the 
cnt=(1:size(mvsf,1))';                               % surface length index
ind0=sum(double(mvsf>0)')'>0;                        % places with >0 thickness
XX=H(5)*(repmat(1:H(2),[H(3) 1])'-H(11));
% now figure out an approximate Witelson's partition to do the averages
% get the Witelson thicknesses
 Area.WitelsonBounds(z,1)=ACCI;
 Area.WitelsonBounds(z,2)=ACC;
 Area.WitelsonBounds(z,3)=ACCI;
 Area.WitelsonBounds(z,4)=(2*ACC/3+PCC/3);
 Area.WitelsonBounds(z,5)=(ACC/2+PCC/2);
 Area.WitelsonBounds(z,6)=(ACC/3+2*PCC/3);
 Area.WitelsonBounds(z,7)=(ACC/5+4*PCC/5); 
 Area.WitelsonBounds(z,8)=(PCC); 
% 
for q=2:(size(Area.WitelsonBounds,2)-1)
 if q==2
  ind=ind0&(cnt<=ACCIp(end));
 else   
  ind=ind0&(cnt>ACCIp(end))&(Xmean<Area.WitelsonBounds(z,q))&(Xmean>=Area.WitelsonBounds(z,q+1));
 end 
 Thickness.WitelsonMNI(z,q,:)=reshape(median(mvsf(ind,:),1),[1 1 3]);
 Thickness.Witelson(z,q,:)=reshape(median(mvsfO(ind,:),1),[1 1 3]);
% W(q,:)=median(mvsf(ind,:),1);WO(q,:)=median(mvsfO(ind,:),1);
 indXX=(XX<Area.WitelsonBounds(z,q))&(XX>=Area.WitelsonBounds(z,q+1));
 Area.WitelsonMNI(z,q)=sum(clustHg(indXX))*H(5)*H(6);
% WA(q)=sum(clustHg(indXX));
 if doAux1&sum(double(indXX(:)))>0
  indXX=(clustHgA>0)&repmat(indXX,[1 1 2*sidesl+1]);
  Aux1.Witelson(z,q)=mean(Aux10(indXX));
  Aux1.WitelsonMed(z,q)=quartile(Aux10(indXX),2);
  Aux1.WitelsonQuart1(z,q)=quartile(Aux10(indXX),1);
  Aux1.WitelsonQuart3(z,q)=quartile(Aux10(indXX),3);
  if doAux2
  	Aux2.Witelson(z,q)=mean(Aux20(indXX));
  	Aux2.WitelsonMed(z,q)=quartile(Aux20(indXX),2);
  	Aux2.WitelsonQuart1(z,q)=quartile(Aux20(indXX),1);
  	Aux2.WitelsonQuart3(z,q)=quartile(Aux20(indXX),3);
  end
 end
end
% compute in native space
Area.Witelson(z,:)=Area.WitelsonMNI(z,:)*prod(sqrt(sum(WOexp(:,2:3).^2)));
%Area.Witelson(z,:)=Area.WitelsonMNI(z,:)*prod((sum(WOexp(:,2:3))));

% now figure out an approximate Hofer's partition to do the averages
Area.HoferBounds(z,1)=ACC;
Area.HoferBounds(z,2)=5*ACC/6+PCC/6;
Area.HoferBounds(z,3)=ACC/2+PCC/2;
Area.HoferBounds(z,4)=ACC/3+2*PCC/3;
Area.HoferBounds(z,5)=ACC/4+3*PCC/4;
Area.HoferBounds(z,6)=PCC;
%
for q=1:(size(Area.HoferBounds,2)-1)
 ind=ind0&(Xmean<Area.HoferBounds(z,q))&(Xmean>=Area.HoferBounds(z,q+1));
 Thickness.HoferMNI(z,q,:)=reshape(median(mvsf(ind,:),1),[1 1 3]);
 Thickness.Hofer(z,q,:)=reshape(median(mvsfO(ind,:),1),[1 1 3]);
% HH(q,:)=median(mvsf(ind,:),1);HO(q,:)=median(mvsfO(ind,:),1);
 indXX=(XX<Area.HoferBounds(z,q))&(XX>=Area.HoferBounds(z,q+1));
 Area.HoferMNI(z,q)=sum(clustHg(indXX))*H(5)*H(6);
% HA(q)=sum(clustHg(indXX));
 if doAux1
  indXX=(clustHgA>0)&repmat(indXX,[1 1 2*sidesl+1]);
  Aux1.Hofer(z,q)=mean(Aux10(indXX));
  Aux1.HoferMed(z,q)=quartile(Aux10(indXX),2);
  Aux1.HoferQuart1(z,q)=quartile(Aux10(indXX),1);
  Aux1.HoferQuart3(z,q)=quartile(Aux10(indXX),3);
  if doAux2
  	Aux2.Hofer(z,q)=mean(Aux20(indXX));
  	Aux2.HoferMed(z,q)=quartile(Aux20(indXX),2);
  	Aux2.HoferQuart1(z,q)=quartile(Aux20(indXX),1);
  	Aux2.HoferQuart3(z,q)=quartile(Aux20(indXX),3);
  end
 end
end
% compute in native space
 Area.Hofer(z,:)=Area.HoferMNI(z,:)*prod(sqrt(sum(WOexp(:,2:3).^2)));;
% Area.Hofer(z,:)=Area.HoferMNI(z,:)*prod((sum(WOexp(:,2:3))));;
 

% now figure out an approximate Chao's partition to do the averages
Area.ChaoBounds(z,1)=ACC;
Area.ChaoBounds(z,2)=2*ACC/3+PCC/3;
Area.ChaoBounds(z,3)=ACC/3+2*PCC/3;
Area.ChaoBounds(z,4)=ACC/4+3*PCC/4;
Area.ChaoBounds(z,5)=ACC/6+5*PCC/6;
Area.ChaoBounds(z,6)=PCC;
%
for q=1:(size(Area.ChaoBounds,2)-1)
 ind=ind0&(Xmean<Area.ChaoBounds(z,q))&(Xmean>=Area.ChaoBounds(z,q+1));
 Thickness.ChaoMNI(z,q,:)=reshape(median(mvsf(ind,:),1),[1 1 3]);
 Thickness.Chao(z,q,:)=reshape(median(mvsfO(ind,:),1),[1 1 3]);
% HH(q,:)=median(mvsf(ind,:),1);HO(q,:)=median(mvsfO(ind,:),1);
 indXX=(XX<Area.ChaoBounds(z,q))&(XX>=Area.ChaoBounds(z,q+1));
 Area.ChaoMNI(z,q)=sum(clustHg(indXX))*H(5)*H(6);
% HA(q)=sum(clustHg(indXX));
 if doAux1
  indXX=(clustHgA>0)&repmat(indXX,[1 1 2*sidesl+1]);
  Aux1.Chao(z,q)=mean(Aux10(indXX));
  Aux1.ChaoMed(z,q)=quartile(Aux10(indXX),2);
  Aux1.ChaoQuart1(z,q)=quartile(Aux10(indXX),1);
  Aux1.ChaoQuart3(z,q)=quartile(Aux10(indXX),3);
  if doAux2
  	Aux2.Chao(z,q)=mean(Aux20(indXX));
  	Aux2.ChaoMed(z,q)=quartile(Aux20(indXX),2);
  	Aux2.ChaoQuart1(z,q)=quartile(Aux20(indXX),1);
  	Aux2.ChaoQuart3(z,q)=quartile(Aux20(indXX),3);
  end
 end
end
 % compute in native space
 Area.Chao(z,:)=Area.ChaoMNI(z,:)*prod(sqrt(sum(WOexp(:,2:3).^2)));;
% Area.Chao(z,:)=Area.ChaoMNI(z,:)*prod((sum(WOexp(:,2:3))));;
 
 
 % save clusters for posterity
 if nargout>2
    clustHg0(:,:,:,z,1)=single(clustHgA); % save for out if desired
    clustHg0(:,:,:,z,2)=single(cHgA); % save for out if desired
 end
 Area.ACC(z)=ACC;
 Area.PCC(z)=PCC;
 Area.ACCz(z)=ACCz;
 Area.PCCz(z)=PCCz;
 Area.WOexp(:,:,z)=WOexp;
 Area.Affine(:,:,z)=Affine;

end % z = subjects loop
Thickness.thresh=thresh;







% auxilliary function
function [ACC,PCC,ACCz,PCCz]=getACCPCC(clustHg,H,epsi)
 ACC=0;PCC=0;
 % get the ACC
 [t0,t1]=max(flipud(clustHg>epsi));
 t0=H(2)-min(t1(sum(double(clustHg>epsi))>0))+1;
 [t1,t11]=max(clustHg(t0,:));
 if ~isempty(t0)&~isempty(t1)
 ACC=(t0-H(11))*H(5)-(1-t1)*H(5);
 ACCz=(t11-H(12))*H(6);
 end
 % get the PCC
 [t0,t1]=max(clustHg>epsi);
 t0=min(t1(sum(double(clustHg>epsi))>0));
 [t1,t11]=max(clustHg(t0,:));
 if ~isempty(t0)&~isempty(t1)
 PCC=(t0-H(11))*H(5)+(1-t1)*H(5);
 PCCz=(t11-H(12))*H(6);
 end
 return 
 
% auxilliary function
 function [I2,H2]=pruneOuter(I,H,sidesl);
 up=min(H(10)-1,min(H(1)-H(10),max(2,ceil(sidesl/H(4)))+1));
 I2=I((H(10)-up):(H(10)+up),:,:);
 H2=H;H2(10)=up+1;H2(1)=up*2+1;
 return
 
 
% auxilliary function
 function Aux1=initAux(sub,stand)
   Aux1.EqualAngle=zeros(size(sub,1),stand,3);
   Aux1.EqualDist=zeros(size(sub,1),stand,3);
   Aux1.EqualArea=zeros(size(sub,1),stand,3);
   Aux1.Witelson=zeros(size(sub,1),7);
   Aux1.WitelsonMed=zeros(size(sub,1),7);
   Aux1.WitelsonQuart1=zeros(size(sub,1),7);
   Aux1.WitelsonQuart3=zeros(size(sub,1),7);
   Aux1.Hofer=zeros(size(sub,1),5);
   Aux1.HoferMed=zeros(size(sub,1),5);
   Aux1.HoferQuart1=zeros(size(sub,1),5);
   Aux1.HoferQuart3=zeros(size(sub,1),5);
   Aux1.Chao=zeros(size(sub,1),5);
   Aux1.ChaoMed=zeros(size(sub,1),5);
   Aux1.ChaoQuart1=zeros(size(sub,1),5);
   Aux1.ChaoQuart3=zeros(size(sub,1),5);
   return
   
function Thickness=initThick(sub,stand)
Thickness.EqualAngle=zeros(size(sub,1),stand,3);
Thickness.EqualDist=zeros(size(sub,1),stand,3);
Thickness.EqualArea=zeros(size(sub,1),stand,3);
Thickness.EqualAngleMNI=zeros(size(sub,1),stand,3);
Thickness.EqualDistMNI=zeros(size(sub,1),stand,3);
Thickness.EqualAreaMNI=zeros(size(sub,1),stand,3);
Thickness.EqualAngleyMNI=zeros(size(sub,1),stand);
Thickness.EqualAnglezMNI=zeros(size(sub,1),stand);
Thickness.EqualAngletMNI=zeros(size(sub,1),stand);
Thickness.EqualDistyMNI=zeros(size(sub,1),stand);
Thickness.EqualDistzMNI=zeros(size(sub,1),stand);
Thickness.EqualDisttMNI=zeros(size(sub,1),stand);
Thickness.EqualAreayMNI=zeros(size(sub,1),stand);
Thickness.EqualAreazMNI=zeros(size(sub,1),stand);
Thickness.EqualAreatMNI=zeros(size(sub,1),stand);
Thickness.Witelson=zeros(size(sub,1),7,3);
Thickness.WitelsonMNI=zeros(size(sub,1),7,3);
Thickness.Hofer=zeros(size(sub,1),5,3);
Thickness.HoferMNI=zeros(size(sub,1),5,3);
Thickness.Chao=zeros(size(sub,1),5,3);
Thickness.ChaoMNI=zeros(size(sub,1),5,3);
Thickness.Length=zeros(size(sub,1),1);
Thickness.LengthMNI=zeros(size(sub,1),1);
Thickness.center=zeros(size(sub,1),2);
return

function Area=initArea(sub)
Area.Witelson=zeros(size(sub,1),7);
Area.WitelsonMNI=zeros(size(sub,1),7);
Area.WitelsonBounds=zeros(size(sub,1),8);
Area.Hofer=zeros(size(sub,1),5);
Area.HoferMNI=zeros(size(sub,1),5);
Area.HoferBounds=zeros(size(sub,1),6);
Area.Chao=zeros(size(sub,1),5);
Area.ChaoMNI=zeros(size(sub,1),5);
Area.ChaoBounds=zeros(size(sub,1),6);
Area.WOexp=zeros(3,3,size(sub,1));
Area.Affine=zeros(4,4,size(sub,1));
Area.ACC=zeros(size(sub,1),1);
Area.PCC=zeros(size(sub,1),1);
Area.ACCz=zeros(size(sub,1),1);
Area.PCCz=zeros(size(sub,1),1);
return


function [IAux1,HAux1,DAux1,mvsAux1]=getAuxFile(sub,pos,z,angle2,sidesl,AuxFilt,thisDir)
  if AuxFilt
     % linearly detrend them
     polyFiltImg(sub{z,pos},[thisDir '/tempoy' num2str(z) '.nii'],1,1);
     nii=load_nii([thisDir '/tempoy' num2str(z) '.nii']);
     delete([thisDir '/tempoy' num2str(z) '.nii']);
  else    
     % or not
     nii=load_nii(sub{z,pos});
  end
  nii.img=double(nii.img);
  nii.img(isnan(nii.img)|isinf(nii.img))=0;     
%  iAux1med=median(double(nii.img(nii2.img>0.95)));
  IAux1=double(nii.img(:));%/iAux1med;
  HAux1=[nii.hdr.dime.dim(2:4),abs(nii.hdr.dime.pixdim(2:4)),1,nii.hdr.dime.datatype,0,nii.hdr.hist.originator(1:3)];
  DAux1='';
  mvsAux1=zeros(length(angle2),3,2*sidesl+1);
  return
  
