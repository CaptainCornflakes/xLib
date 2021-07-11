
%% ------------------------------------------------------------------------
%% --- SCLIP OKLAB --------------------------------------------------------

% setup parameters colorspaces
P3D65 = x3PrimaryCS('P3D65').setBlackLevel(0).setEncodingWhite(1,'Y').setAdaptationWhite(1,'Y');
rec2020 = x3PrimaryCS('rec2020').setBlackLevel(0).setEncodingWhite(1,'Y').setAdaptationWhite(1,'Y');
SRGB = x3PrimaryCS('sRGB').setBlackLevel(0).setEncodingWhite(1,'Y').setAdaptationWhite(1,'Y');
% creating img with some P3D65 colors and srgb colorspace
imgSrc = xImage([0 0 0; 0.18 0.18 0.18; 2 2 2; 0 1 1.2; ...
                 0.5 0.5 0.5; 0.5 1.4 0.7; 1 0 0; 0 1 0; 0 0 1; 1 1 1]) ...
                 .setColorSpace(P3D65).toXYZ ...
                 .setColorSpace(SRGB).fromXYZ
imgSrc = imgSrc.setSize(5, 2);
%imgSrc.show;
%%
% gamutmap imgSrc to sRGB gamut
imgMapped = applyGamutMapping(imgSrc, 'SCLIP', 'oklab', 'vis');

disp('imgSrc:')
imgSrc.getPixel
disp('imgMapped:')
imgMapped.getPixel


%% 2. test

SRGB = x3PrimaryCS('sRGB').setBlackLevel(0).setEncodingWhite(1,'Y').setAdaptationWhite(1,'Y');
img1 = xImage([1,0.675486,0.480298]).setColorSpace(SRGB)

imgMapped = applyGamutMapping(img1, 'SCLIP', 'oklab', 'vis')