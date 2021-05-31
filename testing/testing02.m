% initialize testimages
img1 = xImage('peppers')
img2 = xImage('testcolors')

%%
show(img1)
img2.show

%%
img2.show('3d')

%%
img2.setColorSpace(x3PrimaryCS('sRGB'))

%%
img2.colorSpace.setBlackLevel(0).setEncodingWhite(1, 'Y')
%%
img2.colorSpace.toXYZ.setColorSpace('Lab').fromXYZ



%%
pix = xPixel(img2)

pix2 = pix.setColorSpace(x3PrimaryCS( 'sRGB' ) ... %set CS to sRGB
      .setBlackLevel(0).setEncodingWhite(1,'Y'))... %set encoding white and blacklevel properly
      .toXYZ.setColorSpace('Lab').fromXYZ;
%%
pix2.show

%%%%%%%%%%%
%%
img = xImage('peppers')

gh = img.getColorSpace.getGamutHull('triangle', 17)

%%
gh.show()

%%
ghmCS = gh.setColorSpace(img.getColorSpace).toXYZ.setColorSpace('Lab').fromXYZ.getPixel;

%%
%%
%%
%%
img = xImage('Peppers').setColorSpace('P3D65').clamp(0,1).toXYZ.setColorSpace('sRGB').fromXYZ;
gamutHullTargetCS = img.getColorSpace.getGamutHull('point',17);
ghmCS = gamutHullTargetCS.setColorSpace(img.getColorSpace).toXYZ.setColorSpace('Lab').fromXYZ

%%
points = xPoint(ghmCS.data)

%%
points.show