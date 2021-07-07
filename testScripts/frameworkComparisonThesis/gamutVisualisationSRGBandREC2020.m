%% vis rec2020 in oklab
% def rec2020
rec2020 = x3PrimaryCS('rec2020').setBlackLevel(0).setEncodingWhite(1, 'Y').setAdaptationWhite(1,'Y');
%create gamut hull
rec2020hull = rec2020.getGamutHull('triangle', 6);
% transfer to oklab
pix1 = xPixel( rec2020hull ).setColorSpace(rec2020).toXYZ.setColorSpace('oklab').fromXYZ; 
% store px data in gamut hull
rec2020ghOKLAB = rec2020hull.setPoint(pix1);
%% vis sRGB in oklab
% def sRGB
sRGB = x3PrimaryCS('sRGB').setBlackLevel(0).setEncodingWhite(1,'Y').setAdaptationWhite(1,'Y');
%create gamut hull
sRGBhull = sRGB.getGamutHull('triangle', 6);
% transfer to oklab
pix2 = xPixel( sRGBhull ).setColorSpace(rec2020).toXYZ.setColorSpace('oklab').fromXYZ; 
% store px data in gamut hull
sRGBghOKLAB = sRGBhull.setPoint(pix2);
%% show both
rec2020ghOKLAB.show([0.5 0.5 0.5]) %(xPixel(P3hull))
sRGBghOKLAB.show([1,0,0])%(xPixel(sRGBhull))