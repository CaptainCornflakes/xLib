function img = XYZ2Lab(img,XYZWhitepoint)
%Lab2XYZ Convert L*a*b* to linear XYZ
%   You need to specify a Whitepoint as 'D65' for conversion
%   ToDo: Whitepoint for hdr Images ?

[img,meta] = img2raw(img);
% Make it possible to input a Whitepoiunt as XYZ or char like 'D65_31' 
white = xColorSpace.getWhitePoint(XYZWhitepoint);


f = zeros(size(img,1),3);
index = zeros(size(img,1),3);

for i=1:3
    index(:,i) = (img(:,i)/white(i)) > (216/24389);
    f(:,i) = index(:,i).*(img(:,i)/white(i)).^(1/3);
    f(:,i) = f(:,i) + (1-index(:,i)).*((24389/27)*(img(:,i)/white(i)) + 16)/116;
end

% Scale and convert to color difference
img(:,1) = 116*f(:,2) - 16;
img(:,2) = 500*(f(:,1) - f(:,2));
img(:,3) = 200*(f(:,2) - f(:,3));

img = raw2img(img,meta);

if isa(img,'xBase')
    img = img.setHistory(['converted from XYZ to Lab with whitepoint:' num2str(white)]);
end

end