%% 06.05.2021 CODING SESSION WITH JAN

%% init gamut hull
gh = x3PrimaryCS('sRGB').getGamutHull('line',17);

gh.show
%% CS transformation
pix = xPixel( gh ).setColorSpace(x3PrimaryCS( 'sRGB' ) ... %set CS to sRGB
      .setBlackLevel(0).setEncodingWhite(1,'Y'))... %set encoding white and blacklevel properly
      .toXYZ.setColorSpace('Lab').fromXYZ; %set CS to Lab 

%% %store pixel data in gamut hull
ghLab = gh.setPoint(pix);

%% plot
hold off
ghLab.show(xPixel(gh))
xlabel('L*')
ylabel('a*')
zlabel('b*')
grid on