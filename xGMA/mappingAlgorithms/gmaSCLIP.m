function [imgGamutMapped] = gmaSCLIP(img,mappingColorSpace, varargin)
%SCLIP GamutMappingAlgorithm
    % applies clipping on gamut hull of target colorspace towards center of lightness axis for all OOG colors
    % legal imput args for varargin are 'visualize' and 'vis'
    
    
    
    %% --------------------------------------------------------------------
    %% --- DEBUG START ----------------------------------------------------
    
    % original img, targetCS is set to srgb
%     P3D65 = x3PrimaryCS('P3D65').setBlackLevel(0).setEncodingWhite(1,'Y').setAdaptationWhite(1,'Y');
%     sRGB = x3PrimaryCS('sRGB').setBlackLevel(0).setEncodingWhite(1,'Y').setAdaptationWhite(1,'Y');
%     origImg = xImage(xPixel([0 0 0; 0.18 0.18 0.18; 2 2 2; 0 1 1.2; ...
%                      0.5 0.5 0.5; 0.5 1.4 0.7; 1 0 0; 0 1 0; 0 0 1; 1 1 1])) ...
%                      .setColorSpace(P3D65).clamp(0,1).toXYZ.setColorSpace(sRGB).fromXYZ;
%     mappingColorSpace = 'oklab';
%     precision = 3;
%     
%     img = origImg.linearize;
    
    %img.getPixel()
    %img.show
    
    % ----------------------------------------------------------------------
    % 2nd debug
%     mappingColorSpace = 'oklab';
%     img = xImage(xPixel([1, 0.675486, 0.480298])).setColorSpace(x3PrimaryCS('sRGB').setBlackLevel(0)...
%                      .setEncodingWhite(1,'Y').setAdaptationWhite(1,'Y'));
%     
%     img = xImage(xPixel([1.0007, 0.8723, 0.8408])).setColorSpace(x3PrimaryCS('sRGB').setBlackLevel(0)...
%                      .setEncodingWhite(1,'Y').setAdaptationWhite(1,'Y'));
%     mappingColorSpace = 'oklab';
    
    %% --- DEBUG END ------------------------------------------------------
    %% --------------------------------------------------------------------

    
    %% inits
    precision = 16; % for calculating the gamut hull
    mappingColorSpace = xCamCS(mappingColorSpace); % make sure mappingColorSpace is an xCamCS obj
    targetColorSpace = img.getColorSpace; % def targetColorSpace
    
    %% find all OOG colors of the input img, disp number
    oogPx = img.select(not(img.isInGamut)); % store all OOG colors in oogPx
    numPixelOOG = sum(not(img.isInGamut)); % get number of OOG pixels
    
    %% convert OOG pixels to mapping color space
    oogPxMappingCS = oogPx.toXYZ.setColorSpace(mappingColorSpace).fromXYZ;
    
    %% get rawPoints of all OOG colors and mapping point
    %get raw OOG colors
    oogRawPoints = oogPxMappingCS.getPixel;
    
    % get maximum of lightness axis of mapping space
    whitepoint = xPixel(mappingColorSpace.getEncodingWhite);
    maxLightness = whitepoint.getPixel(2);
    
    % get the raw mapping point and calculate the center of the lightness axis
    centerL = [ maxLightness/2, 0, 0];
    
    %% build mapping lines where P1 = OOG color and P2 = mappingDirection
    % create one point in center of lightness axis for each OOG color
    mappingDirection = repmat(centerL, numPixelOOG, 1);
    
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

    %% find intersection of mapping lines and gamut hull of target CS in mapping CS
    [flag, intersectionPoints] = lineTriangleIntersect(mappingLines, ghmCS, 'any2any');
    
    %% convert the mapped points back to the target color space
    intersectMappingSpace = xPixel(intersectionPoints).setColorSpace(mappingColorSpace);
    intersectionP = intersectMappingSpace.toXYZ.setColorSpace(targetColorSpace).fromXYZ;
    
    %% insert gamputmapped pixels in original img at the respective idx
    idxList = not(img.isInGamut);
    imgGamutMapped = img; %#ok<NASGU>
    imgGamutMapped = insert(img, intersectionP, idxList);
    
    disp([num2str(sum(idxList)), 'pixels have been mapped'])
   
    %% visualization of mapping
    if nargin >= 3
        if isa(varargin{1}, 'char')
            switch lower(varargin{1})
                case {'visualize', 'vis'} % check for varargin 'vis'/'visualize'
                    figure;
                    ghmCS.show(xPixel(gamutHullTargetCS), 0.2); % plot gamut hull with color information and line thickness of 0.2
                    mappingLines.show; % plot mapping lines
                    interP = xPoint([intersectMappingSpace.getPixel]); % create xPoint obj with intersection points
                    hold on
                    
                    show(interP, [0.9 0 0], 30); % plot intersection points
                    show(xPoint(oogPxMappingCS), [0.4 1 0.2], 30);
                    
                    % set names of plotting axis to names of mapping CS
                    xlabel(mappingColorSpace.getAxisName(1));
                    ylabel(mappingColorSpace.getAxisName(2));
                    zlabel(mappingColorSpace.getAxisName(3));
                    
                    ax = gca;
                    ax.Clipping = 'off';
            end
        end
    end 
end

