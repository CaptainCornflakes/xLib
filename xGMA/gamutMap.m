function img = gamutMap(img, gmaName, varargin)
%gamutMap for applying gamut mapping algorithms to an img.
%   inputs are img, gmaName and varargin
%   valid gmaNames are:
%       - 'clip', 'clamp'
%       - 'wminde'

    if ~img.isLinear
                warning(['Images expected to be encoded in linear domain before Gamut Mapping. ' ...
                    'Consider to convert via ''.linearize'' before gamut mapping'])
    end
    
end

