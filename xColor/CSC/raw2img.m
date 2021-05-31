function img = raw2img(raw, meta)
%% Img2ImgLine is a funtion to convert JImages to standard Matlab line representation
%
%
if isa(meta,'xPixel')
    img = meta;
    img = img.setPixel(raw);
elseif isa(meta,'xImage')
    img = meta;
    img = img.setImage(raw);
elseif exist('meta','var') && isfield(meta,'dims')
    if meta.dims == 2
%         if meta.height == 1
%             img = raw';
%         elseif meta.width == 1
            img = raw;
%         else
%             error('Non expected input')
%         end
    elseif meta.dims == 3
        % Convert line to flat image
        img = reshape(raw,meta.height,meta.width,3);
    else
        error('Images must be n*m*3 or n*3')
    end
else
    error(['this type is not currently supported by raw2img']);
end
end