function M = calcRGB2XYZMatrix(RGBColorSpace)
%% calcRGB2XYZMatrix according to Formulas from:
% http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
%
% Jan Froehlich 2012.03.19:
% Modified for better numerical stability (No 0 Division with primary color Spaces)
% 
% ToDo: Compare with Computational Color Technology from Henry R. Kang

if not(strcmpi(class(RGBColorSpace),'xColorSpace'))
    RGBColorSpace = xColorSpace.cast(RGBColorSpace);
end

idx1 = @(x,a)x(a);

%% Get Variables from xColorSpace:
xr = idx1(RGBColorSpace.getRedPrimary,1);
yr = idx1(RGBColorSpace.getRedPrimary,2);
xg = idx1(RGBColorSpace.getGreenPrimary,1);
yg = idx1(RGBColorSpace.getGreenPrimary,2);
xb = idx1(RGBColorSpace.getBluePrimary,1);
yb = idx1(RGBColorSpace.getBluePrimary,2);

Yw = idx1(RGBColorSpace.getEncodingWhite,2);
Xw = idx1(RGBColorSpace.getEncodingWhite,1)/Yw;
Zw = idx1(RGBColorSpace.getEncodingWhite,3)/Yw;
Yw = 1;

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
%Xw = xw*Yw / yw;
% Yw is already there
%Zw = (1.0 - xw - yw)*Yw / yw;

%% Find Scaling values to correct X,Y,Z = 1 for R,G,B respectively assumption:
% Find Rs,Sg,Sb to solve:
% (Xr Xg Xb) (Sr) (Xw)
% (Yr Yg Yb)*(Sg)=(Yw)
% (Zr Zg Zb) (Sb) (Zw)
S = [Xr Xg Xb;Yr Yg Yb;Zr Zg Zb]\[Xw; Yw; Zw];
%Sinstabil = inv([Xr Xg Xb;Yr Yg Yb;Zr Zg Zb])*[Xw; Yw; Zw];

%% Scale Conversion matrix
M = [S';S';S'].*[Xr Xg Xb;Yr Yg Yb;Zr Zg Zb];
% disp(M)
end