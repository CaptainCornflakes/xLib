
classdef xPixel < xBase
    %xPixel Class for representing pixels
    %   pixel data is stored in the following form:
    %   px1:   [r g b; ...
    %   px2:    r g b; ...
    %   px3:    r g b; ...]
    %   ...    ...
    
    %% PROPERTIES
    properties (SetAccess = protected)
        colorSpace
        isLinear
        alpha
    end
    
    %% METHODS
    methods
        %% constructor method
        function obj = xPixel(varargin)
            if nargin == 0
                % constructor
            elseif nargin == 1
                obj = xPixel();
                obj = obj.setPixel(varargin{:});
            elseif nargin == 2
                obj = xPixel();
                obj = obj.setPixel(varargin{:});
            else
                disp('calling xPixel constructor with more than two args is not supported')
            end 
        end
        
        %% set pixel
            
        function obj = setPixel(obj, obj2, metadata)
            % get back metadata if supplied or init xPixel if not
            if exist('metadata','var') && isfloat(obj2)
                if isa(metadata, 'xPixel')
                    obj = metadata;
                else
                    error('xPixel.setPixel: metadata must be of class xPixel')
                end
            end
            
            if isfloat(obj2) && isreal(obj2) && (size(obj2,2)==3)
                if ~isempty(obj.alpha) && size(obj2,1)~=size(obj.alpha,1)
                    error('pixel data must have the same size as alpha')
                else
                    obj.data = obj2;
                end
            elseif isfloat(obj2) && isreal(obj2) && (size(obj2,2) == 4)
                %indexing hack jan
                idx2 = @(x,a,b)x(a,b);
                obj.data = idx2(obj2,':',1:3);
                obj.alpha = idx2(obj2,':',4);
            elseif isa(obj2,'xImage')
                % Stip metadata from xImages
                obj.data = obj2.data;
                obj.colorSpace = obj2.colorSpace;
                obj.isLinear = obj2.isLinear;
                obj.alpha = obj2.alpha;
                obj.name = obj2.name;
                obj.path = obj2.path;
                obj.history = obj2.history;
            elseif isa(obj2,'xPoint')
                obj.data = obj2.data;
                obj.name = obj2.name;
                obj.path = obj2.path;
                obj.history = obj2.history;
            elseif isa(obj2,'xLine')
                % Only vertices copied, idx lost!
                obj.data = obj2.data;
                obj.name = obj2.name;
                obj.path = obj2.path;
                obj.history = obj2.history;
            elseif isa(obj2,'xTriangle')
                % Only vertices copied, idx lost!
                obj.data = obj2.data;
                obj.name = obj2.name;
                obj.path = obj2.path;
                obj.history = obj2.history;
            elseif isa(obj2, 'xPixel')
                % xPixel already there
                obj = obj2;
            else
                error('Calling xPixel.setPixel is currently only supported for single or double n*3 or n*4 vectors. Try xImage for n*m*3')
            end
        end
        
        %% get pixel
        function[pixel,metadata] = getPixel(obj,varargin)
            if isempty(obj.data)
                warning('pixel data is empty')
                pixel = obj.data;
                metadata = obj;
            elseif nargin > 1
                pixel = obj.data(:,varargin{1});
                metadata = obj;
            else
                pixel = obj.data;
                metadata = obj;
            end
        end
        
        %% set/get/has alpha
        
        % setAlpha
        function obj = setAlpha(obj,alpha)
            if isfloat(alpha) && isreal(alpha) && (size(alpha,2)==1)
                if ~isempty(obj.data) && size(alpha,1)~=size(obj.data,1)
                    error('alpha must have the same size as pixel data')
                else
                    obj.alpha = alpha;
                end
            else
                error('calling xPixel.setPixel is currently only supported for single or double n*3 or n*4 vectors')
            end
        end
        
        % getAlpha
        function alpha = getAlpha(obj)
            if isempty(obj.alpha)
                error('alpha data is empty')
            else
                alpha = obj.alpha;
            end
        end
        
        % hasAlpha
        function hasAlpha =hasAlpha(obj)
            if isempty(obj.alpha)
                hasAlpha = false;
            else
                hasAlpha = true;
            end
        end
        
        %% set/get colorspace
        % setColorSpace
        function obj = setColorSpace(obj,colorSpace)
            obj.colorSpace = xColorSpace.cast(colorSpace);
            obj = obj.setHistory(['Color space set to ' obj.colorSpace.getName]);
        end
        
        % getColorSpace
        function colorSpace = getColorSpace(obj)
            if isempty(obj.colorSpace)
                error('xPixel.getColorSpace: Field .colorSpace is empty')
            else
                colorSpace = obj.colorSpace;
            end
        end
        
        %% set Linear
        function obj = setLinear(obj,isLinear)
            if ~exist('isLinear','var')
                isLinear = true;
            end
            obj.isLinear = isLinear;
        end
        %% is inGamut
        function idx = isInGamut(obj)
        % input is an xPixel or xImage obj with a defined x3PrimaryCS
        % output is an array with a logical for each input pixel
        % 0 == px is OOG (out of gamut)
        % 1 == px is in gamut
            if ~obj.isLinear
                error('isInGamut only works with linearized images')
            end
            idx = obj.colorSpace.isInGamut(obj.getPixel);
        end
        
        %% conversion from perceptual to linear coding
        function obj = linearize(obj)
            if isa(obj.getColorSpace,'x3PrimaryCS')
                if obj.isLinear
                    warning('xPixel.linearize: Image is already linear!')
                end
                obj = obj.setPixel(obj.getColorSpace.PLCF(obj.getPixel));
                obj.isLinear = true;
            elseif isa(obj.getColorSpace,'xCamCS')
                warning('ignoring linearization because color space is a color appearance model.');
            else
                error('linearize is only defined for 3 primary based color Spaces');
            end
        end
        
        %% conversion from linear to perceptual coding
        function obj = deLinearize(obj)
            if isa(obj.getColorSpace,'x3PrimaryCS')   
                if ~obj.isLinear
                    warning('xPixel.deLinearize: Image is already perceptually coded!')
                end
                obj = obj.setPixel(obj.getColorSpace.LPCF(obj.getPixel));
                obj.isLinear = false;
            elseif isa(obj.getColorSpace,'xCamCS')
                warning('Ignoring delinearization because color space is a color appearance model.');
            else
                error('DeLinearize is only defined for 3 primary based Color Spaces');
            end
        end
        
        
         %% Convert to deCorrelated Color space
        function obj = deCorrelate(obj)
            if ~isa(obj.getColorSpace,'x3PrimaryCS')
                warning('deCorrelate is only defined for 3 primary based colorspaces and will not be executed');
            else
                obj = obj.mtimes(obj.getColorSpace.getDeCorrelationMatrix);
            end
        end
        function obj = correlate(obj)
            if ~isa(obj.getColorSpace,'x3PrimaryCS')
                warning('correlate is only defined for 3 primary based colorspaces and will not be executed');
            else
                obj = obj.mldivide(obj.getColorSpace.getDeCorrelationMatrix);
            end
        end
        %% Apply function to .data
        function obj = toXYZ(obj)
            obj.data = obj.colorSpace.toXYZ(obj.data);
            obj = obj.setHistory(['converted from ' obj.getColorSpace.getName ' to XYZ']);
        end  
        %% Apply function to .data
        function obj = fromXYZ(obj)
            obj.data = obj.colorSpace.fromXYZ(obj.data);
            obj = obj.setHistory(['converted from XYZ to ' obj.getColorSpace.getName]);
        end
        %% From HSV and to HSV
        function obj = toHSV(objIn)
            error('toHSV is not Verified')
            obj = objIn;
            objMin = min(objIn.data,[],2);
            objMax = max(objIn.data,[],2);
            objC = objMax - objMin;
            % Calculate hue
            obj.data(objC==0,1) = NaN;
            idx = objMax==objIn.data(:,1);
            obj.data(idx,1) = mod((objIn.data(idx,2)-objIn.data(idx,3))./objC(idx),6);
            idx = objMax==objIn.data(:,2);
            obj.data(idx,1) = (objIn.data(idx,3)-objIn.data(idx,1))./objC(idx)+2;
            idx = objMax==objIn.data(:,3);
            obj.data(idx,1) = (objIn.data(idx,1)-objIn.data(idx,2))./objC(idx)+4;
            % Calculate Saturation
            idx = objMax==0;
            obj.data(idx,2) = 0;
            obj.data(~idx,2) = objC(~idx)./objMax(~idx);
            obj.data(:,3) = objMax;
            % Set history
            obj = obj.setHistory(['Converted from ' obj.getColorSpace.getName ' to HSL']);
        end  
        function obj = fromHSL(objIn)
            error('fromHSL is not Verified')
            obj.data = obj.colorSpace.fromXYZ(obj.data);
            obj = obj.setHistory(['Converted from HSL to ' obj.getColorSpace.getName]);
        end
        
         

        %% ---TODO---
        % Quantize to given bitdepth and given max line247
        
        
        %% select
        function obj = select(obj,idx)
            if islogical(idx)
                if size(idx,1) == obj.numElements && size(idx,2) == 1
                    obj.data = obj.data(idx,:);
                    obj = xPixel(obj); % Cast to xPixel because height and width from xImage are probably lost
                else
                    error('xPixel.select: Index must be of obj.numElements*1 size')
                end
            elseif isnumeric(idx) && size(idx,2) == 1
                    obj.data = obj.data(idx,:);
                    obj = xPixel(obj); % Cast to xPixel because height and width from xImage are probably lost
            else
                error('xPixel.select: Index must be logical or numeric')
            end
        end
        
        
        %% insert
        function obj = insert(obj, obj2, idx)
        % overrides existing pixel data at index
        % idx must be an n*1 array with logical data inside
            if islogical(idx) && isa(obj2,'xPixel')
                if size(idx,1) == obj.getNumElements && size(idx,2) == 1 && sum(idx) == obj2.getNumElements
                    obj.data(idx,:) = obj2.data;
                else
                    error(['xPixel.insert: Index must be of ' num2str(obj.numElements) '*1 size (is ' ...
                        num2str(size(idx,1)) '*' num2str(size(idx,2))  ') and have ' ...
                        num2str(obj2.numElements) ' "true" values (is ' num2str(sum(idx)) ')'])
                end
            elseif islogical(idx) && isreal(obj2)
                if (size(obj2,1) == 1) && (size(obj2,2) == 3)
                    obj.data(idx,:) = repmat(obj2,[sum(idx(:)),1]);
                else
                    error('xPixel.insert: static insert value must be a 1*3 vector')
                end
                    
            elseif isnumeric(idx)
                error('Not Yet Implemented')
            else
                error('xPixel.insert: Index must be logical or numeric')
            end
        end
        
        %% clip to Value
        function obj = clipToValue(obj, lowerClip, upperClip, lowerTargetValue, upperTargetValue)
                obj.data( max( obj.data, [], 2 ) > upperClip ) = upperTargetValue;
                obj.data( min( obj.data, [], 2 ) < lowerClip ) = lowerTargetValue;
        end
        
        %% display function
        function myP = show(Img,mode,varargin)
            % show - function that visualizes jPixel and jImages
            
            if not(exist('mode','var'))
                mode = 'uvchart';
            end
            
            if isempty(Img.colorSpace)
                Img = Img.setColorSpace('sRGB').setLinear(true);
                warning('xPixel.show: Image with no color space. Assuming sRGB linear coded!')
            end
            
            myP = 0;

            switch lower(mode)
                case {'h','history'}
                    disp(cellstr(Img.getHistory));
                case 'plain'
                    Img.showImage(varargin{:});
                    
%                 case {'xychart','xy'}
%                     xyChart2(Img,varargin{:});
                case {'uvchart','uv'}
                    uvChart(Img,varargin{:});
                case {'gamut','3d'}
                    if nargin>2
                        ViewColorSpace = xColorSpace.cast(varargin{1});
                    else
                        ViewColorSpace = Img.getColorSpace;
                    end
                    
                    if nargin>3
                        PointSize = varargin{2};
                    else
                        PointSize = 3;
                    end
                    
                    %%
                    if isempty(Img.name)
                        Img.name = 'Image without a name';
                    end
                    
                    %% Create new figure if hold is not on
                    if ~ishold
                    figure('name',['Gamut Plot of ' Img.getName ' in ' ViewColorSpace.getName ...
                        ' Color Space']);
                    end
                    %% Show with guessed colors
                    myP = xPoint(Img).show(Img.linearize.toXYZ.setColorSpace(x3PrimaryCS('sRGB')...
                        .setEncodingWhite(Img.getColorSpace.getEncodingWhite('Y'),'Y')...
                        .setAdaptationWhite(Img.getColorSpace.getAdaptationWhite('Y'),'Y')...
                        ).fromXYZ.deLinearize);
                    xlabel(Img.getColorSpace.getAxisName(1))
                    ylabel(Img.getColorSpace.getAxisName(2))
                    zlabel(Img.getColorSpace.getAxisName(3))
                    
                case {'3d-compare'}
                    %%
                    
                    if nargin>2
                        Img2 = varargin{1};
                    else
                        error('xPixel.show: Mode ''3d-compare'' must be used with additional image as second argument')
                    end
                    
                    if nargin>3
                        ViewColorSpace = xColorSpace.cast(varargin{2});
                    else
                        ViewColorSpace = Img.getColorSpace;
                    end
                    
                    if nargin>4
                        PointSize = varargin{3};
                    else
                        PointSize = 3;
                    end
                    lineSize = 1;

                    %%
                    if isempty(Img.name)
                        Img.name = 'Image without a name';
                    end
                        
                    myP = xPlot3D( ['Gamut Plot of ' Img.getName ' in ' ViewColorSpace.getName ...
                        ' Color Space'],1400, 1800, 1400, 100, [0.5 0.5 0.5]);
                    %%
                    myP.setView(ViewColorSpace);
                    %%
                    myP.setAxis(ViewColorSpace);
%                     %%
%                     if strcmpi(Img.getColorSpace.getName,'lab')
%                         myP.plotGamutGrid(jColorSpace.cast('sRGB'));
%                         warning('sRGB-Gamut-Grid for illustration purposes...')
%                     elseif strcmpi(Img.getColorSpace.getName,'ipt')
%                         myP.plotGamutGrid(jColorSpace.cast('sRGB'));
%                         warning('sRGB-Gamut-Grid for illustration purposes...')
%                     elseif strcmpi(Img.getColorSpace.getName,'iptpq')
%                         myP.plotGamutGrid(jColorSpace.cast('sRGB'));
%                         warning('sRGB-Gamut-Grid for illustration purposes...')
%                     else
%                         myP.plotGamutGrid(Img.getColorSpace);
%                     end
                    %%
                    % disp(ViewColorSpace)
                    %Coords = Img.toXYZ.setColorSpace(ViewColorSpace)...
                    %    .times(ViewColorSpace.getAdaptionWhite('Y')/Img.getColorSpace.getAdaptionWhite('Y'))...
                    %    .fromXYZ.getPixel;
                    Coords = Img.getPixel;
                    %%
                    Colors = Img.toXYZ.setColorSpace(x3PrimaryCS('sRGB'))...
                        .times(x3PrimaryCS('sRGB').getAdaptionWhite('Y')/Img.getColorSpace.getAdaptionWhite('Y'))...
                        .fromXYZ.getPixel;
                    Colors = cat(2,Colors,ones(length(Colors),1));
                    %%
                    myP.plotPoints(Coords,Colors,PointSize);
                    
                    %% Now the second Image:
                    Coords2 = Img2.getPixel;
                    %%
                    Colors2 = Img2.toXYZ.setColorSpace(x3PrimaryCS('sRGB'))...
                        .times(x3PrimaryCS('sRGB').getAdaptionWhite('Y')/Img.getColorSpace.getAdaptionWhite('Y'))...
                        .fromXYZ.getPixel;
                    Colors2 = cat(2,Colors2,ones(length(Colors2),1));
                    %%
                    myP.plotPoints(Coords2,Colors2,PointSize);
                    %% Now connect the points that are not at the same position
                    
                    myP.plotLines(cat(2,Coords,Coords2),ones(size(Colors)),lineSize);
                
                    
                case 'help'
                    disp(' ''plain''          - show img ');
                    disp(' ''uvchart'',''uv'' - show on uv chart ')
                    disp(' ''xychart'',''xy'' - show on xy chart ')
                    disp(' ''gamut'',''3d''   - show in 3D plot ')
                    disp(' ''3d-compare''     - needs additional img, compares in 3d plot ')
                    disp(' ''h'',''history''  - get history ');
                    
                otherwise
                    disp(['Display type',mode,'ist not currently supported.'])
            end
        end
         
    end
end

