function img = raw2img(raw, meta)
%% raw2img is a function to convert standard Matlab line representation into xImage/xPixel obj
%   input args are the raw line data and a meta obj, which defines the output class  
%       valid meta obj types are xPixel, xImage or
%       a struct with the fields height, width and dims
%--------------------------------------------------------------------------
% %e.g. with xPixel
%     x = xPixel()
%     rawlines = [0 0 0; 1 1 1]
%     img = raw2img(rawlines], x)
%
% %eg with stuct
%     out.height = []
%     out.width = []
%     out.dims = 2
%     img = raw2img(rawlines, out)
%--------------------------------------------------------------------------



% set img data 
if isa(meta,'xPixel')
    img = meta;
    img = img.setPixel(raw);
elseif isa(meta,'xImage')
    img = meta;
    img = img.setImage(raw);
    
% isfield checks if dims exist, returns logical
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
    error('this type is not currently supported by raw2img');
end
end