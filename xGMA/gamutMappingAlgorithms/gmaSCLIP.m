function [imgGamutMapped] = gmaSCLIP(img,mappingColorSpace, varargin)
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
    precision = 32;
    mappingColorSpace = xCamCS(mappingColorSpace); % make sure mappingColorSpace is an xCamCS obj
    targetColorSpace = img.getColorSpace; % def targetColorSpace
    
    %% find all OOG colors of the input img, disp number
    oogPx = img.select(not(img.isInGamut)); % store all OOG colors in oogPx
    numPixelOOG = sum(not(img.isInGamut)) % get number of OOG pixels
    
    %% convert OOG pixels to mapping color space
    oogPxOklab = oogPx.toXYZ.setColorSpace(mappingColorSpace).fromXYZ;
    
    %% build lines where P1 = OOG color and P2 = mappingDirection
    oogRawPoints = oogPxOklab.getPixel; % get rawPoints of all OOG colors
    
    % set point for maximum of lightness axis of targetCS
    mappingPoint = xPixel(img.colorSpace.getEncodingWhite).setColorSpace(targetColorSpace);
    % transfer them into mapping color space
    mappingPoint = mappingPoint.setColorSpace(mappingColorSpace).fromXYZ
    % get the raw mapping point and calculate the center of the lightness axis
    rawMappingPoint = mappingPoint.getPixel./2
    
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
    


%             end
%         end
%     end
   
     
    %% find intersection of mapping lines and gamut hull of target CS in mapping CS
    [flag, intersectionPoints] = lineTriangleIntersect2(mappingLines, ghmCS, 'any2any');
    
    %% convert the mapped points back to the target color space
    intersectMappingSpace = xPixel(intersectionPoints).setColorSpace(mappingColorSpace);
    intersectionP = intersectMappingSpace.toXYZ.setColorSpace(targetColorSpace).fromXYZ;
    %% insert gamputmapped pixels in original img at the respective idx
    idxList = not(img.isInGamut);
    imgGamutMapped = img; %#ok<NASGU>
    imgGamutMapped = insert(img, intersectionP, idxList);
   
    %% visualization of mapping
%     if isa(varargin{1}, 'char')
%                     switch lower(varargin{1})
    
    if nargin > 2
        for i = 1:size(varargin(1))
%            if isa(varargin{i}, 'char')
                switch lower(varargin{i,1}{1})
                    case {'visualize', 'vis'}
                        figure;
                        ghmCS.show(xPixel(gamutHullTargetCS))
                        mappingLines.show
                        hold on
                        P = intersectMappingSpace.getPixel
                        for ii = 1:getNumElements(intersectMappingSpace)
                            plot3(P(i,1), P(i,2), P(i,3), '*r')
                        end
                        
                        xlabel(mappingColorSpace.getAxisName(1));
                        ylabel(mappingColorSpace.getAxisName(2));
                        zlabel(mappingColorSpace.getAxisName(3));
               end
        end
    end
    
end

