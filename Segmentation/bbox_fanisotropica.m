%Funcion para hallar el bounding box basada en la segmentacion manual de
%radiologos
%Uso bbox_radiologos(20) Siendo 20 la carpeta del sujeto
function []=bbox_fanisotropica(subject)

%Variables auxiliares del path
sub=num2str(subject);
%path='D:/MEGA/Maestria/CC/Subjects/';
path='F:/MEGA/CC/Subjects/';
name_image_fa='/fa_mri.nii';
name_stats_bbox='/ccstats_bbox_fa.xls';
path_stats=strcat(path,sub,name_stats_bbox);
stats_bbox=[];

%Lectura imagen nifti
fa_image = load_nii(strcat(path,sub,name_image_fa));

%Recorrer todos los slices de un corte
for i=1:256
    
    %Guardar cada corte en una matriz de nxn
    corte = squeeze(double(fa_image.img(i,:,:,1)));
    %Binariza la imagen basada en un umbral
    corte = im2bw(corte, 0.7);
    
    inputImage = imfill(corte, 'holes');
    var2=bwmorph(inputImage,'clean');
    matriz_morph=strel('square',5);
    %var2=imerode(inputImage,matriz_morph);
    %var2=imdilate(inputImage,matriz_morph);
    
    %Guardamos el bounding box de cada frame
    ccbox = regionprops(corte,'BoundingBox');    
    %Almacenar entropia
    entro = regionprops(corte,'Eccentricity');
    
    %Dibujamos el rectangulo de cada objeto encontrado en el frame
    for k = 1 : length(ccbox)
         figure(1)
         subplot(2,1,1);imshow(corte);
         subplot(2,1,2);imshow(var2);
         hold on
         thisBB = ccbox(k).BoundingBox;
         thisEntro = entro(k).Eccentricity;
         stats_bbox=[stats_bbox;i thisBB thisEntro];
         %rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','r','LineWidth',2 );
     end
end
%Guardamos los resultados en un archivo de excel
xlswrite(path_stats,stats_bbox);


