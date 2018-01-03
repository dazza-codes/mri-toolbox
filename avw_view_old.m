function avw_view(avw),

% AVW_VIEW - Create and navigate ortho views of Analyze file
%
% avw_view(avw)
%
% avw    -  a struct, created by avw_img_read
%
% The navigation is by sliders and mouse clicks on the
% images in any of the ortho views.
%

% $Revision: 1.1 $ $Date: 2003/07/09 05:27:37 $

% Licence:  GNU GPL, no express or implied warranties
% History:  06/2002, Darren.Weber@flinders.edu.au
%                    The Analyze format is copyright 
%                    (c) Copyright, 1986-1995
%                    Biomedical Imaging Resource, Mayo Foundation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ~exist('avw','var'),
    msg = sprintf('AVW_VIEW: No input avw - see help avw_view\n');
    error(msg);
end


% GUI General Parameters
GUIwidth  = 150;
GUIheight = 50;
if isfield(avw,'fileprefix'),
    if isempty(avw.fileprefix),
        name = 'AVW View';
    else
        format = strcat('%+',sprintf('%d',length(avw.fileprefix)+1),'s');
        name = strcat('AVW View - ',sprintf(format,avw.fileprefix));
    end
else
    name = 'AVW View';
end

GUI = figure('Name',name,'Tag','AVWVIEW','units','characters',...
             'NumberTitle','off',...
             'MenuBar','figure','Position',[1 1 GUIwidth GUIheight]);
movegui(GUI,'center');

AVWVIEW.gui = GUI;


Font.FontName   = 'Helvetica';
Font.FontUnits  = 'Pixels';
Font.FontSize   = 12;
Font.FontWeight = 'normal';
Font.FontAngle  = 'normal';


shading flat


xdim = size(avw.img,1);
ydim = size(avw.img,2);
zdim = size(avw.img,3);

SagSlice = 1;
CorSlice = 1;
AxiSlice = 1;
if xdim > 1, SagSlice = floor(xdim/2); end
if ydim > 1, CorSlice = floor(ydim/2); end
if zdim > 1, AxiSlice = floor(zdim/2); end

AVWVIEW.origin = [SagSlice,CorSlice,AxiSlice];             % vol origin
AVWVIEW.scale  = double(avw.hdr.dime.pixdim(2:4)) ./ 1000; % vol scale in meters

% Initialise some window handles
G.Ha = 0;
G.Hc = 0;
G.Hs = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Axial Slice
if xdim > 1 & ydim > 1,
	
	[x,y] = meshgrid(1:xdim,1:ydim);
	Xaxial = x'; clear x;
	Yaxial = y'; clear y;
	Zaxial = zeros(xdim,ydim);
	
	G.Aa = subplot('position',[0.05 0.56 0.4 0.4]);
	colormap('gray');
	Saxial = uint8(squeeze(avw.img(:,:,AxiSlice)));
	%G.Ha = surf(Xaxial,Yaxial,Zaxial,Saxial,'EdgeColor','none');
	
    G.Ha = imagesc([0, xdim],[0, ydim],Saxial);
    
    
    axis square, daspect([1,1,1]);
	xlabel('(Left <<) X (>> Right)')
	ylabel('Y')
	zlabel('Z')
	title('Axial')
	view([0,90]);
	
	% This callback navigates with left click
	set(G.Ha,'ButtonDownFcn',...
        strcat('AVWVIEW = get(gcbf,''Userdata''); ',...
        'currentpoint = get(get(AVWVIEW.handles.Ha,''Parent''),''CurrentPoint''); ',...
        'SagSlice = round(currentpoint(2,1)); ',...
        'CorSlice = round(currentpoint(2,2)); ',...
        'AxiSlice = round(str2num(get(AVWVIEW.handles.Taxi,''String''))); ',...
        'imgvalue = AVWVIEW.avw.img(SagSlice,CorSlice,AxiSlice); ',...
        'set(AVWVIEW.handles.imval,''String'',sprintf(''%8.2f'',imgvalue));',...
        'set(AVWVIEW.gui,''UserData'',AVWVIEW);',...
        'if ishandle(AVWVIEW.handles.Hs) & AVWVIEW.handles.Hs, ',...
        '   Ssag = squeeze(AVWVIEW.avw.img(SagSlice,:,:));',...
        '   set(AVWVIEW.handles.Hs,''CData'',Ssag); drawnow;',...
        '   set(AVWVIEW.handles.Tsag,''String'',num2str(SagSlice));',...
        '   set(AVWVIEW.handles.Ssag,''Value'',SagSlice);',...
        '   clear Ssag; ',...
        '   set(AVWVIEW.gui,''UserData'',AVWVIEW);',...
        'end; ',...
        'if ishandle(AVWVIEW.handles.Hc) & AVWVIEW.handles.Hc, ',...
        '   Scor = squeeze(AVWVIEW.avw.img(:,CorSlice,:));',...
        '   set(AVWVIEW.handles.Hc,''CData'',Scor); drawnow;',...
        '   set(AVWVIEW.handles.Tcor,''String'',num2str(CorSlice));',...
        '   set(AVWVIEW.handles.Scor,''Value'',CorSlice);',...
        '   clear Scor; ',...
        '   set(AVWVIEW.gui,''UserData'',AVWVIEW);',...
        'end; ',...
        'clear currentpoint imgvalue AxiSlice CorSlice SagSlice AVWVIEW;'));
    
    if zdim > 1,
		slider_step(1) = 1/(zdim);
		slider_step(2) = 1/(zdim);
		G.Saxi = uicontrol('Parent',GUI,'Style','slider','Units','Normalized', Font, ...
            'Position',[.45 .56 .03 .40], 'HorizontalAlignment', 'center',...
            'BusyAction','queue',...
            'Min',1,'Max',zdim,'SliderStep',slider_step,'Value',AxiSlice,...
            'Callback',strcat('AVWVIEW = get(gcbf,''Userdata''); ',...
            'AxiSlice = round(get(AVWVIEW.handles.Saxi,''Value''));',...
            'set(AVWVIEW.handles.Saxi,''Value'',AxiSlice);',...
            'Saxi = squeeze(AVWVIEW.avw.img(:,:,AxiSlice));',...
            'set(AVWVIEW.handles.Ha,''CData'',Saxi); drawnow;',...
            'set(AVWVIEW.handles.Taxi,''String'',num2str(AxiSlice));',...
            'CorSlice = round(get(AVWVIEW.handles.Scor,''Value''));',...
            'SagSlice = round(get(AVWVIEW.handles.Ssag,''Value''));',...
            'imgvalue = AVWVIEW.avw.img(SagSlice,CorSlice,AxiSlice); ',...
            'set(AVWVIEW.handles.imval,''String'',sprintf(''%8.2f'',imgvalue));',...
            'set(AVWVIEW.gui,''UserData'',AVWVIEW);',...
            'clear imgvalue Saxi AxiSlice CorSlice SagSlice AVWVIEW;'));
    end
	G.Taxi = uicontrol('Parent',GUI,'Style','text','Units','Normalized', Font, ...
        'Position',[.45 .51 .03 .05], 'HorizontalAlignment', 'center',...
        'BusyAction','queue',...
        'String',num2str(AxiSlice));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Coronal Slice
if xdim > 1 & zdim > 1,
	
	[x,z] = meshgrid(1:xdim,1:zdim);
	Xcor = x'; clear x;
	Zcor = z'; clear z;
	Ycor = zeros(xdim,zdim);
	
	subplot('position',[0.55 0.56 0.4 0.4])
	colormap('gray');
	Scor = squeeze(avw.img(:,CorSlice,:));
	
	G.Hc = surf(Xcor,Ycor,Zcor,Scor,'EdgeColor','none');
	axis square, daspect([1,1,1]);
    xlabel('(Left <<) X (>> Right)')
	ylabel('Y')
	zlabel('Z')
	title('Coronal')
	view([0,0]);
	
	% This callback navigates with left click
	set(G.Hc,'ButtonDownFcn',...
        strcat('AVWVIEW = get(gcbf,''Userdata''); ',...
        'currentpoint = get(get(AVWVIEW.handles.Hc,''Parent''),''CurrentPoint''); ',...
        'SagSlice = round(currentpoint(2,1)); ',...
        'AxiSlice = round(currentpoint(2,3)); ',...
        'CorSlice = round(str2num(get(AVWVIEW.handles.Tcor,''String''))); ',...
        'imgvalue = AVWVIEW.avw.img(SagSlice,CorSlice,AxiSlice); ',...
        'set(AVWVIEW.handles.imval,''String'',sprintf(''%8.2f'',imgvalue));',...
        'set(AVWVIEW.gui,''UserData'',AVWVIEW);',...
        'if ishandle(AVWVIEW.handles.Hs) & AVWVIEW.handles.Hs, ',...
        '   Ssag = squeeze(AVWVIEW.avw.img(SagSlice,:,:));',...
        '   set(AVWVIEW.handles.Hs,''CData'',Ssag); drawnow;',...
        '   set(AVWVIEW.handles.Tsag,''String'',num2str(SagSlice));',...
        '   set(AVWVIEW.handles.Ssag,''Value'',SagSlice);',...
        '   clear Ssag; ',...
        '   set(AVWVIEW.gui,''UserData'',AVWVIEW);',...
        'end; ',...
        'if ishandle(AVWVIEW.handles.Ha) & AVWVIEW.handles.Ha, ',...
        '   Saxi = squeeze(AVWVIEW.avw.img(:,:,AxiSlice));',...
        '   set(AVWVIEW.handles.Ha,''CData'',Saxi); drawnow;',...
        '   set(AVWVIEW.handles.Taxi,''String'',num2str(AxiSlice));',...
        '   set(AVWVIEW.handles.Saxi,''Value'',AxiSlice);',...
        '   clear Saxi; ',...
        '   set(AVWVIEW.gui,''UserData'',AVWVIEW);',...
        'end; ',...
        'clear currentpoint imgvalue AxiSlice CorSlice SagSlice AVWVIEW;'));
    
    if ydim > 1,
        slider_step(1) = 1/(ydim);
		slider_step(2) = 1/(ydim);
		G.Scor = uicontrol('Parent',GUI,'Style','slider','Units','Normalized', Font, ...
            'Position',[.95 .56 .03 .40], 'HorizontalAlignment', 'center',...
            'BusyAction','queue',...
            'Min',1,'Max',ydim,'SliderStep',slider_step,'Value',CorSlice,...
            'Callback',strcat('AVWVIEW = get(gcbf,''Userdata''); ',...
            'CorSlice = round(get(AVWVIEW.handles.Scor,''Value''));',...
            'set(AVWVIEW.handles.Scor,''Value'',CorSlice);',...
            'Scor = squeeze(AVWVIEW.avw.img(:,CorSlice,:));',...
            'set(AVWVIEW.handles.Hc,''CData'',Scor); drawnow;',...
            'set(AVWVIEW.handles.Tcor,''String'',num2str(CorSlice));',...
            'AxiSlice = round(get(AVWVIEW.handles.Saxi,''Value''));',...
            'SagSlice = round(get(AVWVIEW.handles.Ssag,''Value''));',...
            'imgvalue = AVWVIEW.avw.img(SagSlice,CorSlice,AxiSlice); ',...
            'set(AVWVIEW.handles.imval,''String'',sprintf(''%8.2f'',imgvalue));',...
            'set(AVWVIEW.gui,''UserData'',AVWVIEW);',...
            'clear imgvalue Scor AxiSlice CorSlice SagSlice AVWVIEW;'));
    end
	G.Tcor = uicontrol('Parent',GUI,'Style','text','Units','Normalized', Font, ...
        'Position',[.95 .51 .03 .05], 'HorizontalAlignment', 'center',...
        'BusyAction','queue',...
        'String',num2str(CorSlice));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Sagittal Slice
if ydim > 1 & ydim > 1,
		
	[y,z] = meshgrid(1:ydim,1:zdim);
	Ysag = y'; clear y;
	Zsag = z'; clear z;
	Xsag = zeros(ydim,zdim);
	
	subplot('position',[0.05 0.06 0.4 0.4])
	colormap('gray');
	Ssag = squeeze(avw.img(SagSlice,:,:));
	
	G.Hs = surf(Xsag,Ysag,Zsag,Ssag,'EdgeColor','none');
	axis square, daspect([1,1,1]);
    xlabel('(Left <<) X (>> Right)')
	ylabel('Y')
	zlabel('Z')
	title('Sagittal')
	view([90,0]);
	
	% This callback navigates with mouse click
	set(G.Hs,'ButtonDownFcn',...
        strcat('AVWVIEW = get(gcbf,''Userdata''); ',...
        'currentpoint = get(get(AVWVIEW.handles.Hs,''Parent''),''CurrentPoint''); ',...
        'CorSlice = round(currentpoint(1,2)); ',...
        'AxiSlice = round(currentpoint(1,3)); ',...
        'SagSlice = round(str2num(get(AVWVIEW.handles.Tsag,''String'')));',...
        'imgvalue = AVWVIEW.avw.img(SagSlice,CorSlice,AxiSlice); ',...
        'set(AVWVIEW.handles.imval,''String'',sprintf(''%8.2f'',imgvalue));',...
        'set(AVWVIEW.gui,''UserData'',AVWVIEW);',...
        'if ishandle(AVWVIEW.handles.Hc) & AVWVIEW.handles.Hc, ',...
        '   Scor = squeeze(AVWVIEW.avw.img(:,CorSlice,:));',...
        '   set(AVWVIEW.handles.Hc,''CData'',Scor); drawnow;',...
        '   set(AVWVIEW.handles.Tcor,''String'',num2str(CorSlice));',...
        '   set(AVWVIEW.handles.Scor,''Value'',CorSlice);',...
        '   clear Scor; ',...
        '   set(AVWVIEW.gui,''UserData'',AVWVIEW);',...
        'end; ',...
        'if ishandle(AVWVIEW.handles.Ha) & AVWVIEW.handles.Ha, ',...
        '   Saxi = squeeze(AVWVIEW.avw.img(:,:,AxiSlice));',...
        '   set(AVWVIEW.handles.Ha,''CData'',Saxi); drawnow;',...
        '   set(AVWVIEW.handles.Taxi,''String'',num2str(AxiSlice));',...
        '   set(AVWVIEW.handles.Saxi,''Value'',AxiSlice);',...
        '   clear Saxi; ',...
        '   set(AVWVIEW.gui,''UserData'',AVWVIEW);',...
        'end; ',...
        'clear currentpoint imgvalue AxiSlice CorSlice SagSlice AVWVIEW;'));

    
    if xdim > 1,
		slider_step(1) = 1/(xdim);
		slider_step(2) = 1/(xdim);
		G.Ssag = uicontrol('Parent',GUI,'Style','slider','Units','Normalized', Font, ...
            'Position',[.45 .06 .03 .4], 'HorizontalAlignment', 'center',...
            'BusyAction','queue',...
            'Min',1,'Max',xdim,'SliderStep',slider_step,'Value',SagSlice,...
            'Callback',strcat('AVWVIEW = get(gcbf,''Userdata''); ',...
            'SagSlice = round(get(AVWVIEW.handles.Ssag,''Value''));',...
            'set(AVWVIEW.handles.Ssag,''Value'',SagSlice);',...
            'Ssag = squeeze(AVWVIEW.avw.img(SagSlice,:,:));',...
            'set(AVWVIEW.handles.Hs,''CData'',Ssag); drawnow;',...
            'set(AVWVIEW.handles.Tsag,''String'',num2str(SagSlice));',...
            'AxiSlice = round(get(AVWVIEW.handles.Saxi,''Value''));',...
            'CorSlice = round(get(AVWVIEW.handles.Scor,''Value''));',...
            'imgvalue = AVWVIEW.avw.img(SagSlice,CorSlice,AxiSlice); ',...
            'set(AVWVIEW.handles.imval,''String'',sprintf(''%8.2f'',imgvalue));',...
            'set(AVWVIEW.gui,''UserData'',AVWVIEW);',...
            'clear imgvalue Ssag AxiSlice CorSlice SagSlice AVWVIEW;'));
    end
	G.Tsag = uicontrol('Parent',GUI,'Style','text','Units','Normalized', Font, ...
        'Position',[.45 .01 .03 .05], 'HorizontalAlignment', 'center',...
        'BusyAction','queue',...
        'String',num2str(SagSlice));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Intensity Value at Mouse Click

G.Timval = uicontrol('Parent',GUI,'Style','text','Units','Normalized', Font, ...
    'Position',[.575 .40 .20 .05], 'HorizontalAlignment', 'left',...
    'BusyAction','queue',...
    'String','Image Intensity');
G.imval = uicontrol('Parent',GUI,'Style','text','Units','Normalized', Font, ...
    'Position',[.775 .40 .20 .05], 'HorizontalAlignment', 'right',...
    'BusyAction','queue',...
    'String','x');

% Nasion Location
G.Tnasion = uicontrol('Parent',GUI,'Style','pushbutton','Units','Normalized', Font, ...
    'Position',[.575 .35 .20 .04], 'HorizontalAlignment', 'left',...
    'BusyAction','queue',...
    'TooltipString','Update Nasion - should be toward +Y',...
    'String','Fiducial: Nasion',...
    'Callback',strcat('AVWVIEW = get(gcbf,''Userdata''); ',...
            'SagSlice = get(AVWVIEW.handles.Ssag,''Value'');',...
            'CorSlice = get(AVWVIEW.handles.Scor,''Value'');',...
            'AxiSlice = get(AVWVIEW.handles.Saxi,''Value'');',...
            'imgXYZ   = [SagSlice,CorSlice,AxiSlice]; ',...
            'imgXYZ = (imgXYZ - AVWVIEW.origin) .* AVWVIEW.scale; ',...
            'set(AVWVIEW.handles.nasion,''String'',sprintf(''%6.3f %6.3f %6.3f'',imgXYZ));',...
            'AVWVIEW.p.mriFID(1,:) = imgXYZ; ',...
            'set(AVWVIEW.gui,''UserData'',AVWVIEW);',...
            'clear imgXYZ AxiSlice CorSlice SagSlice AVWVIEW;'));
G.nasion = uicontrol('Parent',GUI,'Style','text','Units','Normalized', Font, ...
    'Position',[.775 .35 .20 .04], 'HorizontalAlignment', 'right',...
    'BusyAction','queue',...
    'TooltipString','In meters, origin at (0,0,0), should be toward +Y',...
    'String','x,y,z');
% Right Preauricular Location
G.Trpa = uicontrol('Parent',GUI,'Style','pushbutton','Units','Normalized', Font, ...
    'Position',[.575 .30 .20 .04], 'HorizontalAlignment', 'left',...
    'BusyAction','queue',...
    'TooltipString','Update Right Preauricular - should be toward +X',...
    'String','Fiducial: RPA',...
    'Callback',strcat('AVWVIEW = get(gcbf,''Userdata''); ',...
            'SagSlice = get(AVWVIEW.handles.Ssag,''Value'');',...
            'CorSlice = get(AVWVIEW.handles.Scor,''Value'');',...
            'AxiSlice = get(AVWVIEW.handles.Saxi,''Value'');',...
            'imgXYZ   = [SagSlice,CorSlice,AxiSlice]; ',...
            'imgXYZ = (imgXYZ - AVWVIEW.origin) .* AVWVIEW.scale; ',...
            'set(AVWVIEW.handles.rpa,''String'',sprintf(''%6.3f %6.3f %6.3f'',imgXYZ));',...
            'AVWVIEW.p.mriFID(2,:) = imgXYZ; ',...
            'set(AVWVIEW.gui,''UserData'',AVWVIEW);',...
            'clear imgXYZ AxiSlice CorSlice SagSlice AVWVIEW;'));
G.rpa = uicontrol('Parent',GUI,'Style','text','Units','Normalized', Font, ...
    'Position',[.775 .30 .20 .04], 'HorizontalAlignment', 'right',...
    'BusyAction','queue',...
    'TooltipString','In meters, origin at (0,0,0), should be toward +X',...
    'String','x,y,z');
% Left Preauricular Location
G.Tlpa = uicontrol('Parent',GUI,'Style','pushbutton','Units','Normalized', Font, ...
    'Position',[.575 .25 .20 .04], 'HorizontalAlignment', 'left',...
    'BusyAction','queue',...
    'TooltipString','Update Left Preauricular - should be toward -X',...
    'String','Fiducial: LPA',...
    'Callback',strcat('AVWVIEW = get(gcbf,''Userdata''); ',...
            'SagSlice = get(AVWVIEW.handles.Ssag,''Value'');',...
            'CorSlice = get(AVWVIEW.handles.Scor,''Value'');',...
            'AxiSlice = get(AVWVIEW.handles.Saxi,''Value'');',...
            'imgXYZ   = [SagSlice,CorSlice,AxiSlice]; ',...
            'imgXYZ = (imgXYZ - AVWVIEW.origin) .* AVWVIEW.scale; ',...
            'set(AVWVIEW.handles.lpa,''String'',sprintf(''%6.3f %6.3f %6.3f'',imgXYZ));',...
            'AVWVIEW.p.mriFID(3,:) = imgXYZ; ',...
            'set(AVWVIEW.gui,''UserData'',AVWVIEW);',...
            'clear imgXYZ AxiSlice CorSlice SagSlice AVWVIEW;'));
G.lpa = uicontrol('Parent',GUI,'Style','text','Units','Normalized', Font, ...
    'Position',[.775 .25 .20 .04], 'HorizontalAlignment', 'right',...
    'BusyAction','queue',...
    'TooltipString','In meters, origin at (0,0,0), should be toward -X',...
    'String','x,y,z');






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Font.FontWeight = 'bold';

% OK: Return the avw!
G.Bhdr = uicontrol('Parent',GUI,'Style','pushbutton','Units','Normalized', Font, ...
    'Position',[.8 .01 .08 .04],...
    'String','HDR','BusyAction','queue',...
    'TooltipString','Save the hdr parameters.',...
    'BackgroundColor',[0.0 0.0 0.5],...
    'ForegroundColor',[1 1 1], 'HorizontalAlignment', 'center',...
    'Callback',strcat('AVWVIEW = get(gcbf,''Userdata''); ',...
        'avw_view_hdr(AVWVIEW.avw);',...
        'clear AVWVIEW;'));

% Cancel
G.Bquit = uicontrol('Parent',GUI,'Style','pushbutton','Units','Normalized', Font, ...
    'Position',[.9 .01 .08 .04],...
    'String','RETURN','BusyAction','queue',...
    'BackgroundColor',[0.75 0.0 0.0],...
    'ForegroundColor', [1 1 1], 'HorizontalAlignment', 'center',...
    'Callback',strcat('AVWVIEW = get(gcbf,''Userdata''); ',...
        'if isfield(AVWVIEW,''p''), ',...
        '  if isfield(AVWVIEW.p,''mriFID''), ',...
        '    if exist(''p'',''var''), ',...
        '      p.mriFID = AVWVIEW.p.mriFID; ',...
        '    else, ',...
        '      mriFID = AVWVIEW.p.mriFID;',...
        '    end; ',...
        '  end; ',...
        'end; ',...
        'clear AVWVIEW; close gcbf;'));

% Update the gui_struct handles for this gui
AVWVIEW.avw = avw;
AVWVIEW.handles = G;
set(AVWVIEW.gui,'Userdata',AVWVIEW);
set(AVWVIEW.gui,'HandleVisibility','callback');

return


function slice_img(avw),

    figure
    xslice = 128;
    slice = squeeze( avw.img(xslice,:,:) );
    imagesc(slice); axis image; colormap('gray')
    figure
    yslice = 128;
    slice = squeeze( avw.img(:,yslice,:) );
    imagesc(slice); axis image; colormap('gray')
    figure
    zslice = 128;
    slice = squeeze( avw.img(:,:,zslice) );
    imagesc(slice); axis image; colormap('gray')

return
