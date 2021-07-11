function [imgTest] = getTestImageTestSetupSCLIP()
%getTestImageTestSCLIP creates the test image for the SCLIP elaboration 

% def rec2020
rec2020 = x3PrimaryCS('rec2020').setBlackLevel(0) ...
                    .setEncodingWhite(1, 'Y').setAdaptationWhite(1,'Y');
% def sRGB
sRGB = x3PrimaryCS('sRGB').setBlackLevel(0).setEncodingWhite(1,'Y') ...
                    .setAdaptationWhite(1,'Y');
%read peppers.png
ximg = xImage('peppers');

%interpret as rec2020 and convert back in sRGB to create OOG colors
ximg = ximg.setColorSpace(rec2020).toXYZ.setColorSpace(sRGB).fromXYZ; 

% delinearize
ximg = ximg.deLinearize;

% resize to smaller img in nonlin domain
ximg = ximg.resize(round(ximg.getHeight/2),(round(ximg.getWidth/2)));

% reshape to standard representation of images in matlab
imgTest = ximg.getImage;
end