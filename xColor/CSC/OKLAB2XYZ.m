function img = OKLAB2XYZ(img)
%XYZ2OKLAB converts Oklab to XYZ
%   Oklab is a color appearance model which should be easy to compute and
%   perceptually uniform in predicting lightness, hue and chroma.
%   whitepoint is specified with D65 and whitepoint Y = 1, no other options available for now.
%


% calculations based on:
% https://bottosson.github.io/posts/oklab/


% %% ---- DEBUG -------------------------------------------------------------
% 
%     img = xPixel([0 0 0; 0.18 0.18 0.18; 0.5 0.5 0.5; 1 0 0; 0 1 0; 0 0 1; 1 1 1])
%     img = img.setColorSpace('oklab')
% 
% %% ------------------------------------------------------------------------



    warning('XYZ2Oklab only works for D65 whitepoint')
    
     %img = raw img data, meta = xobj
    [img,meta] = img2raw(img);
    
    
    %get whitepoint
    white = xColorSpace.getWhitePoint( 'd65_31' );
    
    %% matrices
    % defining inverse matrix M1 for converting from cone responses to XYZ
    invM1 = [0.8189330101, 0.3618667424, -0.1288597137; ...
             0.0329845436, 0.9293118715, 0.0361456387; ...
             0.0482003018, 0.2643662691, 0.6338517070] ...
             ^(-1);
      
      
   % defining inverse matrix to transform from Lab coordinates to nonlinear cone response   
    invM2 = [0.2104542553, 0.7936177850, -0.0040720468; ...
             1.9779984951, -2.4285922050, 0.4505937099; ...
             0.0259040371, 0.7827717662, -0.8086757660] ...
             ^(-1);
         
    %% calculations
    % 1. transform from Lab to nonlinear cone response
    lmsNonlin = (invM2 .* img')';
    
    % 2. linearize
    lms = lmsNonlin.^3;
    
    % 3. transform from cone response to XYZ
    img = (invM1 .* lms')';

end

