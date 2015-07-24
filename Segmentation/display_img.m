function [] = display_img(handles)
    subject=get(handles.selectSubj,'Value');
        switch subject
               case 1
                 subject=num2str(11);
               case 2
                 subject=12;
               case 3
                 subject=13;
               case 4
                 subject=14;
               case  5
                 subject=20;
        end
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