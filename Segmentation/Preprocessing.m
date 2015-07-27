function varargout = Preprocessing(varargin)
% Preprocessing MATLAB code for Preprocessing.fig
%      Preprocessing, by itself, creates a new Preprocessing or raises the existing
%      singleton*.
%
%      H = Preprocessing returns the handle to a new Preprocessing or the handle to
%      the existing singleton*.
%
%      Preprocessing('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in Preprocessing.M with the given input arguments.
%
%      Preprocessing('Property','Value',...) creates a new Preprocessing or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Preprocessing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Preprocessing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Preprocessing

% Last Modified by GUIDE v2.5 27-Jul-2015 14:19:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Preprocessing_OpeningFcn, ...
                   'gui_OutputFcn',  @Preprocessing_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Preprocessing is made visible.
function Preprocessing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Preprocessing (see VARARGIN)

% Choose default command line output for Preprocessing
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Preprocessing wait for user response (see UIRESUME)
% uiwait(handles.figure1);

    
    %Plots vacios
    temp = zeros(256);
    axes(handles.plotImage);
    imshow(temp);
    axes(handles.plotSeg);
    imshow(temp);
    
    %Variables globales
    
    global rectx1
    global rectx2
    global recty1
    global recty2
    global cirx
    global ciry
    global cirR
    global mascara
    global rect
    
    
    rectx1 = 80;
    rectx2 = 150;
    recty1 = 80;
    recty2 = 170;
    cirx = 256;
    ciry = 256;
    cirR = 20;
    
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
    
    %Graficar mascara
    axes(handles.plotMask);
    imshow(mascara);
    
% --- Outputs from this function are returned to the command line.
function varargout = Preprocessing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnSagittalRad.
function btnSagittalRad_Callback(hObject, eventdata, handles)
% hObject    handle to btnSagittalRad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global mascara

    contents = get(handles.selectSubj,'String'); 
    subject = str2double(contents{get(handles.selectSubj,'Value')});
    
    sub=num2str(subject);
           
    bbox_radiologos_Sag(sub,handles,plane,mascara);

% --- Executes on selection change in selectSubj.
function selectSubj_Callback(hObject, eventdata, handles)
% hObject    handle to selectSubj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selectSubj contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectSubj


% --- Executes during object creation, after setting all properties.
function selectSubj_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectSubj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnCoronalRad.
function btnCoronalRad_Callback(hObject, eventdata, handles)
% hObject    handle to btnCoronalRad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    contents = get(handles.selectSubj,'String'); 
    subject = str2double(contents{get(handles.selectSubj,'Value')});
    
    sub=num2str(subject);
    plane='coronalRad';
    bbox_radiologos_Cor(sub,handles,plane)

% --- Executes on button press in btnAxialRad.
function btnAxialRad_Callback(hObject, eventdata, handles)
% hObject    handle to btnAxialRad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    contents = get(handles.selectSubj,'String'); 
    subject = str2double(contents{get(handles.selectSubj,'Value')});
    sub=num2str(subject);

    plane='axialRad';
    bbox_radiologos_Ax(sub,handles,plane)

% --- Executes on button press in btnSagFree.
function btnSagFree_Callback(hObject, eventdata, handles)
% hObject    handle to btnSagFree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    subject=get(handles.selectSubj,'Value');
    switch subject
           case 1
             subject=11;
           case 2
             subject=12;
           case 3
             subject=13;
           case 4
             subject=14;
           case  5
             subject=20;
    end
    sub=num2str(subject);
    plane='sagittalFree';
    bbox_freesurfer(sub,handles,plane)

% --- Executes on button press in btnCoronalFree.
function btnCoronalFree_Callback(hObject, eventdata, handles)
% hObject    handle to btnCoronalFree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnAxialFree.
function btnAxialFree_Callback(hObject, eventdata, handles)
% hObject    handle to btnAxialFree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnStop.
function btnStop_Callback(hObject, eventdata, handles)
% hObject    handle to btnStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function sldSlice_Callback(hObject, eventdata, handles)
% hObject    handle to sldSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
subject=get(handles.selectSubj,'Value');
    switch subject
           case 1
             subject=11;
           case 2
             subject=12;
           case 3
             subject=13;
           case 4
             subject=14;
           case  5
             subject=20;
    end

showSlide(subject,handles,int32(get(handles.sldSlice,'value')))


% --- Executes during object creation, after setting all properties.
function sldSlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in togglebutton2.
function togglebutton2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton2


% --- Executes on button press in togglebutton3.
function togglebutton3_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton3


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over sldSlice.
function sldSlice_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to sldSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*.nii*','Select nifti file')

function txtFaFilter_Callback(hObject, eventdata, handles)
% hObject    handle to txtFaFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtFaFilter as text
%        str2double(get(hObject,'String')) returns contents of txtFaFilter as a double


% --- Executes during object creation, after setting all properties.
function txtFaFilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtFaFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnRun.
function btnRun_Callback(hObject, eventdata, handles)
% hObject    handle to btnRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global mascara

    contents = get(handles.selectSubj,'String'); 
    
    subject = str2double(contents{get(handles.selectSubj,'Value')});

    sub=num2str(subject);

    plane_selected = get(get(handles.selectPlane,'SelectedObject'),'Tag');
    
    if strcmp(plane_selected,'radSag')
        bbox_radiologos_Sag(sub,handles,plane_selected,mascara);
    elseif strcmp(plane_selected,'radAx')
        bbox_radiologos_Ax(sub,handles,plane_selected,mascara);
    else
        bbox_radiologos_Cor(sub,handles,plane_selected,mascara);
    end

function txtMinArea_Callback(hObject, eventdata, handles)
% hObject    handle to txtMinArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtMinArea as text
%        str2double(get(hObject,'String')) returns contents of txtMinArea as a double


% --- Executes during object creation, after setting all properties.
function txtMinArea_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtMinArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_post.
function btn_post_Callback(hObject, eventdata, handles)
% hObject    handle to btn_post (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

subject=get(handles.selectSubj,'Value');
    switch subject
           case 1
             subject=11;
           case 2
             subject=12;
           case 3
             subject=13;
           case 4
             subject=14;
           case  5
             subject=20;
    end
postprocessing(subject, handles)

% --- Executes on slider movement.
function sldRectx1_Callback(hObject, eventdata, handles)
% hObject    handle to sldRectx1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
draw_mask(handles);

% --- Executes during object creation, after setting all properties.
function sldRectx1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldRectx1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sldCirx_Callback(hObject, eventdata, handles)
% hObject    handle to sldCirx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

draw_mask(handles);

% --- Executes during object creation, after setting all properties.
function sldCirx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldCirx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sldRectx2_Callback(hObject, eventdata, handles)
% hObject    handle to sldRectx2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

draw_mask(handles);

% --- Executes during object creation, after setting all properties.
function sldRectx2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldRectx2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sldRecty1_Callback(hObject, eventdata, handles)
% hObject    handle to sldRecty1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
draw_mask(handles);

% --- Executes during object creation, after setting all properties.
function sldRecty1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldRecty1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sldRecty2_Callback(hObject, eventdata, handles)
% hObject    handle to sldRecty2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
draw_mask(handles);

% --- Executes during object creation, after setting all properties.
function sldRecty2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldRecty2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sldCiry_Callback(hObject, eventdata, handles)
% hObject    handle to sldCiry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
draw_mask(handles);

% --- Executes during object creation, after setting all properties.
function sldCiry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldCiry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sldCirR_Callback(hObject, eventdata, handles)
% hObject    handle to sldCirR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
draw_mask(handles);

% --- Executes during object creation, after setting all properties.
function sldCirR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldCirR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in btnDisplay.
function btnDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to btnDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

display_img(handles)
draw_mask(handles)


% --- Executes on selection change in popConnect.
function popConnect_Callback(hObject, eventdata, handles)
% hObject    handle to popConnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popConnect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popConnect


% --- Executes during object creation, after setting all properties.
function popConnect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popConnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radSag.
function radSag_Callback(hObject, eventdata, handles)
% hObject    handle to radSag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radSag


% --- Executes on button press in radCor.
function radCor_Callback(hObject, eventdata, handles)
% hObject    handle to radCor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radCor


% --- Executes on button press in radAx.
function radAx_Callback(hObject, eventdata, handles)
% hObject    handle to radAx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radAx
