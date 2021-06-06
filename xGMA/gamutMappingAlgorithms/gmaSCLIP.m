function [imgGamutMapped] = gmaSCLIP(img,mappingColorSpace)
%SCLIP GamutMappingAlgorithm
    % applies clipping on gamut hull of target colorspace towards center of lightness axis for all OOG colors

    
    
    
%     %% --------------------------------------------------------------------
%     %% --- DEBUG START ----------------------------------------------------
%     % original img, targetCS is set to srgb
%     P3D65 = x3PrimaryCS('P3D65').setBlackLevel(0).setEncodingWhite(1,'Y').setAdaptationWhite(1,'Y');
%     sRGB = x3PrimaryCS('sRGB').setBlackLevel(0).setEncodingWhite(1,'Y').setAdaptationWhite(1,'Y');
%     origImg = xImage(xPixel([0 0 0; 0.18 0.18 0.18; 2 2 2; 0 1 1.2; ...
%                      0.5 0.5 0.5; 0.5 1.4 0.7; 1 0 0; 0 1 0; 0 0 1; 1 1 1])) ...
%                      .setColorSpace(P3D65).clamp(0,1).toXYZ.setColorSpace(sRGB).fromXYZ;
%     mappingColorSpace = 'oklab';
%     precision = 3;
%     
%     img = origImg.linearize;
%     
%     %img.getPixel()
%     %img.show
%    
%     %% --- DEBUG END ------------------------------------------------------
%     %% --------------------------------------------------------------------




    %% inits
    mappingColorSpace = xCamCS(mappingColorSpace); % make sure mappingColorSpace is an xCamCS obj
    targetColorSpace = img.getColorSpace; % def targetColorSpace
    
    %% find all OOG colors of the input img, disp number
    oogPx = img.select(not(img.isInGamut)); % store all OOG colors in oogPx
    numPixelOOG = sum(not(img.isInGamut)) % get number of OOG pixels
    
    %% convert OOG pixels to mapping color space
    oogPxOklab = oogPx.toXYZ.setColorSpace(mappingColorSpace).fromXYZ;
    
    %% build lines where P1 = OOG color and P2 = mappingDirection
    oogRawPoints = oogPxOklab.getPixel; % get rawPoints of all OOG colors
    
    % set point for mapping direction to center of lightness axis
    mappingPoint = xPixel(img.colorSpace.getEncodingWhite./2).setColorSpace(targetColorSpace);
    % transfer them into mapping color space
    mappingPoint = mappingPoint.setColorSpace(mappingColorSpace).fromXYZ
    % get the raw mapping point as 1*3 array
    rawMappingPoint = mappingPoint.getPixel
    
    %% build mapping lines
    % create one point in center of lightness axis for each OOG color
    mappingDirection = repmat(rawMappingPoint, numPixelOOG, 1);
    
    % build mapping lines from OOG colors to center of lightness axis
    rawMappingLines = cat(2, oogRawPoints, mappingDirection);
    mappingLines = xLine([rawMappingLines]); % store as xLine obj
    
    
    %% get gamut hull of target CS
    %get gamut hull of target color space as triangles
    gamutHullTargetCS = img.getColorSpace.getGamutHull('triangle', precision);
    
    % transfer gamut hull to mapping color space and store in xPixel obj
    ghmCSpx = xPixel(gamutHullTargetCS).setColorSpace(img.getColorSpace).toXYZ.setColorSpace(mappingColorSpace).fromXYZ;
    % create xTriangle obj
    ghmCS = gamutHullTargetCS.setPoint(ghmCSpx);
    
    %% show target gamut and mapping lines 
    mappingLines.show
    ghmCS.show(xPixel(gamutHullTargetCS))
    xlabel L*
    ylabel a*
    zlabel b*
     
    %% find intersection of mapping lines and gamut hull of target CS in mapping CS
    [flag, intersectionPoints] = lineTriangleIntersect2(mappingLines, ghmCS, 'any2any');
    
    %% convert the mapped points back to the target color space
    intersectOklab = xPixel(intersectionPoints).setColorSpace('oklab');
    intersectionP = intersectOklab.toXYZ.setColorSpace(targetColorSpace).fromXYZ;
    %%
    imgGamutMapped = img;
    idxList = not(img.isInGamut);
    %%insert gamputmapped pixels at the respective idx
    imgGamutMapped = insert(img, intersectionP, idxList);
   
    
end

