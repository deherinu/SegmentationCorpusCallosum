% Inicializacion de variables
nii = '';
usecolorbar = [];
usepanel = [];
usestretch = [];
useimagesc = [];
useinterp = [];
colorindex = '';
color_map = 'NA';
glblocminmax = [];
setvalue = [];
highcolor = 'NA';
colorlevel = [];
usecolorbar = 1; % Habilitar la barra de color lateral
cbarminmax = [];

nii = load_nii('Subjects/sujeto20/T1.nii.gz');
nii.img = real(nii.img);
area = [0.05 0.05 0.9 0.9];
setscanid = 1;

if nii.hdr.dime.datatype == 128 | nii.hdr.dime.datatype == 511
    usecolorbar = 0;
elseif isempty(usecolorbar)
    usecolorbar = 1;
end

if isempty(usepanel)
    usepanel = 1;
end

if isempty(usestretch)
    usestretch = 1;
end

if isempty(useimagesc)
    useimagesc = 1;
end

if isempty(useinterp)
    useinterp = 0;
end

if isempty(colorindex)
    tmp = min(nii.img(:,:,:,1));
    if min(tmp(:)) < 0
        colorindex = 2;
        setcrosshaircolor = [1 1 0];
    else
        colorindex = 3;
    end
end

if isempty(color_map) | ischar(color_map)
    color_map = [];
else
    colorindex = 1;
end

bgimg = [];

if ~isempty(glblocminmax)
    minvalue = glblocminmax(1);
    maxvalue = glblocminmax(2);
else
    minvalue = nii.img(:,:,:,1);
    minvalue = double(minvalue(:));
    minvalue = min(minvalue(~isnan(minvalue))); % Nivel de gris minimo en MRI
    maxvalue = nii.img(:,:,:,1);
    maxvalue = double(maxvalue(:));
    maxvalue = max(maxvalue(~isnan(maxvalue))); % Nivel de gris maximo en MRI
end

if ~isempty(setvalue)
    if ~isempty(glblocminmax)
        minvalue = glblocminmax(1);
        maxvalue = glblocminmax(2);
    else
        minvalue = double(min(setvalue.val));
        maxvalue = double(max(setvalue.val));
    end
    
    bgimg = double(nii.img);
    minbg = double(min(bgimg(:)));
    maxbg = double(max(bgimg(:)));
    
    bgimg = scale_in(bgimg, minbg, maxbg, 55) + 200;	% scale to 201~256
    
    % 56 level for brain structure
    %
    % highcolor = [zeros(1,3);gray(55)];
    highcolor = gray(56);
    cbarminmax = [minvalue maxvalue];
    
    if useinterp
        %  scale signal data to 1~200
        %
        nii.img = repmat(nan, size(nii.img));
        nii.img(setvalue.idx) = setvalue.val;
        
        %  200 level for source image
        %
        bgimg = single(scale_out(bgimg, cbarminmax(1), cbarminmax(2), 199));
    else
        bgimg(setvalue.idx) = NaN;
        minbg = double(min(bgimg(:)));
        maxbg = double(max(bgimg(:)));
        bgimg(setvalue.idx) = minbg;
        
        %  bgimg must be normalized to [201 256]
        %
        bgimg = 55 * (bgimg-min(bgimg(:))) / (max(bgimg(:))-min(bgimg(:))) + 201;
        bgimg(setvalue.idx) = 0;
        
        %  scale signal data to 1~200
        %
        nii.img = zeros(size(nii.img));
        nii.img(setvalue.idx) = scale_in(setvalue.val, minvalue, maxvalue, 199);
        nii.img = nii.img + bgimg;
        bgimg = [];
        nii.img = scale_out(nii.img, cbarminmax(1), cbarminmax(2), 199);
        
        minvalue = double(nii.img(:));
        minvalue = min(minvalue(~isnan(minvalue)));
        maxvalue = double(nii.img(:));
        maxvalue = max(maxvalue(~isnan(maxvalue)));
        
        if ~isempty(glblocminmax)		% maxvalue is gray
            minvalue = glblocminmax(1);
        end
    end
    
    colorindex = 2;
    setcrosshaircolor = [1 1 0];
end

if isempty(highcolor) | ischar(highcolor)
    highcolor = [];
    num_highcolor = 0;
else
    num_highcolor = size(highcolor,1);
end

if isempty(colorlevel)
    colorlevel = 256 - num_highcolor;
end

if usecolorbar
    cbar_area = area;
    cbar_area(1) = area(1) + area(3)*0.93;
    cbar_area(3) = area(3)*0.04;
    area(3) = area(3)*0.9;		% 90% used for main axes
else
    cbar_area = [];
end

%  init color (gray) scaling to make sure the slice clim take the
%  global clim [min(nii.img(:)) max(nii.img(:))]
%
if isempty(bgimg)
    clim = [minvalue maxvalue];
else
    clim = [minvalue double(max(bgimg(:)))];
end

if clim(1) == clim(2)
    clim(2) = clim(1) + 0.000001;
end

if isempty(cbarminmax)
    cbarminmax = [minvalue maxvalue]; % Rangos de tono de color mínimo y máximo
end

xdim = size(nii.img, 1); % Número de capas en el plano sagital
ydim = size(nii.img, 2); % Número de capas en el plano coronal
zdim = size(nii.img, 3); % Número de capas en el plano transversal

dims = [xdim ydim zdim]; % Vector de dimensión 3D de todas las capas

voxel_size = abs(nii.hdr.dime.pixdim(2:4)); % volumen en milímetros de cada voxel

if any(voxel_size <= 0)
    voxel_size(find(voxel_size <= 0)) = 1; % Parametrización de voxeles menores a 1 mm
end

origin = abs(nii.hdr.hist.originator(1:3));

if isempty(origin) | all(origin == 0)		% according to SPM
    origin = (dims+1)/2;   
end;

origin = round(origin); % Voxel central (origen) de la cabeza en el MRI

% Corrección en caso que el origen (algun origen) este por fuera del rango
% superior de capas
if any(origin > dims)				% simulate fMRI
    origin(find(origin > dims)) = dims(find(origin > dims));
end

% Corrección en caso que el origen (algun origen) este por fuera del rango
% inferior de capas
if any(origin <= 0)
    origin(find(origin <= 0)) = 1;
end

% Inicio creación de estructura contenedora de resultados para
% visualización
nii_view.dims = dims; % Número de capas
nii_view.voxel_size = voxel_size; % Volumen en voxeles
nii_view.origin = origin; % Voxel de origen

nii_view.slices.sag = 1;
nii_view.slices.cor = 1;
nii_view.slices.axi = 1;
if xdim > 1, nii_view.slices.sag = origin(1); end % Slice inicial de ubicación (origen X)
if ydim > 1, nii_view.slices.cor = origin(2); end % Slice inicial de ubicación (origen y)
if zdim > 1, nii_view.slices.axi = origin(3); end % Slice inicial de ubicación (origen z)

nii_view.area = area;