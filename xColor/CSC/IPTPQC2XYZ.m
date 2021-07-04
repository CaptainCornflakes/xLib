function XYZ_D65 = IPTPQC2XYZ(IPTPQ,XYZWhitepoint,crosstalk)
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
XYZ65_2_LMS = [ 0.38971 -0.22981 0;...
                0.68898  1.18340 0;...
               -0.07868  0.04641 1 ];  
% Normalize to D65
WPD65 = xColorSpace.getWhitePoint('d65_31') * XYZ65_2_LMS;
XYZ65_2_LMS = (XYZ65_2_LMS * diag(([1 1 1] ./ WPD65)))';

LMSp_2_IPT = [0.4000  0.4000  0.2000;
              4.4550 -4.8510  0.3960;
              0.8056  0.3572 -1.1628];

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
LMS = PQ2L(LMSp)./10000;

% Convert to XYZ and remove crosstalk before
c1 = crosstalk(1);
c2 = crosstalk(2);
c3 = crosstalk(3);
XYZ_D65 = (XYZ65_2_LMS\([(1-2*c1), c1, c1;
                         c2, (1-2*c2), c2;...
                         c3, c3, (1-2*c3)]\LMS'))';

XYZ_D65 = XYZ_D65.*XYZWhitepoint(2);

XYZ_D65 = raw2img(XYZ_D65,meta);

if isa(XYZ_D65,'xBase')
    XYZ_D65 = XYZ_D65.setHistory('Converted from IPTPQ to XYZ');
end

end

    
    
