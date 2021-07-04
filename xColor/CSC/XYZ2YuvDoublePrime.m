function img = XYZ2YuvDoublePrime(img)
%Conversion according to Philips Y''u''v'' MPEG M34335 but using symetric workflow

[img,meta] = img2raw(img);

% calc WP:
WP = XYZ2Yuv1976(xColorSpace.getWhitePoint('D65_31'));

% First convert to Yu'v'1976
f = zeros(size(img));

f(:,1) = img(:,2);
div = (img(:,1)+15*img(:,2)+3*img(:,3));
index = abs(div)>eps;
f(index,2) = 4*img(index,1)./div(index) - WP(2);
f(index,3) = 9*img(index,2)./div(index) - WP(3);

% apply Y nonlinearity 
LPCF =  @(Y)log(max(Y./10000,0).^(1/2.0676).*(exp(4.3365)-1)+1)./4.3365; % Original Paper
%LPCF = @(x)L2PQ(x); % Practical implementations

f(:,1) = LPCF(f(:,1));

% apply u' v' attanuation (simplified formula because for us D65 is [0 0])
% calc ranges to reduce chroma
idx1 = f(:,1) < 0.25 & f(:,1) > (1/256);
idx2 = f(:,1) <= (1/256);

f(idx1,2:3) = f(idx1,2:3).*(cat(2,f(idx1,1),f(idx1,1)).*(4-488/996/32)+488/996/128);
f(idx2,2:3) = f(idx2,2:3)./128;

img = raw2img(f,meta);

if isa(img,'xBase')
    img = img.setHistory(['Converted from XYZ to Phlips Y''''u''''v'''' ']);
end

end