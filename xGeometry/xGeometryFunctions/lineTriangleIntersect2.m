function [intersection, P] = lineTriangleIntersect2(Line, Triangle, varargin)
%LINETRIANGLEINTERSECT2 Summary of this function goes here
%   Detailed explanation goes here
% checks if a line and a triangle intersect
% lineTriangleIntersect(Line, Triangle, Mode)
% first input is the line(s), second input is the triangle(s)
% output is [flag, intersection]
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
    % start function with both modes disabled
    FullLine = false;
    Any2Any = false;

    %% case differentiation 'FullLine'/'Any2Any'/other
    % check all varargin and ignore Line and Triangle
    for i=1:1:nargin-2  % nargin-2 = number of args - Line and Triangle = varargin, steps of 2 because of setting 'FullLine'/'Any2Any' true (see function description)
        switch lower(varargin{i})
            case 'fullline'
                FullLine = true;
            case 'any2any'
                Any2Any = true;   
            otherwise
                error(['argument' varargin{i} 'not allowed'])
        end
    end

    
%     %% ------------------------------------------------------------------------
%     %% --------- DEBUG START --------------------------------------------------
%     %% ------------------------------------------------------------------------
% 
%     %% single line and triangle
%     % create test objects
%     Line = xLine([0 0.2 0.2 1 0.8 0.9]);
%     Triangle = xTriangle([ 0.9 0.5 0.2 0.2 0.5 0.4 0.5 0.5 0.9 ]);
%     Any2Any = true;
%     
%     show(Line)
%     show(Triangle)
%     
%     %% 2 lines and 2 triangles
% 
%     Line = xLine([0.1 0 0.4 0.5 1 0.5; 0.1 0 0.1 0.1 1 0.1]);
%     Triangle = xTriangle([0.9 0.5 0.2 0.2 0.7 0.4 0.2 0.5 0.9; ...
%                0.7 0.2 0.1 0.1 0.1 0 1 0.3 0.3]);
%     Any2Any = true;
%     
%     show(Line)
%     show(Triangle)
%     %% ------------------------------------------------------------------------
%     %% --------- DEBUG END ----------------------------------------------------
%     %% ------------------------------------------------------------------------



    %% additional vars
    % get line, triangle and number of lines and triangles
    rawLines = Line.getLine;
    rawTris = Triangle.getTriangle;
    
    numLines = getNumElements(Line);
    numTris = getNumElements(Triangle);
    
    
    %% INPUT ARGS = xLine and xTriangle
    if isa(Line, 'xLine') && isa(Triangle, 'xTriangle')
        
        if Any2Any == true
            for i = 1:numLines % 1. check every line
                
                % index of current line
                iL = i;
                
                % get start- and endpoints of current line (transposed)
                L1 = rawLines(i,1:3)';
                L2 = rawLines(i,4:6)';
                
                % get directional vector from L1 to L2
                vL = L2-L1;      
                
                for ii = 1:numTris % 2. with every triangle
                    
                    % get points of current triangle (transposed)
                    T1 = rawTris(ii, 1:3)'; % 1. point triangle
                    T2 = rawTris(ii, 4:6)'; % 2. point triangle
                    T3 = rawTris(ii, 7:9)'; % 3. point triangle
                    
                    % defining the vectors of the triangle
                    vT1 = T2-T1; % vector from T1 to T2
                    vT2 = T3-T1; % vector from T1 to T3


                    %% ------- CALC POSSIBLE INTERSECTION -----------------
                    
                    % crossproduct of vectors == triangle's normal 
                    % (from global origin, not triangle's origin)
                    crossprodT = cross(vT2, vT1);
                    % plot3(0+T1(1),-0.41+T1(2),0+T1(3), 'or') % plot xprodT with local origin of T1
                    
                      
                    % calculating scalar-/dotproduct of the triangles
                    % normal and the vector between the triangle and the line 
                    n = dot(crossprodT, T3-L1); % == angle between the triangles normal and the vector between T3 and L1 
                    
                    % calculating scalar-/dotproduct of the triangles
                    % normal and the vector of the line 
                    d = dot(crossprodT, L2-L1); % == angle between the triangles normal and the vector of the line
                    
                    % intersection with infinite plane happens if 0 <= n/d <= 1 
                    u = n/d;
                    
                    if u >= 0 && u <= 1
                        
                        % point of possible intersection
                        P = L1 + u*vL;
                        
          
                        %% calculate if intersection point lies within triangle
                        % given that the point P lies on the surface of an 
                        % triangle (T1,T2,T3), the surface area of the
                        % plane A (T1, T2, T3, P) should be smaller than the 
                        % surface area of the original triangle
                        % therefore the calculations below are made to
                        % check, if P lies within the triangle.
                        
                        
                        %surface area original triangle = 0.5 * |(vT1 x vT2)|
                        surfTriangle = 0.5 * abs(crossprodT);
                        
                        % creating vectors
                        vP1 = T1-P; % vector from P to T1
                        vP2 = T2-P; % vetor from P to T2
                        vP3 = T3-P; % vector from P to T3
                        
                        % calculating the surface area of T1,T2,T3,P as two
                        % triangles
                        surfTriangleTemp1 = 0.5 * abs(cross(vP1, vP2)); % triangle 1
                        surfTriangleTemp2 = 0.5 * abs(cross(vP1, vP3)); % triangle 1
                        
                        surfA = surfTriangleTemp1 + surfTriangleTemp2;
                        
                        if surfTriangle >= surfA
                            % intersection true
                            intersection = true;
                        
                            disp(['Line ', num2str(i), ' intersects with Triangle ', num2str(ii), ' at Point: ' ]);
                            disp(num2str(P));
                        
                            hold on
                            plot3(P(1), P(2), P(3), '*r')
                         
%                          %vector from T1 to possible intersection point
%                          vP = P - T1
%                          
%                          dot1 = dot(vP, vT1)
%                          dot2 = dot(vP, vT2)
%                          

%                              plot3(P(1), P(2), P(3), 'og')
                        
                       
                         
                        else
                            intersection = false;
                        end
                    end

                    
                end
            end
        end
        
    end
    
    












end

