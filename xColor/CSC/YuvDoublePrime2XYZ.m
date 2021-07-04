function img = YuvDoublePrime2XYZ( img )
%Conversion according to Philips Y''u''v'' MPEG M34335 but using symetric workflow

% Convert to raw image
[img,meta] = img2raw(img);

% Remove attenuation u' v' attanuation (simplified formula because for us D65 is [0 0])
% calc ranges to reduce chroma
idx1 = img(:,1) < 0.25 & img(:,1) > (1/256);
idx2 = img(:,1) <= (1/256);

img(idx1,2:3) = img(idx1,2:3)./(cat(2,img(idx1,1),img(idx1,1)).*(4-488/996/32)+488/996/128);
img(idx2,2:3) = img(idx2,2:3).*128;

% Remove Y nonlinearity
PLCF =  @(x) 10000 .* max( (exp( x .* 4.3365 ) - 1 ) ./ ( exp( 4.3365 ) - 1 ), 0 ) .^ 2.0676; % Inverted from Original Paper
%LPCF = @(x)L2PQ(x); % Practical implementations
Y = PLCF(img(:,1));

% calc WP:
WP = XYZ2Yuv1976(xColorSpace.getWhitePoint('D65_31'));

% Add WP
u = img(:,2) + WP(2);
v = img(:,3) + WP(3);

% Convert from Yu'v'1976 to XYZ
f = zeros(size(img));

f(:,2) = Y;
f(:,3) = -1*f(:,2).*(3*u+20*v-repmat(12,size(img,1),1))./4./v;
f(:,1) = 9.*f(:,2)./v-15*f(:,2)-3*f(:,3);

% apply Y nonlinearity 

img = raw2img(f,meta);

if isa(img,'xBase')
    img = img.setHistory(['Philips Y''''u''''v'''' to XYZ']);
end

end