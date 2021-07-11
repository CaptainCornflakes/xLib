%% ------------------------------------------------------------------------
%% %%  ELABORATION SCLIP WITHIN xLib FRAMEWORK
% this script was created as part of the bachelor thesis of maximilian czech
% to compare how SCLIP is performed on an image
% when using the xLib framework or the respective raw code.
% this file contains the xLib version
%% ------------------------------------------------------------------------

%% GET TEST-IMG --------------------------------------------------------
imgTest = getTestImageTestSetupSCLIP();

%% timer start
tic
%% ------------------------------------------------------------------------
%% ELABORATION STARTS HERE ------------------------------------------------

% SAVE imgTest AS xImage AND SET COLOR SPACE TO sRGB
img = xImage(imgTest).setColorSpace(x3PrimaryCS('sRGB').setBlackLevel(0)...
                     .setEncodingWhite(1,'Y').setAdaptationWhite(1,'Y'));

% LINEARIZE TESTIMG
imgLin = img.linearize;

%PERFORM GAMUT MAPPING
imgMappedLin = applyGamutMapping(imgLin, 'SCLIP', 'oklab', 'vis');

% DELINEARIZE MAPPED IMG
imgMapped = imgMappedLin.deLinearize;

% RESHAPE IMG TO STANDARD REPRESENTATION OF IMAGES IN MATLAB
imgFinalxLib = imgMapped.getImage;

% elapsed time
timexLib = toc
