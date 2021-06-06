%% ------------------------------------------------------------------------
%% --- xLib DOCUMENTATION AND USAGE EXAMPLES ------------------------------
%% ------------------------------------------------------------------------



%% --- WORKING WITH xOBJECTS ----------------------------------------------
% how to create xObjects
% how to store data
% how to access data

%% creating xObjects and store data
emptyImg = xImage()
% xPixel([px1r px1g px1b; px2r px2g px2b; px3r px3g px3b; ...])
somePixels = xPixel([0 0 0; 0.5 0.5 0.5; 1 1 1; 1.5 1.5 1.5])

% creating an array with raw triangles and passing it into an xTriangle obj
rawTris = [1 1 1 2 2 2 3 3 3; 4 4 4 5 5 5 6 6 6; 7 7 7 8 8 8 9 9 9]
tris = xTriangle(rawTris)


%% general indexing
% create some triangles
rawTris = [1 1 1 2 2 2 3 3 3; 4 4 4 5 5 5 6 6 6; 7 7 7 8 8 8 9 9 9]
tris = xTriangle(rawTris)
% select the second one
tris.select(1).getTriangle

%% how to insert an pixel at specific idx
% define pixel obj and the px that will be inserted
pixels = (xPixel( [ 0 0 0; 1 1 1; 2 2 2; 3 3 3; 4 4 4 ] ) )
newPix = xPixel([9 9 9; 10 10 10])
%create n*1 array with logical values
idx = [false;true;false;false;true];
% insert new pixel at idx 2
newPixels = pixels.insert(newPix, idx);



%% --- display the gamut of an CS in 3D -----------------------------------

% define sRGB gamut hull as xTriangle obj
gh = x3PrimaryCS('sRGB').getGamutHull('triangle',20);

% CS transformation - define sRGB in L*a*b*
pix = xPixel( gh ).setColorSpace(x3PrimaryCS( 'sRGB' ) ... %set CS to sRGB
      .setBlackLevel(0).setEncodingWhite(1,'Y'))... %set encoding white and blacklevel properly
      .toXYZ.setColorSpace('Lab').fromXYZ; %set CS to Lab 

%store pixel data in gamut hull
ghLab = gh.setPoint(pix);

% plot
hold off
ghLab.show(xPixel(gh))



%% test, if pixels are out of gamut (OOG)

%create img with testpixels, set CS to srgb
img1 = xImage(somePixels.getPixel).setColorSpace('srgb')
% since isInGamut expects linear input data, we pretend img1 is linear
img1.setLinear
% check for inGamut and OOG colors (0= OOG, 1== inGamut)
img1.isInGamut

% graphical verification
%1. run cell "display the gamut of an CS in 3D"
%2. get oog pixel:
oog = xPixel(img1.select(4).getPixel)
oogpix= xPixel( oog ).setColorSpace(x3PrimaryCS( 'sRGB' ) ... %set CS to sRGB
      .setBlackLevel(0).setEncodingWhite(1,'Y'))... %set encoding white and blacklevel properly
      .toXYZ.setColorSpace('Lab').fromXYZ; %set CS to Lab
hold on
oogpx = oogpix.getPixel()
plot3(oogpx(1), oogpx(2), oogpx(3), 'or', 'Markersize', 12)
