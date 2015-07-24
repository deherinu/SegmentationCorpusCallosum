function [] = showSlide(subject,handles,slice)

    %Variables auxiliares del path
    sub=num2str(subject);
    path='Subjects/';
    name_image='/T1.nii.gz';
    
    %Eliminar imagenes previas
    cla(handles.plotImage)
    cla(handles.plotSeg)
    
    %Mascara
    for i=1:256
        for j=1:256
            if i>=80 && i<=150 && j>=80 && j<=170
                mascara(i,j)=1;
            else
                mascara(i,j)=0;
            end
        end
    end
    
    %Mostrar el numero del slice
    set(handles.txtSlice,'String',slice)
    
    %Lectura imagen nifti
    image_nii = load_nii(strcat(path,sub,name_image));
    
    %Guarda el slice en un matriz
    img = squeeze(image_nii.img(slice,:,:,1));
    img=rot90(img);
    
    corte=and(img,mascara);
    
    %Graficar el slice
    axes(handles.plotImage);
    imshow(img), title(['Imagen T1 capa: ',num2str(slice)]);
    hold on    
    %Bounding box del frame
    ccbox = regionprops(mascara,'BoundingBox');
    thisBB = ccbox.BoundingBox;
    rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','r','LineWidth',2 );
    
end

