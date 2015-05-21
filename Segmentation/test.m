original_image = load_nii('Subjects/sujeto20/T1.nii.gz');
imageFreeSurfer = load_nii('Subjects/sujeto20/CCSeg_freesurfer_20.nii.gz');

% Get median sagital image
image = squeeze(original_image.img(128,:,:,1));
image = image';
image = imrotate(image,180);
D1 = regionprops(image3, 'area', 'perimeter', 'BoundingBox', 'Centroid', 'Eccentricity', 'MajorAxisLength', 'MinorAxisLength', 'Orientation');
figure
imshow(image(103:132,85:159));
%figure;
%imshow(image);
%E = entropyfilt(image);
%E = entropyfilt(histeq(image(104:131,86:158)));
E = entropyfilt(image(103:133,85:159), true(3));
E2 = stdfilt(image(103:133,85:159), ones(3));
E3 = rangefilt(image(103:133,85:159));
Eim = mat2gray(E);
figure;
imshow(Eim);
figure;
imshow(E2);
figure;
imshow(E3);
%BW1 = imcomplement(im2bw(Eim, .8));
BW1 = im2bw(Eim, .8);
figure, imshow(imcomplement(BW1));
E3 = mat2gray(E3);
E3final = im2bw(E3, .7);
se = strel('disk',2);
figure, imshow(imclose(E3final, se));

% [~, threshold] = edge(image(103:133,85:159), 'sobel');
% fudgeFactor = .5;
% sobelA = edge(image(103:133,85:159),'sobel', threshold * fudgeFactor);
% figure, imshow(sobelA);
% se90 = strel('line', 3, 90);
% se0 = strel('line', 3, 0);
% sobelB = imdilate(sobelA, [se90 se0]);
% imshow(sobelB);
% sobelC = imfill(sobelB, 'holes');
% imshow(sobelC);
% sobelD = imclearborder(sobelC, 4);
% imshow(sobelD);
% seD = strel('diamond',1);
% sobelFinal = imerode(sobelD,seD);
% sobelFinal = imerode(sobelFinal,seD);
% imshow(sobelFinal);

freesurfer_segmentation_image = load_nii('Subjects/sujeto20/CCSeg_freesurfer_20.nii.gz');
% Get median sagital image
image2 = squeeze(freesurfer_segmentation_image.img(128,:,:,1));
image2 = image2';
image2 = imrotate(image2,180);
%figure;
%imshow(image2);
%image3 = bwperim(image2);
%figure;
%imshow(image3);




vale1 = imclearborder(imcomplement(BW1), 4);
vale2 = imerode(vale1,seD);
imshow(vale2)
vale3 = imdilate(vale1,seD);
imshow(vale3)
vale2 = imerode(vale1,seD);
imshow(vale3)
imshow(vale2)
vale2 = imerode(vale2,seD);
imshow(vale2)
vale3 = imdilate(vale2,seD);
imshow(vale3)
vale3 = imdilate(vale3,seD);
imshow(vale3)
vale2 = imerode(vale1,seD);
imshow(vale2)
vale3 = imdilate(vale2,seD);
imshow(vale3)
vale2 = imerode(vale1,seD);
imshow(vale2)
vale2 = bwareaopen(vale2,4);
imshow(vale2)
vale3 = imdilate(vale2,seD);
imshow(vale3)
imshow(vale2)
seD = strel('cirle',1);
Error using strel>ParseInputs (line 1219)
Expected input number 1, STREL_TYPE, to match one of these strings:

'arbitrary', 'square', 'diamond', 'rectangle', 'octagon', 'line', 'pair', 'periodicline',
'disk', 'ball'

The input, 'cirle', did not match any of the valid strings.

Error in strel (line 147)
                [type,params] = ParseInputs(varargin{:});
 
seD = strel('cirle',1);
Error using strel>ParseInputs (line 1219)
Expected input number 1, STREL_TYPE, to match one of these strings:

'arbitrary', 'square', 'diamond', 'rectangle', 'octagon', 'line', 'pair', 'periodicline',
'disk', 'ball'

The input, 'cirle', did not match any of the valid strings.

Error in strel (line 147)
                [type,params] = ParseInputs(varargin{:});
 
vale3 = imdilate(vale2,seD);
imshow(vale3)
vale3 = imdilate(vale3,seD);
imshow(vale3)