function img = Lab2XYZ( img, XYZWhitepoint )
%Lab2XYZ Convert L*a*b* to linear XYZ
%   You need to specify a Whitepoint as 'D65' for conversion
%   ToDo: Whitepoint for hdr Images ?


% %% --- DEBUG --------------------------------------------------------------
% img = xPixel([0 0 0; 0.18 0.18 0.18; 0.5 0.5 0.5; 1 0 0; 0 1 0; 0 0 1; 1 1 1])
% img = img.setColorSpace('Lab');
% XYZWhitepoint = 'D65_31';
% 
% %% ------------------------------------------------------------------------

[img,meta] = img2raw(img);

% Convert from name to XYZ if something like 'D65_31' is supplied
white = xColorSpace.getWhitePoint( XYZWhitepoint );

% Scale to Whitepoint?
%if max(max(Img.Data(:,:,2))) ~= 1
%    white = white .* max(max(Img.Data(:,:,2)));
%    disp(['While converting from XYZ to L*a*b* "Reference White" is not 1!',...
%        'Scaling Reference White by: ',num2str(max(max(Img.Data(:,:,2))))]);
%end

% Calculate fx
f = zeros(size(img,1),3);
%Calculate Fy ( ( L+16 ) / 116 )
f(:,2) = (img(:,1)+16)/116;
%Calculate Fx ( Fy + ( a / 500 ) )
f(:,1) = (img(:,2)/500) + f(:,2);
%Calculate Fz ( Fy - ( b / 200 ) )
f(:,3) = f(:,2) - (img(:,3)/200);

% Remove "Gamma"
% Init Index
index = zeros(size(img,1),3);
% 1 if fx > epsilon
index(:,1) = f(:,1) > (216/24389)^(1/3);
% 1 if L* > k*epsilon
index(:,2) = (img(:,1)) > (216/27);
% 1 if fz > epsilon
index(:,3) = f(:,3) > (216/24389)^(1/3);

% Calculate XYZ before multiplication with whitepoint
xyz = zeros(size(img,1),3);
xyz(:,1) = index(:,1) .* f(:,1).^3 + (1-index(:,1)).*(116*f(:,1) - 16)/(24389/27);
xyz(:,2) = index(:,2) .* ((img(:,1)+16)/116).^3 + (1-index(:,2)).*img(:,1)/(24389/27);
xyz(:,3) = index(:,3) .* f(:,3).^3 + (1-index(:,3)).*(116*f(:,3) - 16)/(24389/27);

% disp('xyz')
% size(xyz)
% disp('white')
% size(repmat(reshape(white,[1 1 3]),[size(Img.Data,1) size(Img.Data,2) 1]))

% Multiply each color with the whitepoint
img = xyz .* repmat( reshape( white, [1 3] ),[size(img,1) 1]);

img = raw2img(img,meta);

if isa(img,'xBase')
    img = img.setHistory(['converted from Lab to XYZ with whitepoint:' num2str(white)]);
end

end
