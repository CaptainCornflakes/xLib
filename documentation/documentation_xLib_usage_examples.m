%% ------------------------------------------------------------------------
%% --- xLib DOCUMENTATION AND USAGE EXAMPLES ------------------------------
%% ------------------------------------------------------------------------



%% --- WORKING WITH xOBJECTS ----------------------------------------------
% how to create xObjects
% how to store data
% how to access data

%% creating xObjects and store data
emptyImg = xImage()
% xPixel([px1r px1g px1b; px2r px2g px2b; px3r px3g px3b])
somePixels = xPixel([0 0 0; 0.5 0.5 0.5; 1 1 1])

% creating an array with raw triangles and passing it into an xTriangle obj
rawTris = [1 1 1 2 2 2 3 3 3; 4 4 4 5 5 5 6 6 6; 7 7 7 8 8 8 9 9 9]
tris = xTriangle(rawTris)


%% general indexing
% create some triangles
rawTris = [1 1 1 2 2 2 3 3 3; 4 4 4 5 5 5 6 6 6; 7 7 7 8 8 8 9 9 9]
tris = xTriangle(rawTris)
% select the second one
tris.select(1).getTriangle