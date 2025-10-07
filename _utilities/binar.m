function varargout = binar(img, varargin)
% interactive binarization of a grayscale image
if nargin <= 1
   if nargin == 0
      initial_dir = pwd;
   elseif nargin == 1 & exist(varargin{1},'dir')
      initial_dir = varargin{1};
   else
      errordlg('Input argument must be a valid directory','Input Argument Error!')
      return
   end
   fig = openfig(mfilename,'reuse');
   handles = guihandles(fig);
   guidata(fig, handles);
   load_listbox(initial_dir,handles)
   if nargout > 0
      varargout{1} = fig; 
   end
   
   set(handles.umb,'SliderStep',[1/255 0.05]);
elseif ischar(varargin{1}) 
   try
      if (nargout)
         [varargout{1:nargout}] = feval(varargin{:}); 
      else
         feval(varargin{:}); 
     end
   catch
      disp(lasterr);
   end
end
% --------------------------------------------------------------------
function listbox1_Callback(h, eventdata, handles, varargin)
if strcmp(get(handles.figure1,'SelectionType'),'open')
   index_selected = get(handles.listbox1,'Value');
   file_list = get(handles.listbox1,'String');
   filename = file_list{index_selected};
   if  handles.is_dir(handles.sorted_index(index_selected))
      cd (filename)
      load_listbox(pwd,handles)
   else
      [path,name,ext,ver] = fileparts(filename);
      if ( strcmp(ext,'.tif')==1 | strcmp(ext,'.bmp')==1 | strcmp(ext,'.jpg')==1 )
          
          handles.im_0 = imread(filename);
          handles.im_orig=handles.im_0;
          handles.im_2=handles.im_orig;
          handles.im_tratada = handles.im_orig;        
          
          tama_im = size(handles.im_orig);          
          tama_vert = tama_im(1);tama_horiz = tama_im(2);
          
          set(handles.sup_min,'Max',round(tama_vert*tama_horiz/100));                              
          set(handles.umb,'Value',round(graythresh(handles.im_orig)*255));
          set(handles.edit_um,'String',num2str( round(graythresh(handles.im_orig)*255) ))          
          set(handles.sup_min,'Value',0);
          set(handles.sup_min, 'SliderStep',[1/get(handles.sup_min,'Max') 0.1]);
          set(handles.edit_sup,'String',num2str(0));
          apagar([handles.radio_open,handles.radio_close,handles.check_fill,handles.check_clean,handles.ajust]);
          
          axes(handles.axes_im1)
          him=imshow(handles.im_orig);          
          axes(handles.axes_im2)
          him=imshow(handles.im_tratada); 
          
          set(handles.guardar_im_tratada,'Enable','on');
          set(handles.edit_um,'Enable','on');
          set(handles.umb,'Enable','on');
          set(handles.recom,'Enable','on');          
          set(handles.radio_open,'Enable','on');          
          set(handles.radio_close,'Enable','on');         
          set(handles.check_fill,'Enable','on');
          set(handles.check_clean,'Enable','on');
          set(handles.sup_min,'Enable','on');
          set(handles.edit_sup,'Enable','on');
                    
          guidata(h,handles); 
          
          procesar(handles);
          
      else
          errordlg('Valid formats: BMP, TIF, JPG');
      end
  end
end
% ------------------------------------------------------------
function load_listbox(dir_path,handles)
cd (dir_path)
dir_struct = dir(dir_path);
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = [sorted_index];
guidata(handles.figure1,handles)
set(handles.listbox1,'String',handles.file_names,'Value',1)
set(handles.text1,'String',pwd)
% --------------------------------------------------------------------
function nom_im_tratada_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function guardar_im_tratada_Callback(h, eventdata, handles, varargin)
nombre = get(handles.nom_im_tratada,'String');
[pathstr,name,ext,versn] = fileparts(nombre);
if ( strcmp(ext,'.tif')==1 | strcmp(ext,'.bmp')==1 | strcmp(ext,'.jpg')==1 )    
    imwrite(handles.im_tratada,nombre);
else
    errordlg('Valid formats: BMP, TIF y JPG');
end
% --------------------------------------------------------------------
function umb_Callback(h, eventdata, handles, varargin)
umbral=round(get(handles.umb,'Value'));
set(handles.umb,'Value',umbral);
set(handles.edit_um,'String',num2str(umbral));
procesar(handles);
% --------------------------------------------------------------------
function edit_um_Callback(h, eventdata, handles, varargin)
valor=str2double(get(handles.edit_um,'String'));
if isnumeric(valor) & length(valor) == 1 & valor >= get(handles.umb,'Min') & valor <= get(handles.umb,'Max')
    set(handles.umb,'Value',valor);      
else
    errordlg('Threshold must be between 0 and 255');
    set(handles.umb,'Value',round(graythresh(handles.im_orig)*255));
    set(handles.edit_um,'String',num2str( round(graythresh(handles.im_orig)*255) ));
end
procesar(handles);  
% --------------------------------------------------------------------
function just_Callback(h, eventdata, handles, varargin)
ha=get(handles.ajust,'Value');
if (ha==1)
    li=stretchlim(handles.im_0,[0.01 0.99]);
    handles.im_orig=imadjust(handles.im_0,li);   
else
    handles.im_orig=handles.im_0;
end
axes(handles.axes_im1)
s=get(handles.axes_im1,'Children');
set(s,'EraseMode','none');
set(s,'CData',handles.im_orig);
guidata(h,handles);
procesar(handles);
% --------------------------------------------------------------------
function recom_Callback(h, eventdata, handles, varargin)
handles.im_orig=handles.im_0;
set(handles.umb,'Value',round(graythresh(handles.im_orig)*255));
set(handles.edit_um,'String',num2str( round(graythresh(handles.im_orig)*255) ))
set(handles.sup_min,'Value',0);
set(handles.edit_sup,'String',num2str(0));
apagar([handles.radio_open,handles.radio_close,handles.check_fill,handles.check_clean,handles.ajust]);
guidata(h,handles);
axes(handles.axes_im1)
him=imshow(handles.im_orig);
procesar(handles);
% --------------------------------------------------------------------
function sup_min_Callback(h, eventdata, handles, varargin)
superf=round(get(handles.sup_min,'Value'));
set(handles.sup_min,'Value',superf);
set(handles.edit_sup,'String',num2str(superf));
procesar(handles);
% --------------------------------------------------------------------
function edit_sup_Callback(h, eventdata, handles, varargin)
valor=str2double(get(handles.edit_sup,'String'));
if isnumeric(valor) & length(valor) == 1 & valor >= get(handles.umb,'Min') & valor <= get(handles.sup_min,'Max')
    set(handles.sup_min,'Value',valor);
else    
    errordlg('Invalid parameter value');
    set(handles.sup_min,'Value',0);
    set(handles.edit_sup,'String',num2str( 0 ));    
end
procesar(handles);
% ----------------------------------------------------------------------
function procesar(handles)
umbral=get(handles.umb,'Value');
superf=get(handles.sup_min,'Value');
fi=get(handles.check_fill,'Value');
cl=get(handles.check_clean,'Value');
op=get(handles.radio_open,'Value');
clo=get(handles.radio_close,'Value');
handles.im_2=im2bw(handles.im_orig,umbral/255);
handles.im_2=bwareaopen(handles.im_2,superf);
if(fi==1)
    handles.im_2=bwmorph(handles.im_2,'fill');
end
if(cl==1)
    handles.im_2=bwmorph(handles.im_2,'clean');
end
if(op==1)
    handles.im_tratada=bwmorph(handles.im_2,'open');
elseif(clo==1)
    handles.im_tratada=bwmorph(handles.im_2,'close');
else
    handles.im_tratada=handles.im_2;
end
guidata(gcbo,handles);
s=get(handles.axes_im2,'Children');
set(s,'EraseMode','none');
etiq=bwlabel(handles.im_tratada,4);
if(max(etiq(:))>0)
    set(s,'CData', label2rgb(etiq,'prism','c') );
else
    set(s,'CData',handles.im_tratada);
end
% --------------------------------------------------------------------
function radio_close_Callback(h, eventdata, handles, varargin)
apagar(handles.radio_open);
procesar(handles);
% --------------------------------------------------------------------
function radio_open_Callback(h, eventdata, handles, varargin)
apagar(handles.radio_close);
procesar(handles);
% --------------------------------------------------------------------
function check_fill_Callback(h, eventdata, handles, varargin)
procesar(handles);
% --------------------------------------------------------------------
function check_clean_Callback(h, eventdata, handles, varargin)
procesar(handles);
% ------------------------------------------------------
function apagar(botones)
set(botones,'Value',0);