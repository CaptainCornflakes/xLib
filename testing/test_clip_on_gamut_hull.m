%% creating sRGB in IPT
gh = x3PrimaryCS('p3d65').getGamutHull('triangle',17);

%gh2.show
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
srcPoint = xPoint([0.02 0.08 0.09]);
srcPoint.show

xlabel I
ylabel P
zlabel T
grid on
%% creating mapping direction
targetPoint = xPoint([0.06, 0, 0]);

%% creating line for mapping direction
mappingVector = xLine([srcPoint.data targetPoint.data]);
mappingVector.show



%% calculate intersection
[flag, intersect] = lineTriangleIntersect(mappingVector, ghLab, 'any2any');

%%
show(intersect,[0 0 1], 15)


xlabel I
ylabel P
zlabel T
grid on
%%
ax = gca;               % get the current axis
ax.Clipping = 'off';    % turn clipping off
%%
%% DEBUG CLIP ON GAMUT HULL

% Error using  ' 
% TRANSPOSE does not support N-D arrays. Use PAGETRANSPOSE/PAGECTRANSPOSE to transpose pages or PERMUTE to reorder dimensions of N-D arrays.
% 
% Error in lineTriangleIntersect (line 143)
%                 u(index) = f(index)'.*dot(s(:,index),p(:,index),1);
% 
% Error in test_clip_on_gamut_hull (line 41)
% lineTriangleIntersect(mappingVector, ghLab, 'any2any')


