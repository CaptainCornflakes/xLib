function img = XYZ2OKLAB(img)
%XYZ2OKLAB converts XYZ to Oklab 
%   Oklab is a color appearance model which should be easy to compute and
%   perceptually uniform in predicting lightness, hue and chroma.
%   whitepoint is specified with D65 and whitepoint Y = 1, no other options available for now.
%


% calculations based on:
% https://bottosson.github.io/posts/oklab/


    warning('XYZ2Oklab only works for D65 whitepoint')

% %% ---- DEBUG -------------------------------------------------------------
% 
% img = xPixel([0 0 0; 0.18 0.18 0.18; 0.5 0.5 0.5; 1 0 0; 0 1 0; 0 0 1; 1 1 1])
% img = img.setColorSpace('oklab')
% 
% %% ------------------------------------------------------------------------
    
    
    %img = raw img data, meta = xobj
    [img,meta] = img2raw(img);
    
    % creating empty matrices with size of input img
    f = zeros(size(img,1),3);
    index = zeros(size(img,1),3);
    
    % defining matrix M1 for converting from XYZ to cone responses
    M1 = [0.8189330101, 0.3618667424, -0.1288597137; ...
          0.0329845436, 0.9293118715, 0.0361456387; ...
          0.0482003018, 0.2643662691, 0.6338517070];
      
   % defining matrix M2 for transform from nonlinear cone response to Lab coordinates
    M2 = [0.2104542553, 0.7936177850, -0.0040720468; ...
          1.9779984951, -2.4285922050, 0.4505937099; ...
          0.0259040371, 0.7827717662, -0.8086757660];
   
      
      
 %%     
    % convert XYZ to approximate cone response
    lms = (M1 * img')'; % transpose img for correct matrix form
    
    % apply nonlinearity
    lmsNonLin = lms.^(1/3);
    
    % transform to Lab coordinates
    imgOklab = (M2 * lmsNonLin' )';
    
    img = raw2img(imgOklab, meta);
    
    if isa(img,'xBase')
        img = img.setHistory(['converted from XYZ to Oklab with whitepoint: D65']);
    end
    
    
    % store in xImage object
    % ----- WORK HERE---
    
    % todo: passing back the right obj + meta
    % what to do with index and f???
    % verify results 
    
end

