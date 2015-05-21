% this is a sample file for how to call C8's main function getCC.m
% you can modify this by adding subjects to the Subjects/ directory with
% names of the style of "ColinAtlas" and then adding their names to the
% "aa" cell array.
%
% this file assumes that segmentation and normalization has been done
% (using, e.g. SPM5 - see segNormColin.m).
%
%
% Author: Timothy Herron, tjherron@ebire.org
% Veterans Affairs, 150 Muir Road, MTZ/151, Martinez, CA 94553
% This function is in the public domain.

thisDir='./Subjects/';
aa={'ColinAtlas'};
for p=1:length(aa) 
 str=char(aa(p));
 aain2{p,1}=[thisDir aa{p} '/' aa{p} '256FS.img'];
 aain2{p,2}=[thisDir aa{p} '/wc2' aa{p} '256FS.img'];
 aain2{p,3}=[thisDir aa{p} '/' aa{p} '256FS_sn.mat'];
 aain2{p,4}=[thisDir aa{p} '/w' aa{p} '256FS.img'];
% aain2{p,5}=[thisDir aa{p} '/anat/wOther.nii'];
end
[Thickness2 Area2 clustHg02 T1s2]=getCC(aain2);

for p=1:length(aa) 
 str=char(aa(p));
 aain1{p,1}=[thisDir aa{p} '/' aa{p} '256FS.img'];
 aain1{p,2}=[thisDir aa{p} '/c2' aa{p} '256FS.img'];
 aain1{p,3}=[thisDir aa{p} '/nothing.mat'];
 aain1{p,4}=[thisDir aa{p} '/' aa{p} '256FS.img'];
end
[Thickness1 Area1 clustHg01 T1s1]=getCC(aain1,'thresh=0.6;');
