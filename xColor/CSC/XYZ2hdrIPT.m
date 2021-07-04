function hdrIPT = XYZ2hdrIPT(XYZ_D65,XYZWhitepoint)
%Lab2IPT Convert linear XYZ (Adapted to D65) to IPT
%   Ebner, F., & Fairchild, M. (1998). 
%   Development and Testing of a Color Space (IPT) with Improved Hue Uniformity. 
%   IS&T/SID 6th Color Imaging Conference, 8?13. 
%   Retrieved from http://white.stanford.edu/~brian/scielab/scielab3/scielab3.html

%% this is an implementation for the special case of DIFFUSE WHITE beeing 318cd/m2 
%% and expects diffuse white at ~100cd/m2 !!!!
% %% Debug:
% XYZ_D65 = xPixel([0 0 0;eye(3);1 1 1]).setColorSpace(x3PrimaryCS('Rec709').setBlackLevel(0))...
%     .toXYZ.times(100/80);
% 
% XYZ_D65 = xPixel([eye(3);1 1 1]).setColorSpace(x3PrimaryCS('Rec709').setBlackLevel(0))...
%     .toXYZ.times(318/80);

%% Inputs:
% Img: Image in XYZ adapted to D65

[XYZ_D65,meta] = img2raw(XYZ_D65);

%% Conversion according to Equn. 1:
% Conversion Matrices
% Assuming D65 White to be XYZ = [0.9505, 1.0000, 1.0891]
% Robin
% XYZ65_2_LMS = [ 0.38971 -0.22981 0;...
%                 0.68898  1.18340 0;...
%                -0.07868  0.04641 1 ];  
% Paper:
XYZ65_2_LMS = [ 0.4002 -0.2280 0;...
                0.7075  1.1500 0;...
               -0.0807  0.0612 0.9184];

%% XYZ_2_LMS neede to be normalized before to WP in original paper version
WPD65 = xColorSpace.getWhitePoint('d65_31') * XYZ65_2_LMS;
XYZ65_2_LMS = (XYZ65_2_LMS * diag(([1 1 1] ./ WPD65)))';
           
LMSp_2_IPT = [0.4000  0.4000  0.2000;
              4.4550 -4.8510  0.3960;
              0.8056  0.3572 -1.1628];

%% Nonlinearity
lpcf = @(x)(x>=0).*(x.^1.38./(x.^1.38 + 0.184.^1.38) + 0.0002) + ...
     (x<0).*-1.*((-x).^1.38./((-x).^1.38 + 0.184.^1.38) + 0.0002);
%lpcf = @(x)(x>=0).*(x.^1.38./(x.^1.38 + 0.184.^1.38)) + ...
%    (x<0).*-1.*((-x).^1.38./((-x).^1.38 + 0.184.^1.38));
%lpcf = @(x)(x>=0).*(x.^1.38./(x.^1.38 + 0.184.^1.38));
  
%% OVERRIDDEN FOR HDR! BE CAREFUL!
% Normalize to Y from whitepoint:
%XYZ_D65 = XYZ_D65./XYZWhitepoint(2);
XYZ_D65 = XYZ_D65./100;

% Convert to LMS 
LMS = (XYZ65_2_LMS*XYZ_D65')';

% Nonlinearity:
if min(LMS(:))<0
    warning('Values sub 0 in LMS are tuncated because IPTPQ doesn''t support them')
    LMS = max(0,LMS);
end

LMSp = lpcf(LMS);

% Convert to hdrIPT
hdrIPT = (LMSp_2_IPT*LMSp')';

hdrIPT = raw2img(hdrIPT,meta);


if isa(hdrIPT,'xBase')
    hdrIPT = hdrIPT.setHistory('Converted from XYZ to hdrIPT');
end
end

    
    
