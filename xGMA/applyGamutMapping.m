function [ imgGamutMapped ] = applyGamutMapping(img, gmaName, mappingColorSpace, varargin)
%gamutMap for applying gamut mapping algorithms to an img.
% applyGamutMapping is performed after converting the image to the desiered
% destination colorspace
%   inputs are img, gmaName and varargin
%   valid gmaNames are:
%       - 'SCLIP'


    % warning
    if ~img.isLinear
                warning(['images expected to be encoded in linear domain before gamut mapping. ' ...
                    'Consider to convert via ''.linearize'' before gamut mapping'])
    end
    
    
    % make sure mapping color space is xColorSpace and set correct encoding white
    mappingColorSpace = xCamCS(mappingColorSpace).setAdaptationWhite(img.getColorSpace.getAdaptationWhite)

    
    
    %% TODO: fallunterscheidung xPixel, xImage?

    switch lower(gmaName)
        case 'sclip'
            [imgGamutMapped]= gmaSCLIP(img, mappingColorSpace, varargin);
    end       
    
end

