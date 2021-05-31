function img = CSMatrix(img,SourceColorSpace,TargetColorSpace)
%ANYLRGB2XYZ Convert any linear RGB Color Space defined in RGBColorSpace to XYZ or backwards.
%
%   RGB-Values expected to between 0 ... 1
%   XYZ-Values expected relative to Whitepoint e.g. 48cd/m2 for Cinema and 80cd/m2 for ITU709

%% Convert Color Space Names to JColorSpace Objects if needed: 
if not(strcmpi(class(SourceColorSpace),'xColorSpace'))
SourceColorSpace = xColorSpace.cast(SourceColorSpace);
end

if not(strcmpi(class(TargetColorSpace),'xColorSpace'))
TargetColorSpace = xColorSpace.cast(TargetColorSpace);
end

%% Check if Source Color Space is O.K.
if strcmpi(class(img),'xImage') && (SourceColorSpace ~= img.ColorSpace)
    warning('ColorSpaceConflict, Argument SourceColorSpace is not identical with Img.ColorSpace');
    %warning('Argument SourceColorSpace is not identical with Img.ColorSpace. Setting SourceColorSpace to Img.ColorSpace!!!');
    %SourceColorSpace = Img.ColorSpace;
end

%% Convert input types n*m*3 and JImage to Line representation
[ImgLine, meta] = img2raw(img);

%ImgLine = (calcRGB2XYZMatrix(TargetColorSpace)\(calcRGB2XYZMatrix(SourceColorSpace)*ImgLine'))';
ImgLine = ((calcRGB2XYZMatrix(TargetColorSpace)\calcRGB2XYZMatrix(SourceColorSpace))*ImgLine')';

%% Convert back from Line represantation to n*m*3 double or JImage if needed
img = raw2img(ImgLine, meta);

%% Set correct Colorspace and History if Img is a JImage
if strcmpi(class(img),'xBase')
    img = img.setColorSpace(TargetColorSpace);
    img = img.setHistory(['Converted from ' SourceColorSpace.getName ' to ' TargetColorSpace.getName]);
end

end