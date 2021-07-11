%% ------------------------------------------------------------------------
%% awg img
imgAWG = xImage('isabella').linearize
imgAWG.show
%% awg2XYZ
imgXYZ = imgAWG.toXYZ
imgXYZ.show
%% XYZ2SRGB
imgSRGB = imgXYZ.setColorSpace(x3PrimaryCS('srgb').setEncodingWhite(1, 'Y').setBlackLevel(0)).fromXYZ
imgSRGB.show