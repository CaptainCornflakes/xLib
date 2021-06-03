function img = XYZ2OKLAB(img)
%XYZ2OKLAB converts XYZ to Oklab 
%   Oklab is a color appearance model which should be easy to compute and
%   perceptually uniform in predicting lightness, hue and chroma.
%   whitepoint is specified with D65 and whitepoint Y = 1, no other options available for now.
%


% calculations based on:
% https://bottosson.github.io/posts/oklab/


    warning('XYZ2Oklab only works for D65 whitepoint and white Y = 1')

% %% ---- DEBUG -------------------------------------------------------------
% 
%    img = xPixel([0.950 1 1.089; ...
%                  1 0 0; ...
%                  0 1 0; ...
%                  0 0 1])
%
%    img = img.setColorSpace('oklab')
% 
% %    after calculating, imgOklab should be:
% %        1.000   -0.000   -0.000
% %        0.450    1.236   -0.019
% %        0.922   -0.671    0.263
% %        0.153   -1.415   -0.449
%
% %% ------------------------------------------------------------------------
    
    
    %img = raw img data, meta = xobj
    [img,meta] = img2raw(img);
    
    % defining matrix M1 for converting from XYZ to cone responses
    M1 = [0.8189330101, 0.3618667424, -0.1288597137; ...
          0.0329845436, 0.9293118715, 0.0361456387; ...
          0.0482003018, 0.2643662691, 0.6338517070];
      
   % defining matrix M2 for transform from nonlinear cone response to Lab coordinates
    M2 = [0.2104542553, 0.7936177850, -0.0040720468; ...
          1.9779984951, -2.4285922050, 0.4505937099; ...
          0.0259040371, 0.7827717662, -0.8086757660];
   
      
      
 %% ---- VERSION 01 ------------------------------------------------------- 
    % convert XYZ to approximate cone response
    lms = (M1 * img')'; % transpose img for correct matrix form
    
    % apply nonlinearity
    %lmsNonLin = round(lms.^(1/3), 4);
    lmsNonLin = nthroot(lms,3); %nthroot for avoiding complex numbers when calc .^(1/3)
    
    % transform to Lab coordinates
    imgOklab = (M2 * lmsNonLin' )';
      
%% --- PREPARE OUTPUT -----------------------------------------------------
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



% %% --- ALTERNATIVE VERSION TO COMPUTE OKLAB VALUES FROM XZY -------------

%     %% convert XYZ to approximate cone response
%     % creating empty matrix with size of input img to store Oklab data in
%     imgOklab = zeros(size(img,1),3);
%     
%     % iterate over all XYZ data
%     for i = 1:size(img, 1);
%         
%         valXYZ = img(i,1:3);
%         
%         % convert XYZ to approximate cone response
%         lms = (M1 * valXYZ'); % transpose valXYZ for correct matrix form
%         
%         % apply nonlinearity
%         %lmsNonLin = lms.^(1/3);
%         lmsNonLin = nthroot(lms,3);
%         
%         % transform to Lab coordinates
%         valOklab = (M2 * lmsNonLin );
%         
%         valOklabL = valOklab(1);
%         valOklabA = valOklab(2);
%         valOklabB = valOklab(3);
%         
%         % store Oklab values in imgOklab
%         imgOklab(i,1) = valOklabL;
%         imgOklab(i,2) = valOklabA;
%         imgOklab(i,3) = valOklabB;
%     end
