function [] = display_img(subject,handles)

    path='Subjects/';
    name_t1_image='/T1.nii.gz';
    image_nii = load_nii(strcat(path,subject,name_t1_image));
    capa = 100;
    
    
    img = squeeze((image_nii.img(capa,:,:,1)));
    img=rot90(img);

    %Graficar imagen original
    axes(handles.plotImage);
    imshow(img),title(['Imagen T1 capa: ',num2str(capa)]);
    hold on