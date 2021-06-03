classdef x3PrimaryCS < xColorSpace
    %x3PrimaryCS class for representing colorspaces
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        % Encoding Parameters:
        redPrim_xy
        greenPrim_xy
        bluePrim_xy
        encWhite_Yxy
        LPCF = @(x)0;
        PLCF = @(x)0;
        deCorrelationMatrix = eye(3);
    end
    properties (Dependent)
        fromXYZ
        toXYZ
        isInGamut % isInGamut is only valid when called with data in linearized form!
    end
    
    methods
    %% constructor with all colorspace definitions
        function obj = x3PrimaryCS(colorSpaceName)
            if isa(colorSpaceName, 'x3Primary')
                obj = colorSpaceName;
            elseif isa(colorSpaceName, 'char')
                obj.axisName = {'R','G','B'};
                obj.decorrelateAxisName = {'Y', 'Cb', 'Cr'};
                switch lower(colorSpaceName)
                    
                    %% DISPLAYS
                    case {'alexawg', 'awg'}
                        obj.name = 'ALEXAWG';
                        obj.redPrim_xy = [0.6840 0.3130];
                        obj.greenPrim_xy = [0.2210 0.8480];
                        obj.bluePrim_xy = [0.0861 -0.1020];
                        obj.encWhite_Yxy = [1 0.3127 0.3290];

                        obj.LPCF = @(x) logC3( ( x / 36 * ( 65535 - 256 ) + 256 ) / 65535, 800, false);
                        obj.PLCF = @(x)( logC3( x, 800, true ) * 65535 - 256 ) / ( 65535 - 256 ) * 36 ;

                        % Adaptation Parameters assumed without reference
                        obj.adaptWhite_Yxy = obj.encWhite_Yxy;
                        obj.blackLevel = 0;
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                        
                    case 'dcixyz'
                        obj.name = 'DciXYZ';
                        % Encoding Parameters from SMPTE ST 428-1:2006 - D-Cinema Distribution Master (DCDM) - Image Characteristics

                        obj.redPrim_xy = [1 0];
                        obj.greenPrim_xy = [0 1];
                        obj.bluePrim_xy = [0 0];
                        obj.encWhite_Yxy = [52.37 1/3 1/3];
                        obj.LPCF = @(x)(abs(x)>0).*(abs(x).^(1/2.6).*sign(x));
                        obj.PLCF = @(x)sign(x).*abs(x).^(2.6);

                        % Adaption Parameters
                        obj.adaptWhite_Yxy = [48.0 0.3140 0.3510];
                        obj.blackLevel = 0.01; % Or 48/2000 ~ 0.02cd/m2 According to SMPTE RP 431-2:2011 - D-Cinema Quality - Reference Projector and Environment
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                        
                    case 'p3d60'
                        obj.name = 'P3D60';
                        % Encoding Parameters from SMPTE ST 428-1:2006 - D-Cinema Distribution Master (DCDM) - Image Characteristics
                        
                        obj.redPrim_xy = [0.680 0.320];
                        obj.greenPrim_xy = [0.265 0.690];
                        obj.bluePrim_xy = [0.150 0.060];
                        obj.encWhite_Yxy = [48.0 0.3217 0.3378]; % White chromaticities CIE-D60 Todo: Ref!!!
                        obj.LPCF = @(x)(abs(x)>0).*(abs(x).^(1/2.6).*sign(x));
                        obj.PLCF = @(x)sign(x).*abs(x).^(2.6);

                        % Adaption Parameters
                        obj.adaptWhite_Yxy = obj.encWhite_Yxy;
                        obj.blackLevel = 0.01; % Or 48/2000 ~ 0.02cd/m2 According to SMPTE RP 431-2:2011 - D-Cinema Quality - Reference Projector and Environment
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                    
                    case 'p3d65'
                        obj.name = 'P3D65';
                        % Encoding Parameters from SMPTE ST 428-1:2006 - D-Cinema Distribution Master (DCDM) - Image Characteristics
                        
                        obj.redPrim_xy = [0.680 0.320];
                        obj.greenPrim_xy = [0.265 0.690];
                        obj.bluePrim_xy = [0.150 0.060];
                        obj.encWhite_Yxy = [48.0 0.3127 0.3290]; % White chromaticities from sRGB D65
                        obj.LPCF = @(x)(abs(x)>0).*(abs(x).^(1/2.6).*sign(x));
                        obj.PLCF = @(x)sign(x).*abs(x).^(2.6);

                        % Adaption Parameters
                        obj.adaptWhite_Yxy = obj.encWhite_Yxy;
                        obj.blackLevel = 0.01; % Or 48/2000 ~ 0.02cd/m2 According to SMPTE RP 431-2:2011 - D-Cinema Quality - Reference Projector and Environment
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                        
                    case 'rec2020'
                        % Encoding Parameters from Recommendation ITU-R BT.2020 (08/2012)
                        % Parameter values for ultra-high definition television systems for
                        % production and international programme exchange
                        %
                        % White = 100cd/m2 and blackLevel = 0.1 are assumption without reference
                        obj.name = 'Rec2020';
                        obj.redPrim_xy = [0.708 0.292];   % 630 nm
                        obj.greenPrim_xy = [0.170 0.797]; % 532 nm
                        obj.bluePrim_xy = [0.131 0.046];  % 467 nm Compromise what’s currently possible with LED backlit LCD and AMOLED and with Laser displays (http://www.tftcentral.co.uk/articles/content/pointers_gamut.htm#_Toc379132050)
                        obj.encWhite_Yxy = [100 0.3127 0.3290];
                        obj.LPCF = @(x)((x>=0.0181).*(1.0993.*x.^0.45-0.0993)+...
                            (x<0.0181).*4.5.*x);
                        obj.PLCF = @(x)((x>=0.0815).*((x+0.0993)./1.0993).^(1/0.45)+...
                            (x<0.0815).*(x./4.5));
                        obj.deCorrelationMatrix = [0.2627  0.6780   0.0593;...
                                                [ -0.2627 -0.6780 1-0.0593]./1.8814;...
                                                [1-0.2627 -0.6780  -0.0593]./1.4746];

                        % Adaption Parameters assumed without reference
                        obj.adaptWhite_Yxy = obj.encWhite_Yxy;
                        obj.blackLevel = 0.1;
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                        
                    case 'rec709'
                        % Encoding Parameters from RECOMMENDATION ITU-R BT.709-5 -  Parameter values
                        % for the HDTV* standards for production and international programme exchange
                        %
                        % ToDo: LPCF & PLCF have a gap at 0.018 / 0.081 if implemented according to
                        % the recomondation. Find gapless solution!
                        obj.name = 'Rec709';
                        obj.redPrim_xy = [0.6400 0.3300];
                        obj.greenPrim_xy = [0.3000 0.6000];
                        obj.bluePrim_xy = [0.1500 0.0600];
                        obj.encWhite_Yxy = [80 0.3127 0.3290];
                        obj.LPCF = @(x)((x>=0.018).*(1.099.*x.^0.45-0.099)+...
                            (x<0.018).*4.5.*x); % Curve from Spec. Gap at 0.018!!!!
                        obj.PLCF = @(x)((x>=0.081).*((x+0.099)./1.099).^(1/0.45)+...
                            (x<0.081).*(x./4.5));
                        obj.deCorrelationMatrix = [0.2126  0.7152   0.0722;...
                                                [ -0.2126 -0.7152 1-0.0722]./1.8556;...
                                                [1-0.2126 -0.7152  -0.0722]./1.5748];

                        % Adaption Parameters assumed without reference
                        obj.adaptWhite_Yxy = obj.encWhite_Yxy;
                        obj.blackLevel = 0.1;
                        obj.adaptField = obj.adaptWhite_Yxy(1)/100*2; % 2% from "ACES ODT Surround Video Viewing Environment Adjustment Experiment - Draft 6"
                        obj.veilingGlare = [];
                        
                    case 'srgb'
                        % Encoding Parameters from IEC 61966-2-1 and ISO 22028-1:2004
                        obj.name = 'sRGB';
                        obj.redPrim_xy = [0.6400 0.3300];
                        obj.greenPrim_xy = [0.3000 0.6000];
                        obj.bluePrim_xy = [0.1500 0.0600];
                        obj.encWhite_Yxy = [80 0.3127 0.3290];
                        obj.LPCF = @(x)((x>0.0031308).*(1.055.*x.^(1/2.4)-0.055)+...
                            (x<=0.0031308).*12.92.*x);
                        obj.PLCF = @(x)((x>0.04045).*((x+0.055)./1.055).^2.4+...
                            (x<=0.04045).*(x./12.92));

                        % Adaption Parameters from ISO 22028-1:2004
                        obj.adaptWhite_Yxy = obj.encWhite_Yxy;
                        obj.blackLevel = 1;
                        obj.adaptField = 20;
                        obj.veilingGlare = 5.5;
                        
                    case 'xyz'
                        % Encoding Parameters
                        obj.name = 'XYZ';
                        obj.redPrim_xy = [1 0];
                        obj.greenPrim_xy = [0 1];
                        obj.bluePrim_xy = [0 0];
                        obj.encWhite_Yxy = [1 1/3 1/3];
                        obj.LPCF = @(x)x;
                        obj.PLCF = @(x)x;

                        % Adaption Parameters
                        obj.adaptWhite_Yxy = [];
                        obj.blackLevel = 0;
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                        obj.axisName = {'X','Y','Z'};
                    otherwise
                        obj.name = false;
                    end
            else
                error('x3PrimaryCS.Constructor only accepts colorspace names or xColorSpace objects')
            end
        end
        
        %% set/getLPCF
        %setLPCF
        function obj = setLPCF(obj,LPCF)
            if isa(LPCF,'function_handle')
                obj.LPCF = LPCF;
            else
                error('LPCF must be function Handles')
            end
        end
        
        %getLPCF
        function LPCF = getLPCF(obj)
            LPCF = obj.LPCF;
        end
        
        %% set/getPLCF
        %setPLCF
        function obj = setPLCF(obj,PLCF)
            if isa(PLCF,'function_handle')
                obj.PLCF = PLCF;
            else
                error('PLCF must be function Handles')
            end
        end
        
        %getPLCF
        function PLCF = getPLCF(obj)
            PLCF = obj.PLCF;
        end
        
        %% set/get deCorrelationMatrix
        %set decorrelation matrix
        function obj = setDeCorrelationMatrix(obj,deCorrelationMatrix)
            obj.deCorrelationMatrix = deCorrelationMatrix;
        end
        
        %get decorrelation matrix
        function deCorrelationMatrix = getDeCorrelationMatrix(obj)
            deCorrelationMatrix = obj.deCorrelationMatrix;
        end
        
        %% set/get primaries
        %set red primary
        function obj = setRedPrimary(obj,prim)
            obj.redPrim_xy = prim;
        end
        
        %set green primary
        function obj = setGreenPrimary(obj,prim)
            obj.greenPrim_xy = prim;
        end
        
        %set blue primary
        function obj = setBluePrimary(obj,prim)
            obj.bluePrim_xy = prim;
        end
        
        %get red primary
        function redPrimary = getRedPrimary(obj,mode)
            if ~exist('mode', 'var')
                mode = 'xy';
            end
            switch mode
                case 'x'
                    redPrimary = obj.redPrim_xy(1);
                case 'y'
                    redPrimary = obj.redPrim_xy(2);
                case 'xy'
                    redPrimary = obj.redPrim_xy;
                case 'Yxy' %Yxy
                    XYZ = CSMatrix([1 0 0],obj,'XYZ');
                    redPrimary = [XYZ(2) obj.redPrim_xy];
                case 'xyY' %xyY
                    tmp = getRedPrimary(obj,'Yxy');
                    redPrimary = [tmp(2) tmp(3) tmp(1)];
                case 'XYZ'
                    redPrimary = xPixel([1 0 0]).setColorSpace(obj).toXYZ.getPixel;
                otherwise
                    error(['x3PrimaryCS.getRedPrimary: This mode ''' mode...
                        ''' is not upported. Try ''Yxy'' or ''xy'''])
            end
        end
        
        %get green primary
        function greenPrimary = getGreenPrimary(obj,mode)
            if ~exist('mode','var')
                mode = 'xy';
            end
            switch mode
                case 'x'
                    greenPrimary = obj.greenPrim_xy(1);
                case 'y'
                    greenPrimary = obj.greenPrim_xy(2);
                case 'xy'
                    greenPrimary = obj.greenPrim_xy;
                case 'Yxy' %Yxy
                    XYZ = CSMatrix([0 1 0],obj,'XYZ');
                    greenPrimary = [XYZ(2) obj.greenPrim_xy];
                case 'xyY' %xyY
                    tmp = getGreenPrimary(obj,'Yxy');
                    greenPrimary = [tmp(2) tmp(3) tmp(1)];
                case 'XYZ'
                    greenPrimary = xPixel([0 1 0]).setColorSpace(obj).toXYZ.getPixel;
                otherwise
                    error(['x3PrimaryCS.getGreenPrimary: This mode ''' mode...
                        ''' is not upported. Try ''Yxy'' or ''xy'''])
            end
        end
        
        %get blue primary
        function bluePrimary = getBluePrimary(obj,mode)
            if ~exist('mode','var')
                mode = 'xy';
            end
            switch mode
                case 'x'
                    bluePrimary = obj.bluePrim_xy(1);
                case 'y'
                    bluePrimary = obj.bluePrim_xy(2);
                case 'xy'
                    bluePrimary = obj.bluePrim_xy;
                case 'Yxy' %Yxy
                    XYZ = CSMatrix([0 0 1],obj,'XYZ');
                    bluePrimary = [XYZ(2) obj.bluePrim_xy];
                case 'xyY' %xyY
                    tmp = getBluePrimary(obj,'Yxy');
                    bluePrimary = [tmp(2) tmp(3) tmp(1)];
                case 'XYZ'
                    bluePrimary = xPixel([0 0 1]).setColorSpace(obj).toXYZ.getPixel;
                otherwise
                    error(['x3PrimaryCS.getBluePrimary: This mode ''' mode...
                        ''' is not upported. Try ''Yxy'' or ''xy'''])
            end
        end
        
        %% set/get EncodingWhite
        %set encoding white
        function obj = setEncodingWhite(obj,wp,mode)
            if ~exist('mode','var')
                mode = 'XYZ';
            end
            switch lower(mode)
                case 'xyz'
                    tmp = XYZ2Yxy(xColorSpace.getWhitePoint(wp));
                    obj.encWhite_Yxy(1) = tmp(1);
                    obj.encWhite_Yxy(2) = tmp(2);
                    obj.encWhite_Yxy(3) = tmp(3);
                case 'yxy'
                    obj.encWhite_Yxy = wp;
                case 'y'
                    obj.encWhite_Yxy(1) = wp;
                otherwise
               error(['This Mode ' mode ' is not supported. Try XYZ or Y'])     
            end
        end
        
        %get encoding white
        function encodingWhite = getEncodingWhite(obj,mode)
            if ~exist('mode','var')
                mode = 'XYZ';
            end
            switch lower(mode)
                case 'xyz'
                    encodingWhite = Yxy2XYZ(obj.encWhite_Yxy);
                case 'yxz'
                    encodingWhite = obj.encWhite_Yxy;
                case 'y'
                    encodingWhite = obj.encWhite_Yxy(1);
                otherwise
                    error(['Use .getEncodingWhite whith Parameters ''Y'', ''XYZ'' or ''Yxy''. You used: ' mode])
            end
        end
        
        %% get to/from XYZ functions
        
        %get to XYZ
        function fun = get.toXYZ(obj)
            switch lower(obj.name)
                
                case {'dcixyz','p3d60','p3d65','rec2020','rec709','srgb','xyz','alexawg'}
                    % Conversion with ISO 22028-1:2004 blacklevel formula (offset and rescale in linear light)
                    fun = @(x)(obj.getRGB2XYZMatrix*(x*(obj.encWhite_Yxy(1)-obj.blackLevel)+...
                        obj.blackLevel)')';
                otherwise
                    error(['No toXYZ transform available for Color Space Name ' obj.name])
            end
        end
        
        %get from XYZ
        function fun = get.fromXYZ(obj)
            switch lower(obj.name)
                case {'dcixyz','p3d60','p3d65','rec2020','rec709','srgb','xyz','alexawg'}
                    % Conversion with ISO 22028-1:2004 blacklevel formula (offset and rescale in linear light)
                    fun = @(x)((obj.getRGB2XYZMatrix\x')'-obj.blackLevel)/...
                        (obj.encWhite_Yxy(1)-obj.blackLevel);
                otherwise
                    error(['No toXYZ transform available for Color Space Name ' obj.name])
            end
        end
        
         %% get isInGamut (Only works in linear domain!)
        function fun = get.isInGamut(obj)
            switch lower(obj.name)
                case {'dcixyz'}
                    % Negative XYZ values do not represent real colors. 
                    % Y limited to 48/52.37, X&Z limited to 1
                    fun = @(x)( min(x(:,[1 3])<=1,[],2) & x(:,2)<=48/52.37 & min(x >= 0,[],2)); 
                case {'srgb','p3d60','p3d65','rec2020','rec709'}
                    % Everything between 0 and 1
                    fun = @(x)(min(x>=0,[],2) & min(x<=1,[],2));
                case 'xyz'
                    % Negative XYZ values do not represent real colors. 
                    fun = @(x)( min(x>=0,[],2) );
                otherwise
                    error(['No isInGamut check available for Color Space Name ' obj.name])
            end
        end
        
        %% GET RGB2XYZ MATRIX
        function M = getRGB2XYZMatrix(obj)
            %% getRGB2XYZMatrix according to Formulas from:
            % http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
            %
            % Jan Froehlich 2012.03.19:
            % Modified for better numerical stability: No zero-division with primary color spaces
            % that are based on reddish, greenish and blueish primaries (in this order)
            %
            % ToDo: Compare with Computational Color Technology from Henry R. Kang
            
            %% Get Variables from JColorSpace:
            xr = obj.redPrim_xy(1);
            yr = obj.redPrim_xy(2);
            
            xg = obj.greenPrim_xy(1);
            yg = obj.greenPrim_xy(2);
            
            xb = obj.bluePrim_xy(1);
            yb = obj.bluePrim_xy(2);
            
            Yw = obj.encWhite_Yxy(1);
            xw = obj.encWhite_Yxy(2);
            yw = obj.encWhite_Yxy(3);
            
            %% Calculate X,Y,Z of Primaries assuming Luminance of X,Y,Z = 1 for R,G,B respectively.
            Xr = 1;
            Yr = yr / xr;
            Zr = (1.0 - xr - yr) / xr;
            
            Xg = xg / yg;
            Yg = 1;
            Zg = (1.0 - xg - yg) / yg;
            
            zb = 1-xb-yb;
            Xb = xb / zb;
            Yb = yb / zb;
            Zb = 1;
            
            %% Calculate X,Y,Z of Whitepoint
            Xw = xw*Yw / yw;
            % Yw is already there
            Zw = (1.0 - xw - yw)*Yw / yw;
            
            %% Find Scaling values to correct X,Y,Z = 1 for R,G,B respectively assumption:
            % Find Rs,Sg,Sb to solve:
            % (Xr Xg Xb) (Sr) (Xw)
            % (Yr Yg Yb)*(Sg)=(Yw)
            % (Zr Zg Zb) (Sb) (Zw)
            S = [Xr Xg Xb;Yr Yg Yb;Zr Zg Zb]\[Xw; Yw; Zw];
            %Sinstabil = inv([Xr Xg Xb;Yr Yg Yb;Zr Zg Zb])*[Xw; Yw; Zw];
            
            %% Scale Conversion matrix
            M = [S';S';S'].*[Xr Xg Xb;Yr Yg Yb;Zr Zg Zb]/Yw;
            % disp(M)
        end
        
        
        
        
        
        
        
        
        
        
        
        
        %% Create Gamut Boundary descriptor
        function geom = getGamutHull(obj, type, precision)
            %%GETGAMUTHULL creates the Gamut Hull of HullColorSpace
            % types can be point, pointplane, line, triangle, cusp 
            
            %% Debug:
%                  clear classes;
%                  precision = 3; %129;
%                  type = 'point';
%                  obj = x3PrimaryCS('sRGB');
            

            %% Init
            
            % DCIXYZ -> pyramide with cutoff top. gamut hull up to 53cd/m²
            % but legal range only up to 48cd/m². -> all WP's have equal
            % luminance at (48cd)
            if strcmpi(obj.name,'dcixyz')
                error('Special DCIXYZ gamut hull is currently not supported, but easy to implement if needed')
            end

            srcLine = linspace(0,1,precision)';
            
            %% Build 2D Points (Points from 0 ... 1
            %builds one plain plane of an cube with respective precision
            [grid2D(:,:,2), grid2D(:,:,1)] = meshgrid(srcLine,srcLine);
            g2D = reshape(grid2D(1:1:(precision),1:1:(precision),:),[],2);
            
            %%
            switch lower(type)
                case 'point'
                    %% Duplicate 2D Point Plane to 6 Planes in 3D
                    
                    % TODO: 
                        % rework code.
                        % mode 'point' calls 'pointplane' and concatenates
                        % the 6 planes together
                    
                    o = ones((precision)^2,1);
                    z = zeros((precision)^2,1);
                    
                    % create all six sides of the cube
                    g3D = cat(1, ...
                        cat(2,g2D,z), ... %plane 1 (XY front)
                        cat(2,1-g2D,o), ... %plane 2 (XY back)
                        cat(1, ...
                            cat(2,1-g2D,z),cat(2,g2D,o)) ... % plane 3+4
                            *[0 0 1;0 1 0;1 0 0], ... % transformation in space to the sides of the cube
                        cat(1,cat(2,(repmat([0 1],(precision)^2,1)-g2D)*[-1 0; 0 1],z),... %plane 5
                        cat(2,(repmat([1 0],(precision)^2,1)-g2D)*[1 0; 0 -1],o))*... %plane 6
                        [1 0 0;0 0 1;0 1 0]); %transformation to top/bottom
                    
                    geom = xPixel(g3D).setColorSpace(obj);
                    
                case 'pointplane'
                    %% Duplicate 2D Point Plane to 6 Planes in 3D
                    o = ones((precision)^2,1);
                    z = zeros((precision)^2,1);
                    
                    % same as point, but every side of the cube lies as an 
                    %  xImage inside a cell array. needed in
                    % some cases like 'line' mode.
                    geom = {xImage(cat(2,g2D,z))...
                        ,xImage(cat(2,1-g2D,o))...
                        ,xImage(cat(2,1-g2D,z)*[0 0 1;0 1 0;1 0 0])...
                        ,xImage(cat(2,g2D,o)*[0 0 1;0 1 0;1 0 0])...
                        ,xImage(cat(2,(repmat([0 1],(precision)^2,1)-g2D)...
                        *[-1 0; 0 1],z)*[1 0 0;0 0 1;0 1 0])...
                        ,xImage(cat(2,(repmat([1 0],(precision)^2,1)-g2D)...
                        *[1 0; 0 -1],o)*[1 0 0;0 0 1;0 1 0])};
                    
                    for i=1:1:6
                        geom{i} = geom{i}.setSize(precision,precision).setColorSpace(obj);
                    end
                    
                case 'line'
                    pp = obj.getGamutHull('PointPlane',precision);
                    % Concatenate all vertices and accept that edge  vertices are two times included
                    % and corner vertices even three times
                    vertices = cat(1,pp{1}.getPixel, pp{2}.getPixel, pp{3}.getPixel,...
                        pp{4}.getPixel, pp{5}.getPixel, pp{6}.getPixel);
                    
                    % Building Bloch 1: Start setting up index for all starting points
                    bVec = (1:1:(precision-1)*precision)';
                    % Building Block 2: Offset to account for step from plane border to next line
                    offs = reshape(repmat(1:1:precision,(precision-1),1),1,precision*(precision-1))';
                    
                    % Index for one Plane
                    planeIdx = cat(1,cat(2,bVec-1+offs,bVec+offs),cat(2,bVec,bVec+precision),...
                        cat(2,bVec(1:(end-precision+1))-1+offs(1:(end-precision+1)),...
                        bVec(1:(end-precision+1))-1+offs(1:(end-precision+1))+precision+1));
                    
                    % Add offsets to 6 times repmatted plane
                    idx = repmat(planeIdx,6,1) + ...
                        reshape(repmat(0:(precision^2):(precision^2*5),...
                        precision*(precision-1)*2*2 + (precision-1)*(precision-1)*2,1)... % Num lines * 2
                        ,2,precision*(precision-1)*6*2 + (precision-1)*(precision-1)*6)';
                    
                    % Convert to geometry
                    geom = xLine(vertices,idx);
                    
                    %%
                case 'triangle'
                    pp = obj.getGamutHull('PointPlane',precision);
                    % Concatenate all vertices and accept that edge  vertices are two times included
                    % and corner vertices even three times
                    vertices = cat(1,pp{1}.getPixel, pp{2}.getPixel, pp{3}.getPixel,...
                        pp{4}.getPixel, pp{5}.getPixel, pp{6}.getPixel);
                    
                    % Building Bloch 1: Start setting up index for all starting points
                    bVec = (1:1:(precision-1)^2)';
                    % Building Block 2: Offset to account for step from plane border to next line
                    offs = reshape(repmat(1:1:(precision-1),(precision-1),1),1,(precision-1)^2)';
                    
                    % Index for one Plane
                    planeIdx = cat(1,cat(2,bVec+offs-1,bVec+offs,bVec+precision+offs),...
                        cat(2,bVec+offs-1,bVec+precision+offs-1,bVec+precision+offs));
                    
                    % Add offsets to 6 times repmatted plane
                    idx = repmat(planeIdx,6,1) + reshape(repmat(0:(precision^2):(precision^2*5),...
                        (precision-1)^2*2*3,1),3,(precision-1)^2*2*6)';
                    
                    % Convert to geometry
                    geom = xTriangle(vertices,idx);
                    
                case 'cusp'
                    SL = srcLine(1:1:(end-1));
                    o = ones(size(SL));
                    z = zeros(size(SL));
                    
                    cusp = cat(1,cat(2,SL,z,o),cat(2,o,z,1-SL),cat(2,o,SL,z),...
                        cat(2,1-SL,o,z),cat(2,z,o,SL),cat(2,z,1-SL,o));
                    
                    cat(2,cusp,circshift(cusp,[-1 0]))
                    
                    geom = xLine(cat(2,cusp,circshift(cusp,[-1 0])));
                    
                otherwise
                    error('Please specify correct type to deliver. E.g. ''Point'' or ''Line''! ')
            end
            
            %%
            %             %% Check:
            %
            %             % RGB Colors
            %             Colors = cat(2,g3D,ones(length(g3D),1));
            %
            %             myP = jPlot3D('Gamut Plot', 800,1200, 100,100, [0.2 0.2 0.2]);
            %             myP.setView('sRGB');
            %             myP.setAxis('sRGB');
            %
            %             % Colors = cat(2,rand(Geom.getNumElements,3),ones(Geom.getNumElements,1)/1);
            %
            %             switch lower(type)
            %                 case 'point'
            %                     myP.plotPoints(g3D,Colors,0.2);
            %                 case 'line'
            %                     myP.plotLines(geom,Colors);
            %                 case 'triangle'
            %                     myP.plotTriangles(geom,Colors);
            %                 case 'cusp'
            %                     myP.plotLines(geom,Colors);
            %             end
            %
            %             myP.setBackgroundColor([0.5 0.5 0.5]);
            
%             if ~iscell(geom)
%             geom
%             disp('Min,Max')
%             min(geom.data)
%             max(geom.data)
%             end
            
            if strcmpi(type,'line') || strcmpi(type,'triangle')
                %do nothing because lines are made from Pointplanes which have already been
                %converted to the right colorspace
            else
                %% Modify to some special gamut Boundaries:
                switch lower(obj.name)
                    case 'dcixyz'
                        if strcmpi(type,'pointplanes')
                            for i=1:1:6
                                geom{i} = geom{i}.clamp([0 0 0],[1 48/52.37 1].^(1/2.6)); % Assuming perceptual coding
                            end
                        else
                            geom = geom.clamp([0 0 0],[1 48/52.37 1].^(1/2.6)); % Assuming perceptual coding
                        end
                        %% PQ encodings are absolute , so set right Black and White Points in perceptual domain
                    otherwise
                        disp('no special gamut bounrady modification executed')
                end
                
                %% Linearize
                if strcmpi(type,'pointplane')
                    %disp('Linearizeing Pointplanes')
                    for i=1:1:6
                        geom{i} = geom{i}.linearize;
                    end
                elseif strcmpi(type,'cusp')
                    geom = geom.setPoint(jPixel(geom.getPoint).setColorSpace(obj).linearize.getPixel);
                    %disp('Linearizeing CUSP')
                else
                    geom = geom.linearize;
                    %disp('Linearizeing Others')
                end
            end
        end 
        
        %% Implement 'equal' '=='
        function value = eq(obj1,obj2)
            if(strcmpi(obj1.name,obj2.name) && min(obj1.redPrim_xy == obj1.redPrim_xy) &&...
                    min(obj1.greenPrim_xy == obj2.greenPrim_xy) && ...
                    min(obj1.bluePrim_xy == obj2.bluePrim_xy) &&...
                    min(obj1.encWhite_Yxy == obj2.encWhite_Yxy) && ...
                    min(obj1.adaptWhite_Yxy == obj2.adaptWhite_Yxy) &&...
                    isequal(obj1.blackLevel, obj2.blackLevel) &&...
                    isequal(obj1.adaptField, obj2.adaptField) &&...
                    isequal(obj1.veilingGlare, obj2.veilingGlare) &&...
                    strcmpi(char(obj1.LPCF),char(obj2.LPCF)) &&...
                    strcmpi(char(obj1.PLCF),char(obj2.PLCF)) &&...
                    strcmpi(char(obj1.isInGamut),char(obj2.isInGamut)) )
                value = true;
            else
                value = false;
            end
        end
        %% Implement 'not equal' '~='
        function value = ne(obj1,obj2)
            value = not(eq(obj1,obj2));
            
        end
    end
end

