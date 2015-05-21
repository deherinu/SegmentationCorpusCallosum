%Funcion para la deteccion del cuerpo calloso en el eje X
function [] = proyecto_final_x(subject)


%Variables auxiliares con las rutas de los archivos
sub=num2str(subject);
path='D:/MEGA/Maestria/CC/Subjects/';
name_image_T1='/T1.nii.gz';
name_image_Rd='/CCSeg_radiologos.nii.gz';
name_image_Free='/CCSeg_freesurfer.nii.gz';
name_image_result='/CCSeg_newx.nii.gz';

%Rutas de las imagenes
original_image = load_nii(strcat(path,sub,name_image_T1));
radiologos_image = load_nii(strcat(path,sub,name_image_Rd));
niifreeCC=load_nii(strcat(path,sub,name_image_Free));

%Crea una estructura morfologica, tipo diamante
% http://www.mathworks.com/help/images/ref/strel.html

seD = strel('diamond',1);
nhood = seD.getnhood;

resultadoPredicados = [];
%capaActual=[];
counter(1,1) = 1;

%Ciclo para recorrer los slices de la imagen
for i=1:256
    %Capa actual desde 1 hasta n (256)
    %capaActual(1) = i;
    %Elimina dimensiones
    capaRadiologos = squeeze(uint8(radiologos_image.img(i,:,:,1)));
    %Binariza la imagen basada en un umbral
    capaRadiologos = im2bw(capaRadiologos, .8);
    
    %Toma caracteristicas de la imagen capa radiologos
    DataUmbralRadio = regionprops(capaRadiologos, 'area', 'perimeter', 'BoundingBox', 'Centroid', 'Eccentricity', 'MajorAxisLength', 'MinorAxisLength', 'Orientation');
    
    temporal = regionprops(capaRadiologos,'BoundingBox');
    %temporal.BoundingBox
    %aux1=temporal.BoundingBox(1)
    [a,b] = size(DataUmbralRadio);
    %Siempre da 1,0
    
    
    for k = 1 : length(temporal)
        figure(1)
        imshow(capaRadiologos)
        hold on
        thisBB = temporal(k).BoundingBox;
        rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','r','LineWidth',2 )
    end
        
    if a > 0
        
        resultadoPredicados(counter(1,1),1) = i;
        capaOriginal = squeeze(uint8(original_image.img(i,:,:,1)));
        %capaOriginal = capaOriginal';
        %capaOriginal = imrotate(capaOriginal,180);
        
        if a > 1
            
            box = vertcat(DataUmbralRadio.Area);
            box2 = vertcat(DataUmbralRadio.BoundingBox);
            [c,d] = size(box);
            [e,f] = size(box2);
            fila(1,1) = 1;
            fila(1,2) = box(1);
            for n=2:c
                if box(n) > fila(1,2);
                    fila(1,2) = box(n);
                    fila(1,1) = n;
                end
            end
            propiedadesRadio(1,1)=box2(fila(1,1),1);
            propiedadesRadio(1,2)=box2(fila(1,1),2);
            propiedadesRadio(1,3)=box2(fila(1,1),3);
            propiedadesRadio(1,4)=box2(fila(1,1),4);
            propiedadesRadio(1,5)=fila(1,2);
            resultadoPredicados(counter(1,1),2) = fila(1,2);
            cajaRadioProcesar = capaOriginal( floor(propiedadesRadio(1,2)) - 2:floor(propiedadesRadio(1,2)) + propiedadesRadio(1,4) + 2, floor(propiedadesRadio(1,1)) - 2:floor(propiedadesRadio(1,1)) + propiedadesRadio(1,3) + 2);
            %figure, imshow(cajaRadioProcesar);
        else
            propiedadesRadio(1,1)=DataUmbralRadio.BoundingBox(1);
            propiedadesRadio(1,2)=DataUmbralRadio.BoundingBox(2);
            propiedadesRadio(1,3)=DataUmbralRadio.BoundingBox(3);
            propiedadesRadio(1,4)=DataUmbralRadio.BoundingBox(4);
            propiedadesRadio(1,5)=DataUmbralRadio.Area;
            resultadoPredicados(counter(1,1),2) = DataUmbralRadio.Area;
            cajaRadioProcesar = capaOriginal(floor(propiedadesRadio(1,2)) - 2:floor(propiedadesRadio(1,2)) + propiedadesRadio(1,4) + 2, floor(propiedadesRadio(1,1)) - 2:floor(propiedadesRadio(1,1)) + propiedadesRadio(1,3) + 2);
            %figure, imshow(cajaRadioProcesar);
        end

        if i < 124 || i > 130
            if propiedadesRadio(1,5) <= 10000
                filtroEntropia = entropyfilt(cajaRadioProcesar, nhood);
                filtroRango = rangefilt(cajaRadioProcesar, nhood);
                %figure, imshow(filtroRango);
                filtroDesviacionEstandar = stdfilt(cajaRadioProcesar, nhood);
                filtroEntropia = imcomplement(filtroEntropia);
                %figure, imshow(filtroEntropia), title(['Segmentación capa: ',num2str(i),'filtro entropia sin dilatación']);
                Eim = mat2gray(filtroEntropia);
                Eim = imdilate(Eim, seD);
                Eim = imdilate(Eim, seD);
                BW1 = im2bw(Eim, .8);
                %figure, imshow(BW1), title(['Segmentación capa: ',num2str(i)]);
             
                BW1 = uint8(BW1);
                BW1(BW1==1)=255;
                capaOriginal = zeros(256,256);
                capaOriginal(floor(propiedadesRadio(1,2)) - 2:floor(propiedadesRadio(1,2)) + propiedadesRadio(1,4) + 2, floor(propiedadesRadio(1,1)) - 2:floor(propiedadesRadio(1,1)) + propiedadesRadio(1,3) + 2) = BW1;
                radiologos_image.img(i,:,:,1) = capaOriginal;
            end
        end
    
        resultadoPredicados(counter(1,1),3) = double(bwarea(cajaRadioProcesar));
        resultadoPredicados(counter(1,1),4) = entropy(cajaRadioProcesar);
        resultadoPredicados(counter(1,1),5) = std2(cajaRadioProcesar);
        resultadoPredicados(counter(1,1),6) = mean2(cajaRadioProcesar);
        counter(1,1) = counter(1,1)+1;
    end
end

save_nii(radiologos_image,strcat(path,sub,name_image_result));