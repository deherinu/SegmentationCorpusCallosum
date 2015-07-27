%Funcion para hallar el bounding box basada en la segmentacion manual de
%radiologos
%Uso bbox_radiologos_Sag(sub,handles,plane_selected,mascara);
function []=bbox_radiologos_Sag(subject,handles,plane,mascara)

    %Variables auxiliares del path
    sub=num2str(subject);
    plane=num2str(plane);
    path='Subjects/';
    fa_image='/fa_mri.nii.gz';
    freeSurfer_image='/CCSeg_freesurfer.nii.gz';
    name_t1_image='/T1.nii.gz';
    pre_processing = '/cc_processed.nii.gz';
    name_stats_bbox=strcat('/ccstats_bbox_',plane,'_',sub,'.csv');
    path_stats=strcat(path,sub,name_stats_bbox);
    fa_image_name=strcat(path,sub,fa_image);
    T1_image_name=strcat(path,sub,name_t1_image);
    freeSurfer_image_name=strcat(path,sub,freeSurfer_image);
    stats_bbox=[];

    %Valor de FA para procesamiento
    faValue = str2double(get(handles.txtFaFilter,'String'));
        
    %Eliminar imagenes previas
    cla(handles.plotMask)
    cla(handles.plotSeg)

    %Mostrar la mascara en un plot
    axes(handles.plotMask);
    imshow(mascara);

    %Lectura imagen nifti
    image_nii = load_nii(fa_image_name);
    T1_nii = load_nii(T1_image_name);
    freesurfer_nii = load_nii(freeSurfer_image_name);

    %Recorrer todos los slices de un corte
    for i=70:180
        
        %Guardar cada corte en una matriz de nxn dependiendo del corte, T1
        T1_img = squeeze((T1_nii.img(i,:,:,1)));
        T1_img=rot90(T1_img);
        
        %Guardar cada corte en una matriz de nxn dependiendo del corte, FA
        fa_data = squeeze((image_nii.img(i,:,:,1)));
        fa_data=rot90(fa_data);
        
        %Guardar cada corte en una matriz de nxn dependiendo del corte, FS
        freeS_data = squeeze((freesurfer_nii.img(i,:,:,1)));
        freeS_data=rot90(freeS_data);
        
        %Binariza la imagen basada en el umbral, por defecto 0.7
        fa_data = im2bw(fa_data, faValue);
        
        %Operacion and entre la mascara y la imagen
        corte=and(fa_data,mascara);
        
        %Guardamos el bounding box de cada frame
        ccbox = regionprops(corte,'BoundingBox');
        maskbox = regionprops(mascara,'BoundingBox');
        maskBB = maskbox.BoundingBox;
        %procesamiento = im2bw(corte, faValue);
        
        %And segmentacion FS y procesamiento
        %corte=or(corte,freeS_data);
        
        %Graficar los resultados
        axes(handles.plotSeg);
        imshow(corte), title(['Segmentación capa: ',num2str(i)]);
        hold on
        
        %Graficar imagen original
        axes(handles.plotImage);
        imshow(T1_img),title(['Imagen T1 capa: ',num2str(i)]);
        hold on

        set(handles.txtSlice,'String',i)
        set(handles.sldSlice,'value',i)
        
        %Dibujamos el rectangulo de cada objeto encontrado en el frame
        for k = 1 : length(ccbox)
            thisBB = ccbox(k).BoundingBox;
            stats_bbox=[stats_bbox;i thisBB];
            rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','r','LineWidth',2 );
            rectangle('Position', [maskBB(1),maskBB(2),maskBB(3),maskBB(4)],'EdgeColor','b','LineWidth',2 );
        end
        
        image_nii.img(i,:,:,1) = corte;
        
    end
    
    save_nii(image_nii,strcat(path,sub,pre_processing));
    %Guardamos los resultados en un archivo de excel
    csvwrite(path_stats,stats_bbox);