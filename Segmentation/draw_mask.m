function [] = draw_mask(handles)

    global mascara
    global rectx1
    global rectx2
    global recty1
    global recty2
    global cirx
    global ciry
    global cirR
    global rect
    
    rectx1 = get(handles.sldRectx1,'Value');
    rectx2 = get(handles.sldRectx2,'Value');
    recty1 = get(handles.sldRecty1,'Value');
    recty2 = get(handles.sldRecty2,'Value');
    cirx = get(handles.sldCirx,'Value');
    ciry = get(handles.sldCiry,'Value');
    cirR = get(handles.sldCirR,'Value');
    
    set(handles.sldRectx1,'TooltipString',num2str(rectx1)); 
    
    %Mascara
    for i=1:256
        for j=1:256
            if i>=rectx1 && i<=rectx2 && j>=recty1 && j<=recty2
                mascara(i,j)=1;
            else
                mascara(i,j)=0;
            end
        end
    end
    
    %Mascara redonda
    width = 256;
    height = 256;
    radius = cirR;
    centerW = cirx/2;
    centerH = ciry/2;
    [W,H] = meshgrid(1:width,1:height);
    mask = sqrt((W-centerW).^2 + (H-centerH-radius).^2) > radius;
    mascara = and(mask,mascara);
    
    %Mostrar la mascara en un plot
    axes(handles.plotMask);
    imshow(mascara);
    
    axes(handles.plotImage);
    maskbox = regionprops(mascara,'BoundingBox');
    maskBB = maskbox.BoundingBox;
    rect = rectangle('Position', [maskBB(1),maskBB(2),maskBB(3),maskBB(4)],'EdgeColor','b','LineWidth',2 );
    
    