figure(1)
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

width = 256;
height = 256;
radius = 20;
centerW = width/2;
centerH = height/2;
[W,H] = meshgrid(1:width,1:height);
mask = sqrt((W-centerW).^2 + (H-centerH-20).^2) > radius;


subplot(1,3,1)
imshow(mascara)
title('Mascara ruido')
subplot(1,3,2)
imshow(mask)
title('Mascara redonda')
subplot(1,3,3)
imshow(and(mascara,mask))
title('Mascara redonda')