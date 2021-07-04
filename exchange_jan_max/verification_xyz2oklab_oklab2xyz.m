%% --- TRANSFORMATION FROM XYZ TO OKLAB AND FROM OKLAB TO XYZ -------------

format long
%% 1. creating XYZ test img
% specified testcolors from:    https://bottosson.github.io/posts/oklab/
imgXYZ1 = xImage(xPixel([0.950 1 1.089; 1 0 0; 0 1 0; 0 0 1])).setColorSpace(x3PrimaryCS('XYZ'));
disp('XYZ values imgXYZ1: ') 
imgXYZ1.getPixel

%% 2. transform imgXYZ to Oklab
imgOklab = imgXYZ1.setColorSpace('oklab').fromXYZ;
disp('Lab values imgOklab: ') 
imgOklab.getPixel.data

%% 3. transform imgOklab back to XYZ
imgXYZ2 = imgOklab.toXYZ;
disp('XYZ values imgXYZ2: ') 
imgXYZ2.getPixel.data

%% 4. validation
% https://bottosson.github.io/posts/oklab/

% after transformation imgOklab should be:
% 1.000   -0.000   -0.000
% 0.450    1.236   -0.019
% 0.922   -0.671    0.263
% 0.153   -1.415   -0.449


% after transformation, imgXYZ should be:
% 0.950   1.000   1.089
% 1.000   0.000   0.000
% 0.000   1.000   0.000
% 0.000   0.000   1.000





