classdef xImage < xPixel
    %xImage class for representing images
    %   image data is stored in the following form:
    %   px1:   [r g b; ...
    %   px2:    r g b; ...
    %   px3:    r g b; ...]
    %   ...    ...
    
    %% PROPERTIES
    properties
        height
        width
    end
    
    %% METHODS
    methods
        %% constructor method
        function obj = xImage(varargin)
            % no input args
            if nargin == 0
                % init
            % 1 input arg
            elseif nargin == 1
                if isa(varargin{1}, 'char')
                    switch lower(varargin{1})
                        case 'peppers'
                            obj = xImage(double(imread('peppers.png'))/255)...
                                .setHistory('reading MATLAB example image: peppers.png')...
                                .setColorSpace('sRGB').setName('MATLAB_Peppers.png').linearize;
                        case('testcolors')
                            %obj = xImage();
                            obj.name = 'testcolors';
                            obj.data = xPixel([0 0 0; 0.18 0.18 0.18; 0.5 0.5 0.5; 1 0 0 ; 0 1 0; 0 0 1; 1 1 1]).getData;
                            obj.history = obj.setHistory('testcolors created');
                            obj.isLinear = 1;
                            obj.colorSpace = x3PrimaryCS('sRGB');
                            obj.history = obj.setHistory('colorspace is set to sRGB');
                            obj.height = obj.getNumElements;
                            obj.width = 1;          
                            
                        % other cases here
                        otherwise
                            [fpath, fname, fext] = fileparts(varargin{1});
                            obj = xImage();
                            obj = obj.read(fpath,[fname fext]);
                    end
                
                    % if object is float && real
                elseif isfloat(varargin{1}) && isreal(varargin{1})
                    % if ismatrix(varargin{1}) == 2
                    if ismatrix(varargin{1}==2)
                        obj = obj.setPixel(varargin{1});
                    else
                        obj = obj.setImage(varargin{1});
                    end
                    
                % if object is xPixel
                elseif isa(varargin{1}, 'xPixel')
                    obj = xImage();
                    obj.name = varargin{1}.name;
                    obj.path = varargin{1}.path;
                    obj.data = varargin{1}.data;
                    obj.history = varargin{1}.history;
                    obj.alpha = varargin{1}.alpha;
                    obj.isLinear = varargin{1}.isLinear;
                    obj.colorSpace = varargin{1}.colorSpace;
                    obj.height = varargin{1}.getNumElements;
                    obj.width = 1;
                
                % if object is xImage
                elseif isa(varargin{1}, 'xImage')
                    obj = varargin{1};
                    
                % ---TODO---    
                % if object is xCLUT    
                
                % if object is xPoint
                
                % if object is xLine
                
                % if object is matlab.ui.figure
                elseif isa(varargin{1},'matlab.ui.Figure')

                    rawImg = double(export_fig('-m2','-nocrop',varargin{1}))./255;
                    if size(rawImg,3) == 1
                        rawImg = cat(3,rawImg,rawImg,rawImg);
                    end
                    obj = obj.setImage(rawImg);
                    obj.name = varargin{1}.Name;
                    obj.path = '';
                    obj.setHistory('Captured Figure');
                % ----------
                else
                    disp('xImage is currently obly supported for char or double images') 
                end
                
            % 2 input args
            % note: check this codeblock
            elseif nargin == 2
                if ischar(varargin{2})
                    obj = xImage();
                    obj = obj.read(varargin{1},varargin{2});
                elseif isa(varargin{1},'matlab.ui.Figure')
                    
                    captureSize = num2str(varargin{2});

                    rawImg = double(export_fig(['-m' captureSize],'-nocrop',varargin{1}))./255;
                    if size(rawImg,3) == 1
                        rawImg = cat(3,rawImg,rawImg,rawImg);
                    end
                    obj = obj.setImage(rawImg);
                    obj.name = varargin{1}.Name;
                    obj.path = '';
                    obj.setHistory('Captured Figure')
                else
                    obj = xImage();
                    obj = obj.setImage(varargin{:});
                end
            else
                disp('Calling xImage contructor with more than two arguments is currently not supported')
            end             
        end
        
        %% get/setImage
        %setImage 
        function obj = setImage(obj, image, metadata)
            % get back metadata if supplied or xImage if not
            if exist('metadata', 'var') && isfloat(image)
                if isa(metadata, 'xImage')
                    obj = metadata;
                else
                    error('xImage.setImage: metadata must be of class xImage')
                end
            end
                
            if ndims(image) == 3
                obj.height = size(image,1);
                obj.width = size(image,2);
                if size(image,3) == 3
                    obj.data = reshape(image,[],3);
                elseif size(image,3) == 4
                    obj.data = reshape(image(:,:,1:3),[],3);
                    obj.alpha = reshape(image(:,:,4),[],1);;
                else
                    error(['xImage.setImage: Images must be n*m*3 or n*m*4. This image is n*m*'... 
                        num2str(size(image,3))])
                end
            elseif ismatrix(image)
                if size(image,2) == 3
                    obj.data = reshape(image,[],3);
                elseif size(image,2) == 4
                    obj.data = image(:,1:3);
                    obj.alpha = image(:,4);
                else
                    error(['xImage.setImage: Images must be n*m*3 or n*m*4. This image is n*m*'... 
                        num2str(size(image,3))])
                end
            else
                error(['xImage.setImage: Images must be n*m*3 or n*m*4. This image has ' ...
                    num2str(ndims(image)) ' dimensions instead of three'])
            end
        end 
        
        %getImage
        function image = getImage(obj)
            image = reshape(obj.data, obj.height, obj.width, 3);
        end
        
        %% set image size
        function obj = setSize(obj, height, width)
            obj.width = width;
            obj.height = height;
        end
        
        %% get image width and height
        %getheight
        function height = getHeight(obj)
            height = obj.height;
        end
        
        %getWidth
        function width = getWidth(obj)
            width = obj.width;
        end
        
        
        %% concatenate image
        % horizontal
        function img = horzcat(img, img2)
            img = img.setImage(cat(2, img.getImage, img2.getimage));
        end
        
        %vertical
        function img = vertcat(img,img2)
            img = img.setImage(cat(1, img.getImage, img2.getImage));
        end
        
        %% display function
        
        function myP = show(Img,mode,varargin)
            
            %persistent blackmagicCardHandle;
            
            if not(exist('mode', 'var'))
                mode = 'plain';
            end
            
            
            switch lower(mode)
                case 'plain'
                    Img.showImage(varargin{:});
                case {'full', 'fullscreen'}
                    fullscreen(Img.getImage,2);
                case {'waveform', 'wfm', 'wfm1','wfm2','wfm3'}
                    %warnings
                    if isempty(Img.colorSpace)
                        Img = Img.setColorSpace('sRGB').setLinear(false);
                        warning('no colorspace detected! automatically set to sRGB')
                    end
                    if Img.getColorSpace == x3PrimaryCS('sRGB') && Img.isLinear
                        Img = Img.deLinearize;
                        warning('sRGB image automatically delinearized')
                    end
                    % Check for graticule
                    if nargin > 2
                        graticule = varargin{1};
                    else
                        graticule = 'PQ';
                    end
                
                %---------------------------------------
                % jImage line 370-434 not yet checked: waveform
                % implementation, graticules, ...
                %---------------------------------------
                
                otherwise
                    myP = xPixel(Img).show(mode,varargin{:});
            end
        end
        
        function obj = read(obj,imgPath,imgName)
            %% xImage.imRead for reading different file formats
                % Currently supported Formats: 'exr' Open EXR (Native cast from half to double)
                %                              'hdr' Radiance format (Native cast to double)
                %                              'png' PNG (values 0-255 or 0-65535 mapped to 0.0-1.0)
                %                              'tif' TIF (values 0-255 or 0-65535 mapped to 0.0-1.0)
                %                              'tif' LAB-TIF
                %
                % Reading OpenEXR relies on the "OpenEXR 1.7.1" from fileexchange
                % Reading Radiance files relies on hdrread.m from MATLAB's image processing toolbox
            if ~exist('imgName','var')
                [imgPath, imgName, imgExt] = fileparts(imgPath);
            else
                [~, imgName, imgExt] = fileparts(imgName);
            end
            idx3 = @(x,a,b,c)x(a,b,c);
            switch lower(imgExt)
                case '.ari'
                    obj = xImage(double(ariread(fullfile(imgPath,[imgName,imgExt]))));
                    obj.isLinear = false;
                
                case '.dpx'
                    [rawImg, metaData] = dpxRead( fullfile( imgPath, [ imgName, imgExt ] ) );
                    obj = xImage( rawImg );
                    
                case '.exr'
                    obj = xImage(double(exrread(fullfile(imgPath,[imgName,imgExt]))));
                    obj.isLinear = true;
                    
                case '.hdr'
                    obj = xImage(double(hdrread(fullfile(imgPath,[imgName,imgExt]))));
                    obj.isLinear = true;
                    
                case {'.png','.jpg'}
                    imageInfo = imfinfo(fullfile(imgPath,[imgName,imgExt]));
                    
                    switch imageInfo.BitDepth
                        case 8
                            GrayChannel = double(imread(fullfile(imgPath,[imgName,imgExt])))/255;
                            obj = xImage(cat(3,GrayChannel,GrayChannel,GrayChannel));
                            
                        case 16
                            GrayChannel = double(imread(fullfile(imgPath,[imgName,imgExt])))/65535;
                            obj = xImage(cat(3,GrayChannel,GrayChannel,GrayChannel));
                            
                        case 24
                            obj = xImage(double(imread(fullfile(imgPath,[imgName,imgExt])))/255);
                            
                        case 48
                            obj = xImage(double(imread(fullfile(imgPath,[imgName,imgExt])))/65535);
                            
                        otherwise
                            disp('Format ist not currently supported')
                    end
                    obj.isLinear = false;
                    
                case {'.tif' '.tiff'}
                    imageInfo = imfinfo(fullfile(imgPath,[imgName,imgExt]));
                    switch imageInfo.BitDepth
                        case 24
                            if ~isfield('PhotometricInterpretation',imageInfo)
                                obj = xImage(idx3(double(imread(fullfile(imgPath,[imgName,imgExt])))/255,':',':',1:1:3));
                            elseif strcmpi(imageInfo.PhotometricInterpretation,'RGB')
                                obj = xImage(idx3(double(imread(fullfile(imgPath,[imgName,imgExt])))/255,':',':',1:1:3));
                            elseif strcmpi(imageInfo.PhotometricInterpretation,'CIELab')
                                % Lab implementation reference: Adobe Photoshop® TIFF Technical Notes March 22, 2002
                                obj = xImage(idx3(double(imread(fullfile(imgPath,[imgName,imgExt]))),':',':',1:1:3));
                                obj = obj.times([100/255 1 1]).plus([0 -128 -128]).setColorSpace('Lab');
                            elseif strcmpi(imageInfo.PhotometricInterpretation,'ICCLab')
                                % Lab implementation reference: Adobe Photoshop® TIFF Technical Notes March 22, 2002
                                obj = xImage(idx3(double(imread(fullfile(imgPath,[imgName,imgExt]))),':',':',1:1:3));
                                obj = obj.times([100/255 1 1]).plus([0 -128 -128]).setColorSpace('Lab');
                            else
                                error(['Unknown Color Space: ', imageInfo.PhotometricInterpretation ,' (PhotometricInterpretation)'])
                            end
                            
                        case {48,64}
                            if ~isfield('PhotometricInterpretation',imageInfo)
                                obj = xImage(idx3(double(imread(fullfile(imgPath,[imgName,imgExt])))/65535,':',':',1:1:3));
                            elseif strcmpi(imageInfo.PhotometricInterpretation,'RGB')
                                obj = xImage(idx3(double(imread(fullfile(imgPath,[imgName,imgExt])))/65535,':',':',1:1:3));
                            elseif strcmpi(imageInfo.PhotometricInterpretation,'CIELab')
                                % Lab implementation reference: Adobe Photoshop® TIFF Technical Notes March 22, 2002
                                obj = xImage(idx3(double(imread(fullfile(imgPath,[imgName,imgExt]))),':',':',1:1:3));
                                obj = obj.times([100/65535 1/256 1/256]).plus([0 -128 -128]).setColorSpace('Lab');
                            elseif strcmpi(imageInfo.PhotometricInterpretation,'ICCLab')
                                % Lab implementation reference: Adobe Photoshop® TIFF Technical Notes March 22, 2002
                                obj = xImage(idx3(double(imread(fullfile(imgPath,[imgName,imgExt]))),':',':',1:1:3));
                                obj = obj.times([100/65280 1/256 1/256]).plus([0 -128 -128]).setColorSpace('Lab');
                            else
                                error(['Unknown Color Space: ', imageInfo.PhotometricInterpretation ,' (PhotometricInterpretation)'])
                            end
                        otherwise
                            %ImageInfo
                            error('Format ist not currently supported.')
                    end    
                otherwise
                    disp(['This Format ' lower(imgExt) ' is not currently supported.'])
            end
            
            obj.isLinear = false;
            obj = obj.setPath(imgPath).setName(imgName)...
                .setHistory(strcat('xImage.imRead: "',fullfile(imgPath,[imgName,imgExt]),'" has been read'));
            %obj.data = gpuArray(obj.data);
        end
        
        %% Write Image
        function img = write(img, format, varargin)
            switch lower(format)
                case 'png' %Implemented 22.12.2007
                    
                    if max(max(max(img.data))) > 1
                        disp('Values above 1 are clipped!')
                        img.data(img.data>1)=1;
                    end
                    
                    if min(min(min(img.data))) < 0
                        disp('Values below 0 are clipped!')
                        img.data(img.data<=0)=0;
                    end
                    
                    %max(max(max(Img.Data)))
                    %min(min(min(Img.Data)))
                    %size(Img.Data)
                    if nargin > 2
                        if varargin{1} == 8
                            imwrite(uint8(img.getImage*255),fullfile(img.path,[img.name '.' format]),'BitDepth',8);
                            disp(['24 bit PNG Image "' img.name '"has been written to:' img.path]);
                        else
                            error(['Second argument ' varargin{1} ' for writing PNGs not known. Try "8" for 8bit files or remove argument!'])                            
                        end
                    else
                        imwrite(uint16(img.getImage*65535),fullfile(img.path,[img.name '.' format]),'BitDepth',16);
                        disp(['48 bit PNG Image "' img.name '"has been written to:' img.path]);
                    end
                case {'jpg','jpeg'} %Implemented 29.09.2017
                    
                    if max(max(max(img.data))) > 1
                        disp('Values above 1 are clipped!')
                        img.data(img.data>1)=1;
                    end
                    
                    if min(min(min(img.data))) < 0
                        disp('Values below 0 are clipped!')
                        img.data(img.data<=0)=0;
                    end
                    
%                     %max(max(max(Img.Data)))
%                     %min(min(min(Img.Data)))
%                     %size(Img.Data)
                    if nargin > 2
                        if varargin{1} == 8
                            imwrite(uint8(img.getImage*255),fullfile(img.path,[img.name '.' format]));
                            disp(['24 bit JPEG Image "' img.name '"has been written to:' img.path]);
                        else
                            error(['Second argument ' varargin{1} ' for writing PNGs not known. Try "8" for 8bit files or remove argument!'])                            
                        end
                    else
                        imwrite(uint16(img.getImage*65535),fullfile(img.path,[img.name '.' format]));
                        disp(['48 bit JPEG Image "' img.name '"has been written to:' img.path]);
                    end
                case {'tif','tiff'} %Implemented 22.12.2007
                    
                    if max(max(max(img.data))) > 1
                        disp('Values above 1 are clipped!');
                        img.data(img.data>1)=1;
                    end
                    
                    if min(min(min(img.data))) < 0
                        disp('Values below 0 are clipped!');
                        img.data(img.data<=0)=0;
                    end
                    
                    imwrite(uint16(img.getImage*65535),fullfile(img.path,[img.name '.' format]),...
                        'Compression','none');
                    disp(['jImage.Write: 48 bit Tiff image "' img.name '"has been written to:' img.path]);
                    
                case 'exr' %Implemented 07.08.2012
                    disp('xImage.Write: Writing 48 bit EXR Image');
                    exrwrite(img.getImage,fullfile(img.path,img.name)); %Write exr Image
                    disp('3x16 bit OpenEXR Image has been written');
                    
                otherwise
                    disp(['Format ', format ,'ist not currently supported.'])
            end
        end
            
       %% eq
        function Flag = eq(Img,Img2)
            if Img.Height == Img2.Height && Img.Width == Img2.Width && min(size(Img.Data) == size(Img2.Data))
                if max(max(abs(Img.getImgLine - Img2.getImgLine)))<10^(-6)
                    Flag = true;
                else
                    Flag = false;
                end
            else
                warning('Can''t check if these Images are the same because Image Size is different');
                Flag = false;
            end
        end
             
    end
    
     %% Private Methods
    methods(Access = private)
        %% Function Plot Image
        function h = showImage(img,varargin)
            
            %% Inits
            if nargin>1
                Title = varargin{1};
            else
                Title = 'xImage - press r,g,b or arrows to analyze image';
            end
            
            % Warnings:
            if isempty(img.colorSpace)
                img = img.setColorSpace('sRGB').setLinear(false);
                warning('Image without colorSpace! Set to sRGB')
            end
            
            if img.getColorSpace ~= xColorSpace.cast('sRGB')
                warning(['Color Space is not sRGB but ' img.getColorSpace.getName '! Consider to convert it before Display!']);
            end

            if img.getColorSpace == x3PrimaryCS('sRGB') && img.isLinear
                img = img.deLinearize;
                warning('sRGB Image automatically deLinearized')
            end
            
            % Fit big images to screen size:
            screenSize = get(0,'ScreenSize');
            dispWidth = img.getWidth;
            dispHeight = img.getHeight;
            if dispHeight > screenSize(4)-160
                dispHeight = min(screenSize(3:4))-160;
                dispWidth = img.getWidth*dispHeight/img.getHeight;
                warning('Image has been resized to fit on your Monitor')
            end
            if dispWidth > screenSize(3)-60
                dispWidth = min(screenSize(3:4))-160;
                dispHeight = img.getHeight*dispWidth/img.getWidth;
                warning('Image has been resized to fit on your Monitor')
            end
            % Show small images bigger: (To do: only integer multiples of original size)
            minSize = [800,800];
            curSize = [dispHeight,dispWidth];
            if curSize(1) < minSize(1) && curSize(2) < minSize(2)
                [~,idx] = max([curSize(1)/minSize(1) curSize(2)/minSize(2)]);
                dispHeight = dispHeight*minSize(idx)/curSize(idx);
                dispWidth = dispWidth*minSize(idx)/curSize(idx);
            end
            
%             % Check Handle
%             if ~exist('h','var')
                 h = figure('Units','pixels','Position',[(screenSize(3)/2-dispWidth/2)...
                     ((screenSize(4)/2-dispHeight/2)) dispWidth dispHeight],'color','k',...
                     'KeyPressFcn', @key_press,'Name',Title);
                 set(gca,'Position',[0 0 1 1]);
%             else
%                 set(0,'CurrentFigure',h)
%             end
            
            % gam = 1;
            offs = 0;
            gam = 1;
            
            refresh_img(img);
            %imshow(Bild)
            axis off          % Remove axis ticks and numbers
            axis image        % Set aspect ratio to obtain square
            
            function refresh_img(Img)
                image(Img.power(gam).plus(offs).clamp(0,1).getImage);
            end
            
            %% Funktion um gedrückte Tasten zu verabreiten:
            
            function key_press(src, event)  %#ok, unused arguments
                %
                %   Jan Reminder how to find out MATLAB key naming:
                %
                %   figure('NumberTitle','off','Menubar','none',...
                %        'Name','Press keys to put event data in Command Window',...
                %        'Position',[560 728 560 200],...
                %        'KeyPressFcn',@(obj,evt)disp(evt));
                
                if strcmpi(event.Modifier,'shift')
                    disp('Shift!')
                end
                
                switch event.Key  %process shortcut keys
                    case 'leftarrow'
                        %disp('LeftArrow')
                        gam = gam - 0.05;
                        refresh_img(img);
                        
                    case 'rightarrow'
                        gam = gam + 0.05;
                        refresh_img(img);
                    case 'uparrow'
                        offs = offs +0.05;
                        refresh_img(img);
                    case 'downarrow'
                        offs = offs -0.05;
                        refresh_img(img);
                    case 'r'
                        refresh_img(img.mtimes([1 0 0;1 0 0; 1 0 0]));
                    case 'g'
                        refresh_img(img.mtimes([0 1 0;0 1 0;0 1 0]));
                    case 'b'
                        refresh_img(img.mtimes([0 0 1;0 0 1;0 0 1]));
                    case 'c'
                        refresh_img(img);
                    case 'space'
                        %play(1/play_fps)
                    case 'backspace'
                        %play(5/play_fps)
                    otherwise
                        disp(['Key' event.Key 'has not been associatted with a function'] )
                end
            end
        end
    end
end

