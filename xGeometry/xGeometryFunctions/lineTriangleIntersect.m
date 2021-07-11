function [intersectionIdx, intersectionPoints] = lineTriangleIntersect(Line, Triangle, varargin)
%lineTriangleIntersect2 checks possible intersection of lines and triangles
% inputs: lineTriangleIntersect(Line, Triangle, Mode)
% first input is the line(s), second input is the triangle(s)
% output is [intersectionIdx, intersection] as raw data
%
%Modes:
%   - 'FullLine' uses the infinite line and is not restricted to the given 
%      endpoints
%   - 'Any2Any' checks any line against any triangle and deliveress the
%     nearest to the first point forming the line


%% calculations based on:
% http://paulbourke.net/geometry/pointlineplane/
% http://paulbourke.net/geometry/pointlineplane/intersectionLinePlane.R


%%
    %both modes disabled, probably needed for future
    % implementations
    FullLine = false;
    Any2Any = false;

    %% case differentiation 'FullLine'/'Any2Any'/other
    % check all varargin and ignore Line and Triangle
    for i=1:1:nargin-2  % nargin-2 = number of args - Line and Triangle = varargin, steps of 2 because of setting 'FullLine'/'Any2Any' true (see function description)
        switch lower(varargin{i})
            case 'fullline'
                FullLine = true;
                disp('mode ''FullLine'' not yet implemented')
            case 'any2any'
                Any2Any = true;   
            otherwise
                error(['argument' varargin{i} 'not allowed'])
        end
    end

    %% ------------------------------------------------------------------
    %% --- DEBUG START --------------------------------------------------
    
     %% --- 2 lines and 2 triangles --------------------------------------
 
%     Line = xLine([0.1 0 0.4 0.5 1 0.5; 0.1 0 0.1 0.1 1 0.1]);
%     Triangle = xTriangle([0.9 0.5 0.2 0.2 0.7 0.4 0.2 0.5 0.9; ...
%                0.7 0.2 0.1 0.1 0.1 0 1 0.3 0.3]);
%     Any2Any = true;
%     
%     show(Line)
%     show(Triangle)
%
%    %% --- line with point exact on triangle ----------------------------
%     Any2Any = true;
%     Triangle = xTriangle([0.5 0 0 0.5 1 0 0.5 0.5 1]);
%     Line = xLine([0.5 0.5 0, 0 0.5 0.5 ]); 


    %% problemfall 
%      Any2Any = true;
%      Triangle = xTriangle([0.677488593541816,0.00219713651569610,-0.169824394534697,0.662919596219348,-0.0230988525440732,-0.177209218249543,0.607826857360545,0.00114496343277381,-0.212044902073140]);
% 
%       px = xPixel([0.982041212506693,0.00356326899180609,0.0142549641129556,0.500000000000000,0,0]).setColorSpace(x3PrimaryCS('sRGB').setBlackLevel(0).setEncodingWhite(1,'Y').setAdaptationWhite(1,'Y')).toXYZ.setColorSpace('oklab').fromXYZ;
%       Line = xLine([0.5 0 0 px.data(1) px.data(2) px.data(3)])
%           
%      Line = xLine([0.5 0 0 0.966202 0.0139881 0.00962699])
%     
%     Line.show
%     Triangle.show
    
%    
%    %% --- gamut hull ---------------------------------------------------
%     
%     % set mode any2any
%     Any2Any = true;
%     
%     % get sRGB gamut hull
%     Triangle = x3PrimaryCS('sRGB').getGamutHull('triangle',3);
% 
%     % CS transformation to lab
%     pix = xPixel( Triangle ).setColorSpace(x3PrimaryCS( 'sRGB' ) ... %set CS to sRGB
%                        .setBlackLevel(0).setEncodingWhite(1,'Y'))... %set encoding white and blacklevel properly
%                        .toXYZ.setColorSpace('oklab').fromXYZ; %set CS to OkLab 
% 
%     %store pixel data in gamut hull
%     ghLab = Triangle.setPoint(pix);
% 
%     % plot
%     hold off
%     ghLab.show(xPixel(Triangle))
% 
%     % creating srcPoint OOG
%     hold on
%     srcPoint = xPoint([0.4 0.4 0.09]);
%     srcPoint.show
%     
%     % creating mapping direction
%     targetPoint = xPoint([0.6, 0, 0]);
%     % creating line for mapping direction
%     Line = xLine([srcPoint.data targetPoint.data]);
%     Line.show
%     
%     %axis labeling
%     xlabel L*
%     ylabel a*
%     zlabel b*
%     grid on
%     
%     
    %% --- DEBUG END ----------------------------------------------------
    %% ------------------------------------------------------------------



    %% variable declaration
    % get line, triangle and number of lines and triangles
    rawLines = Line.getLine;
    numLines = getNumElements(Line);
    
    rawTris = Triangle.getTriangle;
    numTris = getNumElements(Triangle);
    
    intersectionPoints = zeros(numLines,3);
    intersectionIdx = logical(zeros(numLines,1)); %#ok<LOGL>
    
    %% INPUT ARGS = xLine and xTriangle
    if isa(Line, 'xLine') && isa(Triangle, 'xTriangle')
        if Any2Any == true
            for i = 1:numLines % 1. check every line
                
                % index of current line
                %iL = i;
                
                % get start- and endpoints of current line (transposed)
                L1 = rawLines(i,1:3)';
                L2 = rawLines(i,4:6)';
                
                % get directional vector from L1 to L2
                vL1L2 = L2-L1;
                
                for ii = 1:numTris % 2. with every triangle
                    
                    % get points of current triangle (transposed)
                    T1 = rawTris(ii, 1:3)'; % 1. point triangle
                    T2 = rawTris(ii, 4:6)'; % 2. point triangle
                    T3 = rawTris(ii, 7:9)'; % 3. point triangle
                    
                    % defining both vectors of the triangle from point T1
                    vT1T2 = T2-T1; % vector from T1 to T2
                    vT1T3 = T3-T1; % vector from T1 to T3
                    
                    % vector from L1 to T3
                    vL1T3 = T3-L1;


                    %% ------- CALC POSSIBLE INTERSECTION -----------------
                    
                    % crossproduct of vectors == triangle's normal 
                    % (from global origin, not triangle's origin)
                    crossprodT = cross(vT1T3, vT1T2);
                    % plot3(0+T1(1),-0.41+T1(2),0+T1(3), 'or') % plot xprodT with local origin of T1
                    
                      
                    % calculating scalar-/dotproduct of the triangles
                        %vectors are orthogonal if dotproduct == 0
                    % normal and the vector between the triangle and the line 
                    n = dot(crossprodT, vL1T3); % between the triangles normal and the vector between T3 and L1 
                    
                    % calculating scalar-/dotproduct of the triangles
                    % normal and the vector of the line 
                    d = dot(crossprodT, vL1L2); % between the triangles normal and the vector of the line
                    
                    % intersection with infinite plane happens if 0 <= n/d <= 1
                    % u defines, how far from L1 lies the intersectionpoint P
                    % (how many units from L1 in the direction vL1L2)
                    % where u=0 is L1 and u=1 is L2
                    u = n/d;
                    

                    if (u >= 0.0) && (u <= 1.0)
                        
                        % point of possible intersection
                        P = L1 + u*vL1L2;
                        
          
                        %% calculate if intersection point lies within triangle
                        % given that the point P lies on the surface of a 
                        % triangle (T1,T2,T3), the surface area of the
                        % plane A (T1, T2, T3, P) should be smaller than the 
                        % surface area of the original triangle.
                        % therefore the calculations below are made to
                        % check, if P lies within the triangle.
                        % basic idea from
                        % https://prlbr.de/2014/liegt-der-punkt-im-dreieck{

                        % the surface area of a triangle is calculated as follows: 
                        % surfTriangle = 0.5 * |(vT1T2 x vT1T3)|
                        % whereby the magnitude of a vector is calculated as sqrt(x^2+y^2+z^2)
                        surfTriangle = 0.5 * sqrt((crossprodT(1)^2 + crossprodT(2)^2 + crossprodT(3)^2));

                        % creating vectors from P to all vectors of the
                        % triangle
                        vPT1 = T1-P; % vector from P to T1
                        vPT2 = T2-P; % vetor from P to T2
                        vPT3 = T3-P; % vector from P to T3

                        % since there are three possibillities to build a triangle through P with T1,T2,T3, 
                        % all possible combinations of connecting the
                        % points via 2 triangles to a plane must be
                        % considered.

                        % crossproducts of all possible triangles using P
                        % and 2 points of the original triangle
                        crossTemp1 = cross(vPT1, vPT2);
                        crossTemp2 = cross(vPT1, vPT3);
                        crossTemp3 = cross(vPT2, vPT3);

                        % calc surface areas of possible triangles trough P
                        surfTriangleTemp1 = 0.5 * sqrt((crossTemp1(1)^2 + crossTemp1(2)^2 + crossTemp1(3)^2)); % surface area temp triangle 1
                        surfTriangleTemp2 = 0.5 * sqrt((crossTemp2(1)^2 + crossTemp2(2)^2 + crossTemp2(3)^2)); % surface area temp triangle 2
                        surfTriangleTemp3 = 0.5 * sqrt((crossTemp3(1)^2 + crossTemp3(2)^2 + crossTemp3(3)^2)); % surface area temp triangle 3

                        % calculating the surface area (plane) of T1,T2,T3,P as two
                        % triangles for each combination
                        surfPlane1 = surfTriangleTemp1 + surfTriangleTemp2; % calc surface of plane 1
                        surfPlane2 = surfTriangleTemp1 + surfTriangleTemp3; % calc surface of plane 2
                        surfPlane3 = surfTriangleTemp2 + surfTriangleTemp3; % calc surface of plane 3

                        % max of all possible planes to avoid wrong combination
                        surfPlane = max([surfPlane1; surfPlane2; surfPlane3]);

                        % check if surface of triangle is greater than
                        % surface of plane
                        if surfTriangle >= surfPlane

                            % intersection true
                            intersectionIdx(i) = true;
                            intersectionPoints(i,:) = P';


                            % display intersection points and T1,T2,T3 of
                            % respective triangle
%                            disp(['Line ', num2str(i), ' intersects with Triangle ', num2str(ii), ' at Point: ' ]);
%                            disp(num2str(P));
%                            hold on
%                            plot3(P(1), P(2), P(3), '*r')
%                            plot3(T1(1), T1(2), T1(3), 'om', 'Markersize', 12);
%                            plot3(T2(1), T2(2), T2(3), 'om', 'Markersize', 12);
%                            plot3(T3(1), T3(2), T3(3), 'om', 'Markersize', 12);

                            % intersection points
                            %store as raw point data

                        end
                    end
                end
            end

        end    
    end
    %disp([num2str(sum(intersectionIdx(:))),'of', num2str(numLines), ' intersection points calculated'])
    
end

