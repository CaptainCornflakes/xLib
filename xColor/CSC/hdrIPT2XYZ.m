function XYZ_D65 = IPT2XYZ(IPTPQ,XYZWhitepoint)
%IPT2XYZ Convert IPT to linear XYZ (Adapted to D65) 
%   Ebner, F., & Fairchild, M. (1998). 
%   Development and Testing of a Color Space (IPT) with Improved Hue Uniformity. 
%   IS&T/SID 6th Color Imaging Conference, 8?13. 
%   Retrieved from http://white.stanford.edu/~brian/scielab/scielab3/scielab3.html

%% Inputs:
% Img: Image in XYZ adapted to D65

[IPTPQ, meta] = img2raw(IPTPQ);

%% Inverse Conversion:

% Conversion Matrices
% From Robin:
% XYZ65_2_LMS = [ 0.38971 -0.22981 0;...
%                 0.68898  1.18340 0;...
%                -0.07868  0.04641 1 ]; 
% From Paper:
XYZ65_2_LMS = [0.4002 0.7075 -0.0807;
              -0.2280 1.1500  0.0612;
               0.0    0.0     0.9184];
           
% Normalize to D65
WPD65 = xColorSpace.getWhitePoint('d65_31') * XYZ65_2_LMS;
XYZ65_2_LMS = (XYZ65_2_LMS * diag(([1 1 1] ./ WPD65)))';

LMSp_2_IPT = [0.4000  0.4000  0.2000;
              4.4550 -4.8510  0.3960;
              0.8056  0.3572 -1.1628];

% Nonlinearity
plcf = @(x)(x>=0).*((0.184.^1.38.*(x-0.0002))./(1+0.0002-x)).^(1/1.38) + ...
    (x<0).*-1.*((0.184.^1.38.*(-x-0.0002))./(1+0.0002+x)).^(1/1.38);

% Convert to perceptual coded LMS
LMSp = (LMSp_2_IPT\IPTPQ')';

% remove nonlinearity
if min(LMSp<0)
    warning('Values sub 0 in LMS are truncated because IPTPQ doesn''t support them')
    LMSp = max(0,LMSp);
end
% if max(LMSp>1)
%     warning('Values higher 1 are truncated because LMS doesn''t support them')
%     LMSp = min(1,LMSp);
% end
LMS = plcf(LMSp);

% Convert to XYZ 
XYZ_D65 = (XYZ65_2_LMS\LMS')';

XYZ_D65 = XYZ_D65.*XYZWhitepoint(2);

XYZ_D65 = raw2img(XYZ_D65,meta);

if isa(XYZ_D65,'xBase')
    XYZ_D65 = XYZ_D65.setHistory('Converted from IPT to XYZ');
end

end

    
    
