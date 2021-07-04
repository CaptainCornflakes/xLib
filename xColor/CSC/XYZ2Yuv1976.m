function img = XYZ2Yuv1976(img)
%Lab2XYZ Convert Yu'v'1976 to linear XYZ
% Reference: ISO 11664-5:2011-07

[img,meta] = img2raw(img);

f = zeros(size(img));

f(:,1) = img(:,2);
div = (img(:,1)+15*img(:,2)+3*img(:,3));
index = abs(div)>eps;
f(index,2) = 4*img(index,1)./div(index);
f(index,3) = 9*img(index,2)./div(index);

img = raw2img(f,meta);

if isa(img,'xBase')
    img = img.setHistory(['Converted from XYZ to Yu''v'' 1976']);
end

end