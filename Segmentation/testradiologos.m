original_image = load_nii('Subjects/sujeto20/T1.nii.gz');
radiologos_image = load_nii('Subjects/sujeto20/CCSeg_radiologos_20.nii.gz');
niifreeCC=load_nii('Subjects/sujeto20/CCSeg_freesurfer_20.nii.gz')

capaOriginal = squeeze(uint8(original_image.img(113,:,:,1)));
capaOriginal = capaOriginal';
capaOriginal = imrotate(capaOriginal,180);

capaRadiologos = squeeze(uint8(radiologos_image.img(113,:,:,1)));
capaRadiologos = capaRadiologos';
capaRadiologos = imrotate(capaRadiologos,180);
capaRadiologos = im2bw(capaRadiologos, .8);

DataUmbralRadio = regionprops(capaRadiologos, 'area', 'perimeter', 'BoundingBox', 'Centroid', 'Eccentricity', 'MajorAxisLength', 'MinorAxisLength', 'Orientation');

%cajaRadioProcesar = capaRadiologos(round(DataUmbralRadio.BoundingBox(2)) - 2:round(DataUmbralRadio.BoundingBox(2)) - 2 + (round(DataUmbralRadio.BoundingBox(2))+round(DataUmbralRadio.BoundingBox(4)) + 2) - (round(DataUmbralRadio.BoundingBox(2)) - 2), round(DataUmbralRadio.BoundingBox(1)) - 2:round(DataUmbralRadio.BoundingBox(1)) - 2 + (round(DataUmbralRadio.BoundingBox(1))+round(DataUmbralRadio.BoundingBox(3)) + 2) - (round(DataUmbralRadio.BoundingBox(1)) - 2)) 

cajaOriginal = capaOriginal(98:136, 81:166);
figure, imshow(cajaOriginal);

entropy(cajaOriginal)

cajaOriginalProcesar = capaOriginal(98:117, 81:124);
figure, imshow(cajaOriginalProcesar);

figure, imshow(cajaOriginalProcesar);

cajaOriginalProcesar = histeq(cajaOriginalProcesar);
Entropy = entropy(cajaOriginalProcesar);
DesviacionEstandar = std2(cajaOriginalProcesar);

seD = strel('diamond',1);
nhood = seD.getnhood;

filtroEntropia = entropyfilt(cajaOriginalProcesar, nhood);
figure, imshow(filtroEntropia);

filtroDesviacionEstandar = stdfilt(cajaOriginalProcesar, nhood);
figure, imshow(filtroDesviacionEstandar);