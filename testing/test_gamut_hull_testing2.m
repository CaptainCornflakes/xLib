%% 06.05.2021 CODING SESSION WITH JAN

%% init gamut hull
gh = x3PrimaryCS('sRGB').getGamutHull('line',17);

%gh.show
%% CS transformation
pix = xPixel( gh ).setColorSpace(x3PrimaryCS( 'sRGB' ) ... %set CS to sRGB
      .setBlackLevel(0).setEncodingWhite(1,'Y'))... %set encoding white and blacklevel properly
      .toXYZ.setColorSpace('Lab').fromXYZ; %set CS to Lab 

% pix = xPixel(gh).setColorSpace('sRGB').toXYZ.setColorSpace('Lab').fromXYZ;
%% %store pixel data in gamut hull
ghLab = gh.setPoint(pix);

%% plot
%hold off
ghLab.show(xPixel(gh)) % giving the xPixel obj colorizes the hull
xlabel L*
ylabel a*
zlabel b*
grid on


%%
pix = xPixel(xImage('testcolors'));

pix.setColorSpace(x3PrimaryCS('sRGB').setBlackLevel(0).setEncodingWhite(1, 'Y').toXYZ.setColorSpace('Lab').fromXYZ)


%% TESTING DIFFERENT GAMUT DESCRIPTIONS

gh2 = x3PrimaryCS('p3d65').getGamutHull('line',17);

%gh2.show
% CS transformation
pix2 = xPixel( gh2 ).setColorSpace(x3PrimaryCS( 'p3d65' ) ... %set CS to sRGB
      .setBlackLevel(0).setEncodingWhite(1,'Y'))... %set encoding white and blacklevel properly
      .toXYZ.setColorSpace('Lab').fromXYZ; %set CS to Lab 

%store pixel data in gamut hull
ghLab2 = gh2.setPoint(pix2);

% plot
hold off
ghLab2.show(xPixel(gh2))
xlabel L*
ylabel a*
zlabel b*
grid on

%%
%% TESTING DIFFERENT GAMUT DESCRIPTIONS

gh3 = x3PrimaryCS('rec2020').getGamutHull('line',17);

%gh2.show
% CS transformation
pix3 = xPixel( gh3 ).setColorSpace(x3PrimaryCS( 'rec2020' ) ... %set CS to sRGB
      .setBlackLevel(0).setEncodingWhite(1,'Y'))... %set encoding white and blacklevel properly
      .toXYZ.setColorSpace('Lab').fromXYZ; %set CS to Lab 

%store pixel data in gamut hull
ghLab3 = gh3.setPoint(pix3);

% plot
hold off
ghLab3.show(xPixel(gh3))
xlabel L*
ylabel a*
zlabel b*
grid on

%% TESTING 4

gh4 = x3PrimaryCS('srgb').getGamutHull('line',17);

%gh2.show
% CS transformation
pix4 = xPixel( gh4 ).setColorSpace(x3PrimaryCS( 'srgb' ) ... %set CS to sRGB
      .setBlackLevel(0).setEncodingWhite(1,'Y'))... %set encoding white and blacklevel properly
      .toXYZ.setColorSpace('Lab').fromXYZ; %set CS to Lab 

%store pixel data in gamut hull
ghLab4 = gh4.setPoint(pix4);

% plot
hold off
ghLab4.show(xPixel(gh4))
xlabel L*
ylabel a*
zlabel b*
grid on
