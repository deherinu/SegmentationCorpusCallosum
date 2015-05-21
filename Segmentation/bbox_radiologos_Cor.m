%Funcion para hallar el bounding box basada en la segmentacion manual de
%radiologos
%Uso bbox_radiologos(20) Siendo 20 la carpeta del sujeto
function []=bbox_radiologos_Cor(subject,handles,plane)

    %Variables auxiliares del path
    sub=num2str(subject);
    plane=num2str(plane);
    path='Subjects/';
    if strcmp(plane,'coronalRad')
        name_image='/CCSeg_radiologos.nii.gz';
    else
        name_image='/CCSeg_freesurfer.nii.gz';
    end
    name_stats_bbox=strcat('/ccstats_bbox_',plane,'_',sub,'.xls');
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
    cla(handles.plotMask)
    cla(handles.plotSeg)
        
    %Mostrar la mascara en un plot
    axes(handles.plotMask);
    imshow(mascara);

    %Lectura imagen nifti
    image_nii_Cor = load_nii(strcat(path,sub,name_image));

    %Recorrer todos los slices de un corte
    for i=70:180

        %Guardar cada corte en una matriz de nxn dependiendo del corte
        img_Cor = squeeze(double(image_nii_Cor.img(:,i,:,1)));
        img_Cor = rot90(img_Cor);
        
        %Operacion and entre la mascara y la imagen
        corte_Cor=and(img_Cor,mascara);
        
        %Guardamos el bounding box de cada frame
        ccbox = regionprops(corte_Cor,'BoundingBox');

        %Graficar los resultados
        axes(handles.plotSeg);
        imshow(corte_Cor), title(['Segmentación capa: ',num2str(i)]);
        hold on
        
        %Dibujamos el rectangulo de cada objeto encontrado en el frame
        for k = 1 : length(ccbox)
             thisBB = ccbox(k).BoundingBox;
             stats_bbox=[stats_bbox;i thisBB];
             rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','r','LineWidth',2 );
        end        
    end
    
    %Guardamos los resultados en un archivo de excel
    xlswrite(path_stats,stats_bbox);