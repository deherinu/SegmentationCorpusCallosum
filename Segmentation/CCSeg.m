function varargout = CCSeg(varargin)
% CCSEG MATLAB code for CCSeg.fig
%      CCSEG, by itself, creates a new CCSEG or raises the existing
%      singleton*.
%
%      H = CCSEG returns the handle to a new CCSEG or the handle to
%      the existing singleton*.
%
%      CCSEG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CCSEG.M with the given input arguments.
%
%      CCSEG('Property','Value',...) creates a new CCSEG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CCSeg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CCSeg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CCSeg

% Last Modified by GUIDE v2.5 19-May-2015 16:17:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CCSeg_OpeningFcn, ...
                   'gui_OutputFcn',  @CCSeg_OutputFcn, ...
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


% --- Executes just before CCSeg is made visible.
function CCSeg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CCSeg (see VARARGIN)

% Choose default command line output for CCSeg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CCSeg wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CCSeg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
