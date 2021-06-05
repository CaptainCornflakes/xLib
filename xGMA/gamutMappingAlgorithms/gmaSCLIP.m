function [imgGamutMapped] = gmaSCLIP(img,mappingColorSpace)
%SCLIP GamutMappingAlgorithm
    % applies clipping on gamut hull of target colorspace towards center of lightness axis for all OOG colors

    %% --------------------------------------------------------------------
    %% --- DEBUG START ----------------------------------------------------
    % original img, targetCS is set to srgb
    P3D65 = x3PrimaryCS('P3D65').setBlackLevel(0).setEncodingWhite(1,'Y').setAdaptationWhite(1,'Y')
    sRGB = x3PrimaryCS('sRGB').setBlackLevel(0).setEncodingWhite(1,'Y').setAdaptationWhite(1,'Y')
    origImg = xImage(xPixel([0 0 0; 0.18 0.18 0.18; 2 2 2; 0 1 1.2; ...
                     0.5 0.5 0.5; 0.5 1.4 0.7; 1 0 0; 0 1 0; 0 0 1; 1 1 1])) ...
                     .setColorSpace(P3D65).clamp(0,1).toXYZ.setColorSpace(sRGB).fromXYZ;
    mappingColorSpace = 'oklab';
    precision = 17;
    
    img = origImg;
    
    %img.getPixel()
    img.show
   
    %% --- DEBUG END ------------------------------------------------------
    %% --------------------------------------------------------------------
    
    %% inits
    % make sure mappingColorSpace is an xCamCS
    mappingColorSpace = xCamCS(mappingColorSpace);
    
    
    %% find all OOG colors of the input img, create empty var for new IG pixels
    oogPx = img.select(not(img.isInGamut));
    rawIgImg = zeros(oogPx.getNumElements,3);
    numPixelOOG = sum(not(img.isInGamut))
    
    %% convert to mapping color space
    % out of gamut pixels are now converted to oklab
    oogPx = oogPx.toXYZ.setColorSpace(mappingColorSpace).fromXYZ;
    
    
    
    
    %% build lines where P1 = OOG color and P2 = mappingDirection
    % get raw OOG points
    oogRawPoints = oogPx.getPixel;
    
    % set point for mapping direction to center of lightness axis
    mappingPoint = xPixel([img.colorSpace.getEncodingWhite/2]).setColorSpace('srgb').toXYZ.setColorSpace('oklab').fromXYZ

    rawMappingPoint = mappingPoint.getPixel
    %%
    mappingDirection = repmat(rawMappingPoint, numPixelOOG, 1);
    
    % build mapping lines
    rawMappingLines = cat(2, oogRawPoints, mappingDirection)
    
    mappingLines = xLine(rawMappingLines)
    mappingLines.show
    
    %% get gamut hull of target CS
    %get srgb GH
    gamutHullTargetCS = img.getColorSpace.getGamutHull('triangle', precision);
    %gamutHullTargetCS.show
    ghmCSpx = xPixel(gamutHullTargetCS).setColorSpace(img.getColorSpace).toXYZ.setColorSpace(mappingColorSpace).fromXYZ
    ghmCS = gamutHullTargetCS.setPoint(ghmCSpx)
    ghmCS.show(xPixel(gamutHullTargetCS))
     
    
    
    
end

