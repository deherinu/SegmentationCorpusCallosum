function [] = postprocessing(subject, handles)
    

    %Paths
    path='Subjects/';
    processing_Sag_img='/cc_processed_Sag.nii.gz';
    processing_Cor_img='/cc_processed_Cor.nii.gz';
    processing_Ax_img='/cc_processed_Ax.nii.gz';
    post_processing_img='/cc_postprocessed.nii.gz';
    %Filenames
    filename_Sag=strcat(path,subject,processing_Sag_img);
    filename_Cor=strcat(path,subject,processing_Cor_img);
    filename_Ax=strcat(path,subject,processing_Ax_img);
    
    
    if exist(filename_Sag, 'file') && exist(filename_Cor, 'file') && exist(filename_Ax, 'file')
        
        %Alert
        msgLoad = msgbox('Loading processed image..');
        
        %Load nifti processed images
        sag_nii = load_nii(filename_Sag);
        
        %Save data as matrix
        img_data = sag_nii.img(:,:,:,:);
        
        %Get minimal area
        minArea = str2double(get(handles.txtMinArea,'String'));
        
        %Get connectivity value
        contents = get(handles.popConnect,'String'); 
        connect_value = str2double(contents{get(handles.popConnect,'Value')});
        
        delete(msgLoad);
        
        %Alert
        msgRemove = msgbox('Removing small objects...');
        %Mask 3d
        for i=1:256
            for j=1:256
                for k=1:256
                    if i>=100 && i<=170 && j>=70 && j<=180 && j>=100 && j<=160
                        mascara(i,j,k)=1;
                    else
                        mascara(i,j,k)=0;
                    end
                end
            end
        end
        
        %Remove small 3d objects
        bw3 = bwareaopen(img_data, minArea, connect_value);
     
        %Apply 3d mask
        bw3=and(bw3,mascara);
        
        delete(msgRemove);
        
        %Filling holes
        msgFill = msgbox('Filling holes..');
        
        %se = ones(10,10,10);
        se=strel3d(15);
        
        %filled_image = imclose(bw3,se);
        step1 = imdilate(bw3,se);
        step2 = imdilate(step1,se);
        step3 = imerode(step2,se);
        filled_image = imerode(step3,se);
        
        %Dilato y erosioso
        whos filled_image
        
        %Copy result
        sag_nii.img(:,:,:,:) = filled_image;

        %Save nifti image
        save_nii(sag_nii,strcat(path,subject,post_processing_img));
        
        delete(msgFill);
        %Alert
        msgbox('Operation Completed!');
    else
        %Alert
        msgbox('Complete all planes processing','Error','error');
    end
    
    