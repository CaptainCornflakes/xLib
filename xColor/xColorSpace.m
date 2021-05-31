classdef xColorSpace
    %xColorSpace class for representing colorspaces
    
    properties (SetAccess = protected)
        name
        axisName
        decorrelateAxisName
        % adaption params:
        adaptWhite_Yxy
        blackLevel
        adaptField
        veilingGlare
        param
    end
    
    methods
        function obj = xColorSpace()
            % init
        end
        
        %% set/get name
        function obj = setName(obj, name)
            obj.name = name;
        end
        
        function Name = getName(obj)
            Name = obj.name;
        end
        
        %% set/get axis name
        %set axis name
        function obj = setAxis(obj, name)
            obj.axisName = name;
        end
        
        %get axis name
        function axisName = getAxisName(obj, channelSelection,correlationState)
            if ~exist('channelSelection', 'var')
                axisName = obj.axisName;
            elseif ~exist('correlationState','var')
                axisName = obj.axisName{channelSelection};
            elseif strcmpi(correlationState, 'decorrelate')
                if isempty(obj.decorrelateAxisName)
                    axisName = obj.axisName(channelSelection);
                else
                    axisName = obj.decorreltateAxisName(channelSelection);
                end
            else
                error('parameter ''channelSelection'' must be int if specified, ''correlationState'' must be ''decorrelate'' if specified.')
            end
        end
        
        %% set/get adaptation white
        %set adaptation white
        function obj = setAdaptationWhite(obj, wp, param)
           if ~exist('param', 'var')
               param = 'XYZ';
           end
           if strcmpi(param,'Y')
               obj.adaptWhite_Yxy(1) = wp;
           elseif strcmpi(param, 'xy')
               obj.adaptWhite_Yxy(2) = wp(1);
               obj.adaptWhite_Yxy(3) = wp(2);
           elseif strcmpi(param, 'yxy')
               obj.adaptWhite_Yxy = wp;
           else
               tmp = XYZ2Yxy(xColorSpace.getWhitePoint(wp));
                obj.adaptWhite_Yxy(1) = tmp(1);
                obj.adaptWhite_Yxy(2)= tmp(2);
                obj.adaptWhite_Yxy(3) = tmp(3);
           end
        end

        %get adaptation white
        function adaptationWhite = getAdaptationWhite(obj,param)
            if ~exist('param','var')
                param = 'XYZ';
            end
            if strcmpi(param,'Y')
                adaptationWhite = obj.adaptWhite_Yxy(1);
            elseif strcmpi(param,'xy')
                adaptationWhite = [obj.adaptWhite_Yxy(2), obj.adaptWhite_Yxy(3)];
            else
                adaptationWhite = Yxy2XYZ(obj.adaptWhite_Yxy);
            end
        end
        
        %% set/get blacklevel
        %set blacklevel
        function obj = setBlackLevel(obj, blackLevel)
            obj.blackLevel = blackLevel;
        end
        
        %get blacklevel
        function blackLevel = getBlackLevel(obj)
            blackLevel = obj.blackLevel;
        end
        
        %% set/get adaptation field
        %set adaptation field
        function obj = setAdaptationField(obj, adaptField)
            obj.adaptField = adaptField;
        end
        
        %get adaptation field
        function adaptField = getAdaptationField(obj)
            adaptField = obj.adaptField;
        end
        
        %% get/setParam
        function obj = setParam(obj,param)
            obj.param = param;
        end
        function param = getParam(obj)
            param = obj.param;
        end
    end
    
    methods (Static)
        %% cast colorspace --> should be moved to the constructor but MATLAB doesn't like it...
        function obj = cast(colorSpace)
            if ischar(colorSpace)
                if ~islogical(x3PrimaryCS(colorSpace).getName)
                    obj = x3PrimaryCS(colorSpace);
                elseif ~islogical(xCamCS(colorSpace).getName)
                    obj = xCamCS(colorSpace);
                elseif ~islogical(xMeasuredCS(colorSpace).getName)
                    obj = xMeasuredCS(colorSpace);
                else
                    error('xPixel.setColorSpace: input must be valid char colorspace name')
                end
            elseif isa(colorSpace,'xColorSpace')
                obj = colorSpace;
            else
                error('xPixel.setColorSpace: Argument "colorSpace" must be either char or xColorSpace')
            end
        end
        
        %% adaptation matrices (bruce lindbloom)
        function m = getAdaptationMatrix(mName)
            switch lower(mName)
                case 'bradford'
                    % source: http://www.brucelindbloom.com/index.html?Eqn_ChromAdapt.html
                    m =  [0.8951000  0.2664000 -0.1614000;...
                        -0.7502000  1.7135000  0.0367000;...
                        0.0389000 -0.0685000  1.0296000];
                case {'vonkries','vankries'}
                    % Source: http://www.brucelindbloom.com/index.html?Eqn_ChromAdapt.html
                    m =  [ 0.4002400  0.7076000 -0.0808100;...
                        -0.2263000  1.1653200  0.0457000;...
                        0.0000000  0.0000000  0.9182200];
                otherwise
                    error(['xBase.getMatrix: Matrix with Name: ' mName ' is not yet known'])
            end
        end
        
        %% whitepoint definitions
        function XYZwhite = getWhitePoint(WhitepointName)
            if isempty(WhitepointName)
                error('You need to specify a Whitepoint like D65_64 for D65 and 1964 observer as the first argument');
            end
            
            % Select Whitepoint
            if isa(WhitepointName,'char')
                switch lower(WhitepointName)
                    case 'a_64'
                        XYZwhite=[1.11144 1 0.35200];
                    case 'a_31'
                        XYZwhite=[1.09850 1 0.35585];
                    case 'c_64'
                        XYZwhite=[0.97285 1 1.16145];
                    case 'c_31'
                        XYZwhite=[0.98074 1 1.18232];
                    case 'd50_64'
                        XYZwhite=[0.96720 1 0.81427];
                    case 'd50_31'
                        XYZwhite=[0.96422 1 0.82521];
                    case 'd55_64'
                        XYZwhite=[0.95799 1 0.90926];
                    case 'd55_31'
                        XYZwhite=[0.95682 1 0.92149];
                    case 'd65_64'
                        XYZwhite=[0.94811 1 1.07304];
                    case 'd65_31'
                        % XYZwhite=[0.95047 1 1.08883]; 
                        % MUST USE ROUNDED VALUES TO PREVENT ROUND-TRIP ERRORS
                        XYZwhite = Yxy2XYZ([1 0.3127 0.3290]);
                    case 'd60_31'
                        XYZwhite=[0.95234 1 1.00800];
                    case 'd75_64'
                        XYZwhite=[0.94416 1 1.20641];
                    case 'd75_31'
                        XYZwhite=[0.94072 1 1.22638];
                    case 'f2_64'
                        XYZwhite=[1.03279 1 0.69027];
                    case 'f2_31'
                        XYZwhite=[0.99186 1 0.67393];
                    case 'f7_64'
                        XYZwhite=[0.95792 1 1.07686];
                    case 'f7_31'
                        XYZwhite=[0.95041 1 1.08747];
                    case 'f11_64'
                        XYZwhite=[1.03863 1 0.65607];
                    case 'f11_31'
                        XYZwhite=[1.00962 1 0.64350];
                    otherwise
                        error('Unknown first argument: "White Reference"\nUse D65_31 for D65 and 1931 2° Observer or ''User'' and an own whitepoint in [X Y Z]');
                end
            elseif isfloat(WhitepointName) && size(WhitepointName,1) == 1 && size(WhitepointName,2) == 3
                XYZwhite = WhitepointName;
            else
                error(['Whitepoint: ' WhitepointName ' not supported. Use "D65_31" for D65 and 1931 2° Observer or 1*3 double'])
            end
        end
    end     
end

