function img = Yuv19762XYZ(img)
%Lab2XYZ Convert Yu'v'1976 to linear XYZ
% Reference: ISO 11664-5:2011-07

[img,meta] = img2raw(img);

f = zeros(size(img));

f(:,2) = img(:,1); % Y
f(:,3) = -1*f(:,2).*(3*img(:,2)+20*img(:,3)-repmat(12,size(img,1),1))./4./img(:,3);
f(:,1) = 9.*f(:,2)./img(:,3)-15*f(:,2)-3*f(:,3);

% div = (img(:,1)+15*img(:,2)+3*img(:,3));
% index = abs(div)>eps;
% f(index,2) = 4*img(index,1)./div(index);
% f(index,3) = 9*img(index,1)./div(index);

img = raw2img(f,meta);

if isa(img,'xBase')
    img = img.setHistory(['Converted from XYZ to Yu''v'' 1976']);
end

end