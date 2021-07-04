function img = OKLAB2XYZ(img)
%XYZ2OKLAB converts Oklab to XYZ
%   Oklab is a color appearance model which should be easy to compute and
%   perceptually uniform in predicting lightness, hue and chroma.
%   whitepoint is specified with D65 and whitepoint Y = 1, no other options available for now.
%


% calculations based on:
% https://bottosson.github.io/posts/oklab/

% %-------------------------------------------------------------------------
% %% ---- DEBUG START -----------------------------------------------------
% 
%    img = xPixel([1 0 0; ...
%                  0.450 1.236 -0.019; ...
%                  0.922 -0.671 0.263; ...
%                  0.153 -1.415 -0.449]);
% 
%    img = img.setColorSpace('oklab');
% 
% %    after calculating, imgXYZ should be:
% %        0.950   1.000   1.089
% %        1.000   0.000   0.000
% %        0.000   1.000   0.000
% %        0.000   0.000   1.000
% 
% %% ---- DEBUG END -------------------------------------------------------
% %-------------------------------------------------------------------------


%% --- INITS --------------------------------------------------------------
warning('XYZ2Oklab only works for D65 whitepoint')

[img,meta] = img2raw(img); %img2raw: img is pixel data, meta stores xObj info
    

%% --- DEFINING MATRICES --------------------------------------------------
% https://bottosson.github.io/posts/oklab/

% inverse matrix M1 for converting cone responses to XYZ
invM1 = [0.8189330101, 0.3618667424, -0.1288597137; ...
         0.0329845436, 0.9293118715, 0.0361456387; ...
         0.0482003018, 0.2643662691, 0.6338517070] ...
         ^(-1);

% inverse matrix M2 to transform Lab coordinates to nonlinear cone response   
invM2 = [0.2104542553, 0.7936177850, -0.0040720468; ...
         1.9779984951, -2.4285922050, 0.4505937099; ...
         0.0259040371, 0.7827717662, -0.8086757660] ...
         ^(-1);
 
     
%% --- COMPUTATION --------------------------------------------------------
% 1. transform from Lab to nonlinear cone response
lmsNonlin = (invM2 * img')'; % transpose for correct dims while calculating

% 2. linearize
lms = lmsNonlin.^3;

% 3. transform from cone response to XYZ
imgXYZ = (invM1 * lms')'; % transpose back to correct dims for xLib


%% --- PREPARE OUTPUT -----------------------------------------------------
img = raw2img(imgXYZ, meta);

if isa(img,'xBase')
    img = img.setHistory(['converted from Oklab to XYZ with whitepoint: D65']);
end

end

