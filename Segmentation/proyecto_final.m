original_image = load_nii('Subjects/13/T1.nii.gz');
radiologos_image = load_nii('Subjects/13/CCSeg_radiologos.nii.gz');
niifreeCC=load_nii('Subjects/13/CCSeg_freesurfer.nii.gz')

seD = strel('diamond',1);
nhood = seD.getnhood;

resultadoPredicados = [];
capaActual=[];
counter(1,1) = 1;
for i=1:256
    capaActual(1) = i;
    capaRadiologos = squeeze(uint8(radiologos_image.img(i,:,:,1)));
    %capaRadiologos = capaRadiologos';
    %capaRadiologos = imrotate(capaRadiologos,180);
    capaRadiologos = im2bw(capaRadiologos, .8);
    
    DataUmbralRadio = regionprops(capaRadiologos, 'area', 'perimeter', 'BoundingBox', 'Centroid', 'Eccentricity', 'MajorAxisLength', 'MinorAxisLength', 'Orientation');
    
    [a,b] = size(DataUmbralRadio);
    
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

        if i < 124 | i > 130
            if propiedadesRadio(1,5) <= 10000
                filtroEntropia = entropyfilt(cajaRadioProcesar, nhood);
                filtroRango = rangefilt(cajaRadioProcesar, nhood);
                %figure, imshow(filtroRango), title(['Segmentación capa: ',num2str(i)]);
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



save_nii(radiologos_image,'prueba.nii.gz');