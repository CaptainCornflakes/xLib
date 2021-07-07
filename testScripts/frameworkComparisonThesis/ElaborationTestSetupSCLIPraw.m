%% ------------------------------------------------------------------------
%% %%  ELABORATION SCLIP WITHOUT xLib FRAMEWORK
% this script was created as part of the bachelor thesis of maximilian czech
% to compare how SCLIP is performed on an image
% when using the xLib framework or the respective raw code.
% this file contains the raw code version
%% ------------------------------------------------------------------------

%% GET TEST-IMG --------------------------------------------------------
imgTest = getTestImageTestSetupSCLIP();


% start timer
tic
%% ------------------------------------------------------------------------
%% ELABORATION STARTS HERE ------------------------------------------------

%% VARIABLES & SETUP ------------------------------------------------------
% get width and height of img
height = size(imgTest,1);
width = size(imgTest,2);
%reshape img to working dimensions
img = reshape(imgTest(:,:,1:3),[],3);
%%
% create index for every pixel
idx = zeros(size(img,1),1);
for i = 1:size(img,1)
    idx(i) = i;
end

% gamut hull precision (same as in xLib test)
precision = 16;
% blacklevel and encoding white for sRGB
blackLevel = 0;
encWhiteY = 1;

%% TRANSFER FUNCTIONS DEFINITIONS
% fun: sRGB linearisation/delinearisation functions
sRGB2linear = @(x)((x>0.04045).*((x+0.055)./1.055).^2.4 + ...
                    (x<=0.04045).*(x./12.92));
linear2sRGB = @(x)((x>0.0031308).*(1.055.*x.^(1/2.4)-0.055) + ...
                    (x<=0.0031308).*12.92.*x);

% fun: sRGB2XYZ and XYZ2sRGB functions
sRGB2XYZ = @(x)(sRGB2XYZMatrix*(x*(encWhiteY-blackLevel)+blackLevel)')';
XYZ2sRGB = @(x)((sRGB2XYZMatrix\x')'-blackLevel)/(encWhiteY-blackLevel);

% fun: find OOG colors as IDX: 0 if color is in gamut, 1 if OOG
findOOGColors = @(x)not(min(x>=0,[],2) & min(x<=1,[],2));

%% LINEARIZE IMG
imgLin = sRGB2linear(img);

%% FIND OOG COLORS
% create empty list of indices
OOGidx = zeros(size(img,1),1);
% store OOG indices in it
OOGidx = findOOGColors(imgLin);
% find number of OOG colors
numPixelOOG = sum(findOOGColors(imgLin));

% store oog pixel in an separate array
OOGpx = imgLin(OOGidx,:);


%% CREATE GAMUT HULL (GH) OF SRGB -----------------------------------------
% precision = 16;
srcLine = linspace(0,1,precision)';
% build 2D points (from 0 ... 1) of one plane of a cube
[grid2D(:,:,2), grid2D(:,:,1)] = meshgrid(srcLine,srcLine);
g2D = reshape(grid2D(1:1:(precision),1:1:(precision),:),[],2);

% duplicate 2D point plane to 6 planes in 3D
o = ones((precision)^2,1);
z = zeros((precision)^2,1);

            
% same as point, but every side of the cube inside a cell array.
geom = {(cat(2,g2D,z))...
        ,(cat(2,1-g2D,o))...
        ,(cat(2,1-g2D,z)*[0 0 1;0 1 0;1 0 0])...
        ,(cat(2,g2D,o)*[0 0 1;0 1 0;1 0 0])...
        ,(cat(2,(repmat([0 1],(precision)^2,1)-g2D)...
            *[-1 0; 0 1],z)*[1 0 0;0 0 1;0 1 0])...
        ,(cat(2,(repmat([1 0],(precision)^2,1)-g2D)...
            *[1 0; 0 -1],o)*[1 0 0;0 0 1;0 1 0])};

% linearisation 
for i=1:1:6
geom{i} = sRGB2linear(geom{i});
end

triangles = cat(1, geom{1}, geom{2}, geom{3}, geom{4}, geom{5}, geom{6});            
% building block 1: start setting up index for all starting points
bVec = (1:1:(precision-1)^2)';
% building block 2: offset to account for step from plane border to next line
offs = reshape(repmat(1:1:(precision-1),(precision-1),1),1,(precision-1)^2)';
% index for one plane
planeIdx = cat(1,cat(2,bVec+offs-1,bVec+offs,bVec+precision+offs),...
    cat(2,bVec+offs-1,bVec+precision+offs-1,bVec+precision+offs));
% add offsets to 6 times repmatted plane
idx = repmat(planeIdx,6,1) + ...
        reshape(repmat(0:(precision^2):(precision^2*5),...
        (precision-1)^2*2*3,1),3,(precision-1)^2*2*6)';           


%% TRANFSER GH AND OOG PIXELS FROM sRGB TO OKLAB -------------------------- 
% sRGB to XYZ transformation
ghXYZ = sRGB2XYZ(triangles);
pxXYZ = sRGB2XYZ(OOGpx);

% transfer gamut hull from XYZ to Oklab
ghOklabRaw = XYZ2OKLAB(ghXYZ);
% reshape to n*9 array where each row is one triangle of the GH
ghOklabReshaped = cat(2, ghOklabRaw(idx(:,1),:), ghOklabRaw(idx(:,2),:), ...
                                    ghOklabRaw(idx(:,3),:));
% create struct with idx and reshaped triangle data
ghOklab.idx = idx;
ghOklab.triangles = ghOklabReshaped;

% convert OOG pixels to Oklab
pxOklab = XYZ2OKLAB(pxXYZ);


%% SCLIP GAMUT MAPPING ----------------------------------------------------

%% PREPARE GAMUT MAPPING
% center of lightness axis Oklab
% Oklab whitepoint is Y=1, x=0.3127, y=0.3290 therefore:
centerL = [0.5 0 0];
% create one point in center of lightness axis for each OOG color
mappingDirection = repmat(centerL, numPixelOOG, 1);
% build mapping lines from OOG colors to center of lightness axis
mappingLines = cat(2, pxOklab, mappingDirection);


%% CALCULATE INTERSECTIONS BETWEEN MAPPING LINES AND GH
% get num mapping lines
numLines = numPixelOOG;
% get num triangles of GH
numTris = size(ghOklab.idx,1);
ghOklab.triangles = ghOklab.triangles;

% create empty arrays for intersection points and intersection indices
intersectionPoints = zeros(numLines,3);
intersectionIdx = false(numLines,1);

% calc intersection
for i = 1:numLines % 1. check every line     
    % get start- and endpoints of current line (transposed)
    L1 = mappingLines(i,1:3)';
    L2 = mappingLines(i,4:6)';
    % get directional vector from L1 to L2
    vL1L2 = L2-L1;

    for ii = 1:numTris % 2. with every triangle
        % get points of current triangle (transposed)
        T1 = ghOklab.triangles(ii, 1:3)'; % 1. point triangle
        T2 = ghOklab.triangles(ii, 4:6)'; % 2. point triangle
        T3 = ghOklab.triangles(ii, 7:9)'; % 3. point triangle

        % defining both vectors of the triangle from point T1
        vT1T2 = T2-T1; % vector from T1 to T2
        vT1T3 = T3-T1; % vector from T1 to T3
        % vector from L1 to T3
        vL1T3 = T3-L1;


        %% CALC POSSIBLE INTERSECTION

        % crossproduct of vectors == triangle's normal 
        % (from global origin, not triangle's origin)
        crossprodT = cross(vT1T3, vT1T2);
        % plot3(0+T1(1),-0.41+T1(2),0+T1(3), 'or') % plot xprodT with ...
        % local origin of T1

        % calculating scalar-/dotproduct of the triangles
        % normal and the vector between the triangle and the line
        % vectors are orthogonal if dotproduct == 0
        n = dot(crossprodT, vL1T3);

        % calculating scalar-/dotproduct of the triangles
        % normal and the vector of the line 
        d = dot(crossprodT, vL1L2);

        % intersection with infinite plane happens if 0 <= n/d <= 1
        % u defines, how far from L1 lies the intersectionpoint P
        % (how many units from L1 in the direction vL1L2)
        % where u=0 is L1 and u=1 is L2
        u = n/d;

        if (u >= 0) && (u <= 1)
            % point of possible intersection
            P = L1 + u*vL1L2;
            
            %% calculate if intersection point lies within triangle
            

            % surface area triangle calculation:  0.5 * |(vT1T2 x vT1T3)|
            % magnitude of a vector is calculated as sqrt(x^2+y^2+z^2)
            surfTriangle = 0.5 * sqrt((crossprodT(1)^2 + crossprodT(2)^2 ...
                                        + crossprodT(3)^2));

            % creating vectors from P to all vectors of the triangle
            vPT1 = T1-P;
            vPT2 = T2-P;
            vPT3 = T3-P;

            % since there are three possibillities to build a triangle 
            % through P with T1,T2,T3, 
            % all possible combinations of connecting the
            % points via 2 triangles to a plane must be
            % considered.

            % crossproducts of all possible triangles using P and 2 points 
            % of the original triangle
            crossTemp1 = cross(vPT1, vPT2);
            crossTemp2 = cross(vPT1, vPT3);
            crossTemp3 = cross(vPT2, vPT3);

            % calc surface areas of possible triangles trough P
            surfTriangleTemp1 = 0.5 * sqrt((crossTemp1(1)^2 + crossTemp1(2)^2 + crossTemp1(3)^2));
            surfTriangleTemp2 = 0.5 * sqrt((crossTemp2(1)^2 + crossTemp2(2)^2 + crossTemp2(3)^2));
            surfTriangleTemp3 = 0.5 * sqrt((crossTemp3(1)^2 + crossTemp3(2)^2 + crossTemp3(3)^2));

            % calculating the surface area (plane) of T1,T2,T3,P as 
            % two triangles for each combination
            surfPlane1 = surfTriangleTemp1 + surfTriangleTemp2;
            surfPlane2 = surfTriangleTemp1 + surfTriangleTemp3;
            surfPlane3 = surfTriangleTemp2 + surfTriangleTemp3;

            % max of all possible planes to avoid wrong combination
            surfPlane = max([surfPlane1; surfPlane2; surfPlane3]);

            % check if surface of triangle is greater than 
            if surfTriangle >= surfPlane

                % intersection true
                intersectionIdx(i) = true;
                intersectionPoints(i,:) = P';
            end
        end
    end
end

%% PREPARE MAPPED IMG -----------------------------------------------------
%% convert intersectionPoints back to sRGB
% Oklab2XYZ
pxMappedXYZ = OKLAB2XYZ(intersectionPoints);
% XYZ2sRGB
pxMapped = XYZ2sRGB(pxMappedXYZ);

%% STORE MAPPED PX BACK IN IMG

imgMappedLin = imgLin;
if size(pxMapped,1) == numPixelOOG
    imgMappedLin(OOGidx,:) = pxMapped;
else
    error('number of mapped pixels does not equal the number of OOG pixel')
end

%% DELINEARIZE MAPPED IMG
imgMapped = linear2sRGB(imgMappedLin);


%% RESHAPE IMG TO STANDARD REPRESENTATION OF IMAGES IN MATLAB
imgFinal = reshape(imgMapped, height, width, 3);


% elapsed time
timeRaw = toc




%% FUNCTIONS --------------------------------------------------------------
function M = sRGB2XYZMatrix
% this function calculates the transformation matrix from sRGB to XYZ values

% define sRGB primaries as well as D65 whitepoint definition
xr = 0.64;
yr = 0.33;
xg = 0.30;
yg = 0.60;
xb = 0.15;
yb = 0.06;

xw = 0.3127;
yw = 0.3290;

% encodingWhite Y = 1 for correct conversions
Yw = 1;
%calc Xw and Zw
Xw = xw*Yw / yw;
Zw = (1.0 - xw - yw)*Yw / yw;

%calc XYZ of primaries
Xr = xr/yr;
Yr = 1;
Zr = (1-xr-yr)/yr;

Xg = xg/yg;
Yg = 1;
Zg = (1-xg-yg)/yg;

Xb = xb/yb;
Yb = 1;
Zb = (1-xb-yb)/yb;

% find scaling, divisoin for better numerical stability
% inv([Xr Xg Xb;Yr Yg Yb;Zr Zg Zb])*[Xw; Yw; Zw]
S = [Xr Xg Xb;Yr Yg Yb;Zr Zg Zb]\[Xw; Yw; Zw];

% scale conversion matrix
M = [S';S';S'].*[Xr Xg Xb;Yr Yg Yb;Zr Zg Zb];
end


function img = XYZ2OKLAB(img)
% this function transforms XYZ values to OKLAB
%% --- DEFINING MATRICES
% https://bottosson.github.io/posts/oklab/

% matrix M1 for converting XYZ values to cone responses
M1 = [0.8189330101, 0.3618667424, -0.1288597137; ...
      0.0329845436, 0.9293118715, 0.0361456387; ...
      0.0482003018, 0.2643662691, 0.6338517070];
% matrix M2 to transform from nonlinear cone response to Lab coordinates
M2 = [0.2104542553, 0.7936177850, -0.0040720468; ...
      1.9779984951, -2.4285922050, 0.4505937099; ...
      0.0259040371, 0.7827717662, -0.8086757660];

      
%% COMPUTATION
% 1. convert XYZ to approximate cone response
lms = (M1 * img')';
% 2. apply nonlinearity
% nthroot instead of .^(1/3) to avoid complex nums 
lmsNonLin = nthroot(lms,3);
% 3. transform to Lab coordinates
img = (M2 * lmsNonLin')';
end

function img = OKLAB2XYZ(img)
% this function transforms OKLAB values to XYZ

%% DEFINING MATRICES
% https://bottosson.github.io/posts/oklab/

% inverse matrix M1 for converting cone responses to XYZ
invM1 = [0.8189330101, 0.3618667424, -0.1288597137; ...
         0.0329845436, 0.9293118715, 0.0361456387; ...
         0.0482003018, 0.2643662691, 0.6338517070] ...
         ^(-1);
% inverse matrix M2 to transform Lab coordinates to nonlinear cone response   
invM2 = [0.2104542553, 0.7936177850, -0.0040720468; ...
         1.9779984951, -2.4285922050, 0.4505937099; ...
         0.0259040371, 0.7827717662, -0.8086757660] ...
         ^(-1);
 
     
%% COMPUTATION
% 1. transform from Lab to nonlinear cone response
lmsNonlin = (invM2 * img')';
% 2. linearize
lms = lmsNonlin.^3;
% 3. transform from cone response to XYZ
img = (invM1 * lms')';
end