classdef xCamCS < xColorSpace
    %xCamCS for representing color appearance models
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
    end
    
    properties (Dependent = true)
        toXYZ
        fromXYZ
    end
    
    methods
        %% CONSTRUCTOR
        function obj = xCamCS(colorSpaceName)
            if isa(colorSpaceName, 'xCamCS')
                obj = colorSpaceName;
            elseif isa(colorSpaceName, 'char')
                switch lower(colorSpaceName)
                    
                    case 'oklab'
                        obj.name = 'OKLAB';
                        obj.axisName = {'L', 'a', 'b'};
                        obj.adaptWhite_Yxy = [1 0.3127 0.3290];
                        obj.blackLevel = 0;
                        obj.adaptField = 0;
                        obj.veilingGlare = [];
                    
                    case 'ciecam02'
                        obj.name = 'CIECAM02';
                        obj.axisName = {'J', 'Ca', 'Cb'};
                        obj.adaptWhite_Yxy = [1 0.3127 0.3290];
                        obj.blackLevel = 0;
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                        
                    case 'ciecam02hpe'
                        obj.name = 'CIECAM02HPE';
                        obj.axisName = {'J','Ca','Cb'};
                        obj.adaptWhite_Yxy = [1 0.3127 0.3290];
                        obj.blackLevel = 0;
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                        
                    case 'ictcp'
                        obj.name = 'IPTPQflex';
                        obj.axisName = {'I','Ct','Cp'};
                        obj.adaptWhite_Yxy = [10000 0.3127 0.3290];
                        obj.blackLevel = 0;
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                        obj.param = {[0.92 0.04 0.04;...
                                      0.04 0.92 0.04;...
                                      0.04 0.04 0.92],...
                            [2048  2048     0;...
                             6610 -13613 7003;...
                            17933 -17390 -543] ./ 4096};
                            % LMS2LMS mx, LMS2IPT mx
                            
                    case 'lab'
                        obj.name = 'Lab';
                        obj.axisName = {'L','a','b'};
                        obj.adaptWhite_Yxy = [1 0.3127 0.3290];
                        obj.blackLevel = 0;
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                    
                    case 'lms'
                        obj.name = 'LMS';
                        obj.axisName = {'L','M','S'};
                        obj.adaptWhite_Yxy = [1 0.3127 0.3290];
                        obj.blackLevel = 0;
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                    
                    case 'ipt'
                        obj.name = 'IPT';
                        obj.axisName = {'I','P','T'};
                        obj.adaptWhite_Yxy = [100 0.3127 0.3290];
                        obj.blackLevel = 0;
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                        
                    case 'iptc'
                        obj.name = 'IPTc';
                        obj.axisName = {'I','P','T'};
                        obj.adaptWhite_Yxy = [100 0.3127 0.3290];
                        obj.blackLevel = 0;
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                        obj.param = [0.02 0.02 0.02];
                        
                    case 'hdript'
                        obj.name = 'hdrIPT';
                        obj.axisName = {'I','P','T'};
                        obj.adaptWhite_Yxy = [100 0.3127 0.3290];
                        obj.blackLevel = 0;
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                        
                    case 'hdriptc'
                        obj.name = 'hdrIPTc';
                        obj.axisName = {'I','P','T'};
                        obj.adaptWhite_Yxy = [100 0.3127 0.3290];
                        obj.blackLevel = 0;
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                        
                    case 'iptpq'
                        obj.name = 'IPTPQ';
                        obj.axisName = {'I','P','T'};
                        obj.adaptWhite_Yxy = [10000 0.3127 0.3290];
                        obj.blackLevel = 0;
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                        
                    case 'iptpqc'
                        obj.name = 'IPTPQc';
                        obj.axisName = {'I','P','T'};
                        obj.adaptWhite_Yxy = [10000 0.3127 0.3290];
                        obj.blackLevel = 0;
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                        obj.param = [0.02 0.02 0.02];
                        
                    case 'yuv1976'
                        obj.name = 'Yuv1976';
                        obj.axisName = {'Y','u','v'};
                        obj.adaptWhite_Yxy = [1 0.333333 0.333333];
                        obj.blackLevel = 0;
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                        
                    case 'yxy'
                        obj.name = 'Yxy';
                        obj.axisName = {'Y','x','y'};
                        obj.adaptWhite_Yxy = [1 0.333333 0.333333];
                        obj.blackLevel = 0;
                        obj.adaptField = [];
                        obj.veilingGlare = [];
                        
                    otherwise    
                        obj.name = false;
                end
            else
                error('xCamCS Constructor only accepts color space names or xCamCS objects ')
            end
        end
        
        %% 
        function fun = get.toXYZ(obj)
            switch lower(obj.name)
                
                case 'oklab'
                    % todo: check whitepoint and directly raise error if wrong set.
                    fun = @(x)OKLAB2XYZ(x);
                
                case 'ciecam02'
                    fun = @(x)CIECAM022XYZ(x,obj.getAdaptationWhite,...
                        obj.adaptField,obj.adaptField,'dim');
                    
                case 'ciecam02hpe'
                    fun = @(x)CIECAM122XYZ(x,obj.getAdaptationWhite,...
                        obj.adaptField,obj.adaptField,'dim');
                    
                case 'lab'
                    fun = @(x)Lab2XYZ(x,obj.getAdaptationWhite);
                    
                case 'lms'
                    refWP = obj.getAdaptationWhite/obj.getAdaptationWhite('Y');
                    if  (refWP) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.toXYZ: LMS is only defined for D65 Whitepoint')
                    end
                    XYZ65_2_LMS = [ 0.38971 -0.22981 0;...
                                    0.68898  1.18340 0;...
                                   -0.07868  0.04641 1 ];
                    
                    % XYZ_2_LMS neede to be normalized before to WP
                    WPD65 = xColorSpace.getWhitePoint('d65_31') * XYZ65_2_LMS;
                    XYZ65_2_LMS = (XYZ65_2_LMS * diag(([1 1 1] ./ WPD65 .* obj.getAdaptationWhite('Y'))))';
                    fun = @(x)(XYZ65_2_LMS\(x'))';
                    
                case 'ipt'
                    if  (obj.getAdaptationWhite/obj.getAdaptationWhite('Y')) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.toXYZ: IPT is only defined for D65 Whitepoint')
                    end
                    fun = @(x)IPT2XYZ(x,obj.getAdaptationWhite);
                    
                case 'iptc'
                    if  (obj.getAdaptationWhite/obj.getAdaptationWhite('Y')) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.toXYZ: IPTc is only defined for D65 Whitepoint')
                    end
                    fun = @(x)IPTc2XYZ(x,obj.getAdaptationWhite,obj.param);
                    
                case 'hdript'
                    if  (obj.getAdaptationWhite/obj.getAdaptationWhite('Y')) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.toXYZ: hdrIPT is only defined for D65 Whitepoint')
                    end
                    fun = @(x)hdrIPT2XYZ(x,obj.getAdaptationWhite);
                                     
                case 'iptpq'
                    refWP = obj.getAdaptationWhite/obj.getAdaptationWhite('Y').*10000;
                    fun = @(x)IPTPQ2XYZ(x,refWP);
                    if  (refWP/10000) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.toXYZ: IPT is only defined for D65 Whitepoint')
                    end
                    
                case 'iptpqc'
                    refWP = obj.getAdaptationWhite/obj.getAdaptationWhite('Y').*10000;
                    fun = @(x)IPTPQC2XYZ(x,refWP,obj.param);
                    if  (refWP/10000) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.toXYZ: IPT is only defined for D65 Whitepoint')
                    end

                case 'yuv1976'
                    fun = @(x)Yuv19762XYZ(x);
                    
                case 'yuvdoubleprime'
                    fun = @(x)YuvDoublePrime2XYZ(x);
                    
                case 'yxy'
                    %error('Yxy to XYZ not yet implemented')
                    fun = @(x)Yxy2XYZ(x);
                    
                case 'ypqxy'
                    error('YPQxy to XYZ not yet implemented')
                    fun = @(x)(x);
                    
                otherwise
                    error(['xCamCS.toXYZ: This name is not yet implemented: ' obj.name])
            end
        end
        %%
        function fun = get.fromXYZ(obj)
            switch lower(obj.name)
                case 'oklab'
                    fun = @(x)XYZ2OKLAB(x);
                
                case 'ciecam02'
                    fun = @(x)XYZ2CIECAM02(x,obj.getAdaptationWhite,...
                        obj.adaptField,obj.adaptField,'dim');
                case 'ciecam02c'
                    fun = @(x)XYZ2CIECAM02c(x,obj.getAdaptationWhite,...
                        obj.adaptField,obj.adaptField,'dim');
                case 'ciecam02hpe'
                    fun = @(x)XYZ2CIECAM12(x,obj.getAdaptationWhite,...
                        obj.adaptField,obj.adaptField,'dim');
                case 'lab'
                    fun = @(x)XYZ2Lab(x,obj.getAdaptationWhite);
               
                case 'lms'
                    refWP = obj.getAdaptationWhite/obj.getAdaptationWhite('Y').*10000;
                    if (refWP/10000) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.fromXYZ: IPT is only defined for D65 Whitepoint')
                    end
                    XYZ65_2_LMS = [ 0.38971 -0.22981 0;...
                                    0.68898  1.18340 0;...
                                   -0.07868  0.04641 1 ];
                    
                    % XYZ_2_LMS neede to be normalized before to WP
                    WPD65 = xColorSpace.getWhitePoint('d65_31') * XYZ65_2_LMS;
                    XYZ65_2_LMS = (XYZ65_2_LMS * diag(([1 1 1] ./ WPD65 ./ obj.getAdaptationWhite('Y'))))';
                    
                    fun = @(x)(XYZ65_2_LMS*x')';
                case 'lmsd'
                    refWP = obj.getAdaptationWhite/obj.getAdaptationWhite('Y').*10000;
                    if (refWP/10000) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.fromXYZ: IPT is only defined for D65 Whitepoint')
                    end
                    XYZ65_2_LMS = [ 0.38971 -0.22981 0;...
                                    0.68898  1.18340 0;...
                                   -0.07868  0.04641 1 ];
                    
                    % XYZ_2_LMS neede to be normalized before to WP
                    WPD65 = xColorSpace.getWhitePoint('d65_31') * XYZ65_2_LMS;
                    XYZ65_2_LMS = (XYZ65_2_LMS * diag(([1 1 1] ./ WPD65 ./ obj.getAdaptationWhite('Y'))))';
                    
                    fun = @(x)([1/3, 1/3, 1/3;...
                                2/3, -1/3, -1/3;...
                               -1/5, -1/5, 2/5]*(XYZ65_2_LMS*x'))';
                case 'lmspq'
                    refWP = obj.getAdaptationWhite/obj.getAdaptationWhite('Y').*10000;
                    if (refWP/10000) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.fromXYZ: IPT is only defined for D65 Whitepoint')
                    end
                    XYZ65_2_LMS = [ 0.38971 -0.22981 0;...
                                    0.68898  1.18340 0;...
                                   -0.07868  0.04641 1 ];
                    
                    % XYZ_2_LMS neede to be normalized before to WP
                    WPD65 = xColorSpace.getWhitePoint('d65_31') * XYZ65_2_LMS;
                    XYZ65_2_LMS = (XYZ65_2_LMS * diag(([1 1 1] ./ WPD65)))';
                    
                    fun = @(x)L2PQ(XYZ65_2_LMS*x')';
                    
                case 'lmspqc'
                    refWP = obj.getAdaptationWhite/obj.getAdaptationWhite('Y').*10000;
                    if (refWP/10000) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.fromXYZ: IPT is only defined for D65 Whitepoint')
                    end
                    XYZ65_2_LMS = [ 0.38971 -0.22981 0;...
                                    0.68898  1.18340 0;...
                                   -0.07868  0.04641 1 ];
                    
                    % XYZ_2_LMS neede to be normalized before to WP
                    WPD65 = xColorSpace.getWhitePoint('d65_31') * XYZ65_2_LMS;
                    XYZ65_2_LMS = (XYZ65_2_LMS * diag(([1 1 1] ./ WPD65)))';
                    
                    c1 = obj.param(1);
                    c2 = obj.param(2);
                    c3 = obj.param(3);
                    
                    fun = @(x)L2PQ([(1-2*c1), c1, c1;
                                     c2, (1-2*c2), c2;...
                                     c3, c3, (1-2*c3)]*XYZ65_2_LMS*x')';
                                     
                case 'lmspqcj'
                    refWP = obj.getAdaptationWhite/obj.getAdaptationWhite('Y').*10000;
                    if (refWP/10000) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.fromXYZ: IPT is only defined for D65 Whitepoint')
                    end
                    XYZ65_2_LMS = [ 0.38971 -0.22981 0;...
                                    0.68898  1.18340 0;...
                                   -0.07868  0.04641 1 ];
                    
                    % XYZ_2_LMS neede to be normalized before to WP
                    WPD65 = xColorSpace.getWhitePoint('d65_31') * XYZ65_2_LMS;
                    XYZ65_2_LMS = (XYZ65_2_LMS * diag(([1 1 1] ./ WPD65)))';
                    
                    c1 = obj.param(1);
                    c2 = obj.param(2);
                    c3 = obj.param(3);
                    c4 = obj.param(4);
                    c5 = obj.param(5);
                    c6 = obj.param(6);
                    
                    fun = @(x)L2PQ([(1-c1-c2), c1, c2;
                                     c3, (1-c3-c4), c4;...
                                     c5, c6, (1-c5-c6)]*XYZ65_2_LMS*x')';
                case 'lmss'
                    refWP = obj.getAdaptationWhite/obj.getAdaptationWhite('Y').*10000;
                    if (refWP/10000) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.fromXYZ: IPT is only defined for D65 Whitepoint')
                    end
                    XYZ65_2_LMS = [ 0.38971 -0.22981 0;...
                                    0.68898  1.18340 0;...
                                   -0.07868  0.04641 1 ];
                    
                    % XYZ_2_LMS neede to be normalized before to WP
                    WPD65 = xColorSpace.getWhitePoint('d65_31') * XYZ65_2_LMS;
                    XYZ65_2_LMS = (XYZ65_2_LMS * diag(([1 1 1] ./ WPD65)))';
                    
                    %% Sigmoid curve
                    lRef = 10.^(-4:0.5:4);
                    pqRef = L2PQ(lRef);
                    pqRef(15) = 0.74;
                    pqRef(16) = 0.788;
                    pqRef(17) = 0.8;
                    fun = @(x)interp1(lRef,pqRef,(XYZ65_2_LMS*x'),'cubic')';
                case 'ipt'
                    if (obj.getAdaptationWhite/obj.getAdaptationWhite('Y')) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.fromXYZ: IPT is only defined for D65 Whitepoint')
                    end
                    fun = @(x)XYZ2IPT(x,obj.getAdaptationWhite);
                case 'iptc'
                    if (obj.getAdaptationWhite/obj.getAdaptationWhite('Y')) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.fromXYZ: IPTc is only defined for D65 Whitepoint')
                    end
                    fun = @(x)XYZ2IPTc(x,obj.getAdaptationWhite,obj.param);
                case 'hdript'
                    if (obj.getAdaptationWhite/obj.getAdaptationWhite('Y')) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.fromXYZ: hdrIPT is only defined for D65 Whitepoint')
                    end
                    fun = @(x)XYZ2hdrIPT(x,obj.getAdaptationWhite);
                case'iptpq'
                    refWP = obj.getAdaptationWhite/obj.getAdaptationWhite('Y').*10000;
                    fun = @(x)XYZ2IPTPQ(x,refWP);
                    if (refWP/10000) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.fromXYZ: IPT is only defined for D65 Whitepoint')
                    end
                case'iptpqc'
                    refWP = obj.getAdaptationWhite/obj.getAdaptationWhite('Y').*10000;
                    fun = @(x)XYZ2IPTPQC(x,refWP,obj.param);
                    if (refWP/10000) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.fromXYZ: IPT is only defined for D65 Whitepoint')
                    end

                case'iptpqflex'
                    refWP = obj.getAdaptationWhite/obj.getAdaptationWhite('Y').*10000;
                    fun = @(x)XYZ2IPTPQflex(x,refWP,obj.param);
                    if (refWP/10000) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.fromXYZ: IPT is only defined for D65 Whitepoint')
                    end
                case'iptglc'
                    refWP = obj.getAdaptationWhite/obj.getAdaptationWhite('Y').*10000;
                    fun = @(x)XYZ2IPTGLC(x,refWP,obj.param);
                    if (refWP/10000) ~= xColorSpace.getWhitePoint('D65_31')
                        error('xCAMCS.fromXYZ: IPT is only defined for D65 Whitepoint')
                    end
               
                case 'yuv1976'
                    fun = @(x)XYZ2Yuv1976(x);
                case 'yxy'
                    fun = @(x)cat(2,x(:,2), x(:,1)./(x(:,1)+x(:,2)+x(:,3)), ...
                        x(:,2)./(x(:,1)+x(:,2)+x(:,3)));
                case 'ypqxy'
                    fun = @(x)cat(2,L2PQ(x(:,2)), x(:,1)./(x(:,1)+x(:,2)+x(:,3)), ...
                        x(:,2)./(x(:,1)+x(:,2)+x(:,3)));
                case 'yuvdoubleprime'
                    fun = @(x)XYZ2YuvDoublePrime(x);
                    
                                        
                case 'rec2100hlg'
                    fun = @(x) xPixel(x).setColorSpace( x3PrimaryCS( 'Rec2020BBC' ).setBlackLevel(0)...
                        .setAdaptationWhite(10000,'Y').setEncodingWhite(10000,'Y') )...
                        .fromXYZ.deLinearize.deCorrelate.getPixel;
                    
                case 'rec2100pq'
                    fun = @(x) xPixel(x).setColorSpace( x3PrimaryCS( 'Rec2020PQ' ).setBlackLevel(0)...
                        .setAdaptationWhite(10000,'Y').setEncodingWhite(10000,'Y') )...
                        .fromXYZ.deLinearize.deCorrelate.getPixel;
                    
                otherwise
                    error(['xCamCS.fromXYZ: This name is not yet implemented: ' obj.name])
            end
        end
                %% Implement 'equal' '=='
        function value = eq(obj1,obj2)
            
            if(strcmpi(obj1.name,obj2.name))
                value = true;
            else
                value = false;
            end
        end
        %% Implement 'not equal' '~='
        function value = ne(obj1,obj2)
            value = not(eq(obj1,obj2));
            
        end
        %% Implement setParam
        function obj = setParam(obj,param)
            obj.param = param;
        end
        %% set/getEncodingWhite (For compatibility with j3Primary CS)
        function obj = setEncodingWhite(obj,wp,mode)
            warning('Encoding White is not defined for xCamCS. Setting Adaptation White instead')
            if ~exist('mode','var')
                mode = 'XYZ';
            end
            switch lower(mode)
                case 'xyz'
                    tmp = XYZ2Yxy(xColorSpace.getWhitePoint(wp));
                    obj.adaptWhite_Yxy(1) = tmp(1);
                    obj.adaptWhite_Yxy(2) = tmp(2);
                    obj.adaptWhite_Yxy(3) = tmp(3);
                case 'yxy'
                    obj.adaptWhite_Yxy = wp;
                case 'y'
                    obj.adaptWhite_Yxy(1) = wp;
                otherwise
               error(['This Mode ' mode ' is not supported. Try XYZ or Y'])     
            end
        end
        
        function encodingWhite = getEncodingWhite(obj,mode)
            if ~exist('mode','var')
                mode = 'XYZ';
            end
            switch lower(mode)
                case 'xyz'
                    encodingWhite = Yxy2XYZ(obj.adaptWhite_Yxy);
                case 'yxz'
                    encodingWhite = obj.adaptWhite_Yxy;
                case 'y'
                    encodingWhite = obj.adaptWhite_Yxy(1);
                otherwise
                    error(['Use .getEncodingWhite whith Parameters ''Y'', ''XYZ'' or ''Yxy''. You used: ' mode])
            end
        end
        
    end
end

