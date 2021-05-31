img = xImage(xPixel([0 0 0; 0.18 0.18 0.18; 1 0 0 ; 0 1 0; 0 0 1; 1 1 1]))
%%
img.show
%%
img.getData
%%

img2 = xImage().setColorSpace('sRGB')

%%

testimg = xImage('testcolors')
testimg.getData
testimg.getHistory
testimg.show