function [] = showSlide(subject,handles,slice)

    %Variables auxiliares del path
    sub=num2str(subject);
    path='Subjects/';
    name_image='/CCSeg_radiologos.nii.gz';
    
    %Mostrar el numero del slice
    set(handles.txtSlice,'String',slice)
    
    %Mascara para eliminar ruido fuera de la segmentacion
    for i=1:256
        for j=1:256
            if i>=80 && i<=150 && j>=80 && j<=170
                mascara(i,j)=1;
            else
                mascara(i,j)=0;
            end
        end
    end
    
    %Lectura imagen nifti
    image_nii = load_nii(strcat(path,sub,name_image));
    
    %Guarda el slice en un matriz
    img = squeeze(double(image_nii.img(slice,:,:,1)));
    img=rot90(img);
    %Aplicar la mascara de eliminacion de ruido
    corte=and(img,mascara);
    
    %Graficar el slice
    axes(handles.plotSeg);
    imshow(corte), title(['Segmentación capa: ',num2str(slice)]);
    hold on
    
    %Bounding box del frame
    ccbox = regionprops(corte,'BoundingBox');
    
    %Graficar bounding box
    for k = 1 : length(ccbox)
         thisBB = ccbox(k).BoundingBox;
         rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','r','LineWidth',2 );
    end
    

end

