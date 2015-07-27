function [] = postprocessing(subject, handles)
    
    %Variables auxiliares del path
    sub=num2str(subject);
    path='Subjects/';
    processing_img='/cc_processed.nii.gz';
    post_processing_img='/cc_postprocessed.nii.gz';
    file_name=strcat(path,sub,processing_img);
    image_nii = load_nii(file_name);
    
    img_data = image_nii.img(:,:,:,:);
    
    minArea = str2double(get(handles.txtMinArea,'String'));
    
    contents = get(handles.popConnect,'String'); 
    connect_value = str2double(contents{get(handles.popConnect,'Value')});
    
    bw3 = bwareaopen(img_data, minArea, connect_value);
    
    image_nii.img(:,:,:,:) = bw3;
    
    save_nii(image_nii,strcat(path,sub,post_processing_img));
    
    h = msgbox('Operation Completed');