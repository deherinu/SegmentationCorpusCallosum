function polyFiltImg(filein,fileout,lev,levuse)
% function polyFiltImg(filein,fileout,lev,levuse)
%
% removal of low spatial frequencies from an analyze
% format image file using 3D orthonormal polynomials.
%
% filein  - file name of image to cleanup
% fileout - output file name
% lev     - maximum level (order) of polynomials to compute
% levuse  - polynomial orders to use when cleaning image
%           you can also specify 'odd' and 'even' for 'levuse'
%           if you wish to subtract off all purely odd or even
%           polynomial components within an image, respectively.
%           
% For a 3D image, the function uses polynomials with 3
% variables, x, y, and z, to clean low spatial frequencies.
%
% For example, using the zeroth order polynomial just 
% subtracts off the mean of the image
%
% For example, the 1st order polynomials are linear
% combinations of the monomials x, y, z, xy, xz, yz, xyz.
%
% To remove any linear gradient from an image in any of the
% 3 directions of a B0 DWI image, use the function:
% polyFiltImg('B0-DWI.img','cleanB0-DWI.img',1,1);
%
%
% Author: Timothy Herron, tjherron@ebire.org
% Veterans Affairs, 150 Muir Road, MTZ/151, Martinez, CA 94553
% This function is in the public domain.

if nargin<4 levuse=0:lev; end
if ischar(levuse)
   if findstr(levuse,'odd') vec=[0,1:2:lev]; end
   if findstr(levuse,'even') vec=[0:2:lev]; end
   levuse=1:lev;
else
   vec=levuse;
end
if 1%~isempty(findstr(filein,'.nii'))
 nii=load_nii(filein);
% isac=isacode(nii.img(:));
 I=double(nii.img(:));
 H=[nii.hdr.dime.dim(2:4),abs(nii.hdr.dime.pixdim(2:4)),1,nii.hdr.dime.datatype,0,nii.hdr.hist.originator(1:3)];
elseif ~isempty(findstr(filein,'.img'))|~isempty(findstr(filein,'.hdr'))
 [I,H,D]=imgRead(filein);
end
I=reshape(I,H(1:3));
I(isnan(I))=0;
I(isinf(I))=0;
opx=opregset(1:H(1),lev);
opy=opregset(1:H(2),lev);
opz=opregset(1:H(3),lev);
for px=vec
   for py=vec
      for pz=vec
         if sum(double(max([px,py,pz])==levuse))>0
          op3=repmat(opx(:,px+1),[1 H(2:3)]).*repmat(opy(:,py+1)',[H(1) 1 H(3)]).*repmat(permute(opz(:,pz+1),[3 2 1]),[H(1:2) 1]);
          I=I-sum(sum(sum(I.*op3)))*op3;
         end
      end
   end
end
if 1%~isempty(findstr(fileout,'.nii'))
% eval(['nii.img=' isac '(I);']);
 nii.img=I;
% nii.hdr.dime.datatype=64;
% nii.hdr.dime.bitpix=64;
 save_nii(nii,fileout);
elseif ~isempty(findstr(fileout,'.img'))|~isempty(findstr(fileout,'.hdr'))
 imgSave('.',fileout,I,H,D);
end