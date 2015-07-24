%Funcion para hallar el bounding box basada en la segmentacion manual de
%radiologos
%Uso bbox_radiologos(20) Siendo 20 la carpeta del sujeto
function [slice]=bbox_radiologos_Ax(subject,handles,plane)

    %Variables auxiliares del path
    sub=num2str(subject);
    plane=num2str(plane);
    path='Subjects/';
    if strcmp (plane,'axialRad')
        name_image='/CCSeg_radiologos.nii.gz';
    else
        name_image='/CCSeg_freesurfer.nii.gz';
    end
    name_stats_bbox=strcat('/ccstats_bbox_',plane,'_',sub,'.csv');
    path_stats=strcat(path,sub,name_stats_bbox);
    stats_bbox=[];

    %Mascara para eliminar ruido fuera de la segmentacion
    for i=1:256
        for j=1:256
            if i>=50 && i<=200 && j>=80 && j<=170
                mascara(i,j)=1;
            else
                mascara(i,j)=0;
            end
        end
    end
    
    %Eliminar imagenes previas
    cla(handles.plotMask);
    cla(handles.plotSeg);
    
    %Mostrar la mascara en un plot
    axes(handles.plotMask);
    imshow(mascara);

    %Lectura imagen nifti
    image_nii = load_nii(strcat(path,sub,name_image));

    %Recorrer todos los slices de un corte
    for i=70:180

        %Guardar cada corte en una matriz de nxn dependiendo del corte
        img = squeeze(double(image_nii.img(:,:,i,1)));
        img=rot90(img);
        
        %Operacion and entre la mascara y la imagen
        corte=and(img,mascara);
        
        %Guardamos el bounding box de cada frame
        ccbox = regionprops(corte,'BoundingBox');

        %Graficar los resultados
        axes(handles.plotSeg);
        imshow(corte), title(['Segmentación capa: ',num2str(i)]);
        hold on
        
        %Dibujamos el rectangulo de cada objeto encontrado en el frame
        for k = 1 : length(ccbox)
             thisBB = ccbox(k).BoundingBox;
             stats_bbox=[stats_bbox;i thisBB];
             rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','r','LineWidth',2 );
        end        
    end
    
    %Guardamos los resultados en un archivo de excel
    csvwrite(path_stats,stats_bbox);