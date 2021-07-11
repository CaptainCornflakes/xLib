%% creating sRGB in IPT
%funktioniert noch
gh = x3PrimaryCS('sRGB').getGamutHull('triangle',12);

%funktioniert nicht mehr
gh = x3PrimaryCS('sRGB').getGamutHull('triangle',3);

% CS transformation
pix = xPixel( gh ).setColorSpace(x3PrimaryCS( 'sRGB' ) ... %set CS to sRGB
      .setBlackLevel(0).setEncodingWhite(1,'Y'))... %set encoding white and blacklevel properly
      .toXYZ.setColorSpace('ipt').fromXYZ; %set CS to Lab 

%store pixel data in gamut hull
ghLab = gh.setPoint(pix);

% plot
hold off
ghLab.show(xPixel(gh))



%% creating srcPoint OOG
hold on

srcPoints = [0.02 0.08 0.09; 0 0 -0.1]
targetPoint = [0.06 0 0]
%srcPoint = xPoint([0.02 0.08 0.09; 0 0 -0.1]);
%srcPoint.show

% grid on
%% creating mapping direction
%targetPoint = xPoint([0.06 0 0]);

%% creating line for mapping direction
mappingLines = xLine([srcPoints(1,:), targetPoint; srcPoints(2,:), targetPoint]);
%mappingLines = xLine([srcPoints(1,:), targetPoint]);
mappingLines.show



%% calculate intersection
[flag2, intersect2] = lineTriangleIntersect2(mappingLines, ghLab, 'any2any');
%[flag, intersect] = lineTriangleIntersect(mappingLines, ghLab, 'any2any');

%%
%show(intersect,[0 0 1], 15)
%%
xlabel L*
ylabel a*
zlabel b*
grid on
ax = gca;               % get the current axis
ax.Clipping = 'off';    % turn clipping off


%% get triangles from ghLab

%trianglesGhLab = ghLab.getTriangle;

