function IPTPQ = XYZ2IPTPQ(XYZ_D65,XYZWhitepoint)
%Lab2IPT Convert linear XYZ (Adapted to D65) to IPT
%   Ebner, F., & Fairchild, M. (1998). 
%   Development and Testing of a Color Space (IPT) with Improved Hue Uniformity. 
%   IS&T/SID 6th Color Imaging Conference, 8?13. 
%   Retrieved from http://white.stanford.edu/~brian/scielab/scielab3/scielab3.html

%% Inputs:
% Img: Image in XYZ adapted to D65

[XYZ_D65,meta] = img2raw(XYZ_D65);

%% Conversion according to Equn. 1:
% Conversion Matrices
% Assuming D65 White to be XYZ = [0.9505, 1.0000, 1.0891]
XYZ65_2_LMS = [ 0.38971 -0.22981 0;...
                0.68898  1.18340 0;...
               -0.07868  0.04641 1 ];  

% XYZ_2_LMS neede to be normalized before to WP in original paper version
WPD65 = xColorSpace.getWhitePoint('d65_31') * XYZ65_2_LMS;
XYZ65_2_LMS = (XYZ65_2_LMS * diag(([1 1 1] ./ WPD65)))';
           
           
LMSp_2_IPT = [0.4000  0.4000  0.2000;
              4.4550 -4.8510  0.3960;
              0.8056  0.3572 -1.1628];

% Normalize to Y from whitepoint:
XYZ_D65 = XYZ_D65./XYZWhitepoint(2);

% Convert to LMS 
LMS = (XYZ65_2_LMS*XYZ_D65')';

% Nonlinearity:
if min(LMS(:))<0
    warning('Values sub 0 in LMS are tuncated because IPTPQ doesn''t support them')
    LMS = max(0,LMS);
end

LMSp = L2PQ(LMS.*10000);

% Convert to IPTPQ
IPTPQ = (LMSp_2_IPT*LMSp')';

IPTPQ = raw2img(IPTPQ,meta);


if isa(IPTPQ,'xBase')
    IPTPQ = IPTPQ.setHistory('Converted from XYZ to IPTPQ');
end
end

    
    