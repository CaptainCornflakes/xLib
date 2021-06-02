function [raw, meta] = img2raw(img)
%% image2raw is a funtion to convert xPixel/xImage to raw line representation
%
%

% check class of input img
type = class(img);

%case differentiation
switch type
    %if class xImage or xPixel:
    %   store pixel data in raw and delete data in img
    case {'xImage','xPixel'}
        raw = img.getPixel();
        meta = img;
        meta = meta.clearData;
    case {'double','single'}
        if (ismatrix(img)) && (size(img,2)==3)
            % We already have a line, original width and height unknown
            raw = img;
            meta.dims = 2;
            meta.height = size(img,1);
            meta.width = 1;
        elseif (ismatrix(img)) && (size(img,1)==3)
            % We already have a line, original width and height unknown
            raw = img';
            meta.dims = 2;
            meta.height = 1;
            meta.width = size(img,2);
            warning('Horizontal image representation not recommended!')
        elseif (ndims(img) == 3) && (size(img,3)==3)
            % Convert flat image to line
            meta.dims = 3;
            meta.height = size(img,1);
            meta.width = size(img,2);
            raw = reshape(img,[],3);
        else
            error('Images must be n*m*3 or n*3')
        end
    otherwise
        error([class(img) 'is not currently supported by Img2ImgLine']);
end
end