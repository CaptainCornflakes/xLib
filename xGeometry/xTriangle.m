classdef xTriangle < xPoint
    %XTRIANGLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % inherited from xBase: name, path, history, data
        idx
    end
    
    methods
        %% CONSTRUCTOR
        function obj = xTriangle(varargin)
            if nargin == 0
                % standard constructor
            else
                obj = xTriangle();
                obj = obj.setTriangle(varargin{:});
            end
        end
        
        %% setTriangle
        function obj = setTriangle(obj, x1,y1,z1, x2,y2,z2, x3,y3,z3)
            %% 9 params
            if exist('x1', 'var') && exist('y1', 'var') && exist('z1', 'var') ...
                    && exist('x2', 'var') && exist('y2', 'var') && exist('z2', 'var') ...
                    && exist('x3', 'var') && exist('y3', 'var') && exist('z3', 'var')
%                 if size(x1,2) == 1 && size(y1,2) == 1 && size(z1,2) == 1 && ...
%                         size(x2,2) == 1 && size(y2,2) == 1 && size(z2,2) == 1 && ...
%                         size(x3,2) == 1 && size(y3,2) == 1 && size(z3,2) == 1 && ...
%                         isequal(size(x1,1),size(y1,1),size(z1,1),size(x2,1), ...
%                         size(y2,1), size(z2,1), size(x3,1), size(y3,1), size(z3,1))
%                     obj.P1 = cat(2,x1,y1,z1);
%                     obj.P2 = cat(2,x2,y2,z2);
%                     obj.P3 = cat(2,x3,y3,z3);
%                 elseif size(x1,1) == 1 && size(y1,1) == 1 && size(z1,1) == 1 && ...
%                         size(x2,1) == 1 && size(y2,1) == 1 && size(z2,1) == 1 && ...
%                         size(x3,1) == 1 && size(y3,1) == 1 && size(z3,1) == 1 && ...
%                         isequal(size(x1,2), size(y1,2), size(z1,2), size(x2,2), ...
%                         size(y2,2), size(z2,2), size(x3,2), size(y3,2), size(z3,2))
%                     obj.P1 = cat(2,x1',y1',z1');
%                     obj.P2 = cat(2,x2',y2',z2');
%                     obj.P3 = cat(2,x3',y3',z3');
%                 else
%                     error('x1,y1,z1,x2,y2,z2,x3,y3 and z3 must be n*1 oder 1*n')
%                 end
            error('9 param input not yet implemented')
            
            %% 3 params
            elseif exist('x1','var') && exist('y1','var') && exist('z1','var') && ...
                    ~exist('x2','var') && ~exist('y2','var') && ~exist('z2','var') && ...
                    ~exist('x3','var') && ~exist('y3','var') && ~exist('z3','var')
                
%                 if isa(x1,'xImage') && isa(y1,'xImage') && isa(z1,'xImage')
%                     obj.P1 = x1.getImgLine;
%                     obj.P2 = y1.getImgLine;
%                     obj.P3 = z1.getImgLine;
%                     
%                 elseif size(x1,2) == 3 && size(y1,2) == 3 && size(z1,2) == 3 && ...
%                         isequal(size(x1,1), size(y1,1), size(z1,1))
%                     obj.P1 = x1;
%                     obj.P2 = y1;
%                     obj.P3 = z1;
%                 else
%                     error('Wrong setTriangle usage')
%                 end
            error('3 param input not yet implemented')
            
            %% 2 params
            elseif exist('x1','var') && exist('y1','var') && ~exist('z1','var') && ...
                    ~exist('x2','var') && ~exist('y2','var') && ~exist('z2','var') && ...
                    ~exist('x3','var') && ~exist('y3','var') && ~exist('z3','var')
                if size(x1,2) == 3 && size(y1,2) == 3
                    % Case vertices and indices
                    obj.data = x1;
                    obj.idx = y1;
                else
                    size(x1,1)
                    size(y1,1)
                    size(x1,2)
                    size(y1,2)
                    error('xLine.setLine: wrong setLine usage')
                end
                
            %% 1 param
            elseif exist('x1','var') && ~exist('y1','var') && ~exist('z1','var') && ...
                    ~exist('x2','var') && ~exist('y2','var') && ~exist('z2','var') && ...
                    ~exist('x3','var') && ~exist('y3','var') && ~exist('z3','var')
                
                if isa(x1, 'xPixel')
                    obj.data = x1.data;
                    obj.name = x1.name;
                    obj.path = x1.path;
                    obj.history = x1.history;
                    
                elseif size(x1,2) == 9
                    obj.data = cat(1,x1(:,1:1:3),x1(:,4:1:6),x1(:,7:1:9));
                    obj.idx = cat(2,(1:1:size(x1,1))',((size(x1,1)+1):1:(size(x1,1)*2))',...
                        ((size(x1,1)*2+1):1:(size(x1,1)*3))');
                else
                    error('Using setTriangle with only one paprameter expects n*9 list of Points or xImage with NumElements == multiple of 3')
                end
            else
                error('Wrong usage of xTriangle contructor')
            end   
        end
        
        %% getTriangle
        function raw_tris = getTriangle(obj)
            raw_tris = cat(2,obj.data(obj.idx(:,1),:),obj.data(obj.idx(:,2),:),obj.data(obj.idx(:,3),:));
        end
        
        %% check for intersection
        function [flag, intersection] = intersect(triangle,line,varargin)
            [flag, intersection] = xGeometryFunctions.lineTriangleIntersect(line,triangle,varargin{:});
            warning('output is per line! Not per triangle')
        end
        
        %% show function
        function h = show(obj, colorsORh, lineWidth, faceAlpha)

            % Create Colors of they don't exist
            if ~exist('colorsORh','var')
                colorsORh = zeros(size(obj.data,1),3);
            end
            if isa(colorsORh, 'matlab.graphics.primitive.Patch')
                % Move object
                h = colorsORh;
                if obj.getNumElements == size(h.Faces,1)
                    % Update all line positions.
                    h.Vertices = obj.data;
                else
                    error(['When moving triangles the number of elements must not change. ' ...
                        'Your object has ' num2str(obj.getNumElements) ...
                        ' but the handle contains ' num2str(size(h.Faces,1))]);
                end
            else
                %warning('New interpolating patch behaviour when drawing triangles (As of August 2017)')
                % Draw new object
                colors = img2raw( colorsORh );
                
                % Replicate if it's a single RGB value
                if size(colors,1) == 1
                    colors = repmat(colors,[size(obj.data,1) 1]);
                end
                
                % Warn is size is wrong
                if (size(colors,1) ~= size(obj.data,1))
                    error(['colors have wrong size or type. xTriangle.show expects '...
                        'colors that conform to the number of underlying vertices not the number of triangles!'])
                end
                
                % Check if line width exists and otherwise set to default
                if ~exist('lineWidth','var')
                    lineWidth = 2;
                end
                if ~exist('faceAlpha','var')
                    faceAlpha = 0;
                end
                
                % plot and output handle to Scatter object
                if (lineWidth ~= 0) && (faceAlpha == 0)
                    % case only lines should be plotted
                    h = patch('Faces',obj.idx,'Vertices',obj.data,'FaceColor','none',...
                        'FaceVertexCData',colors,'EdgeColor','flat','LineWidth',lineWidth);
                elseif (lineWidth == 0) && (faceAlpha ~= 0)
                    % case only faces should be plotted
                    h = patch('Faces',obj.idx,'Vertices',obj.data,'FaceColor','interp',...
                        'FaceAlpha',faceAlpha,...
                        'FaceVertexCData',uint8(colors*255),'EdgeColor','none');
                elseif (lineWidth ~= 0) && (faceAlpha == 1)
                    % case lines and faces should be plotted
                    h = patch( 'Faces',obj.idx, 'Vertices', obj.data, 'FaceColor', 'interp',...
                        'FaceVertexCData', colors, 'EdgeColor', 'interp', 'LineWidth', lineWidth );
                    disp('Debug - Plotting Triangle with Alpha = 1')
                elseif (lineWidth ~= 0) && (faceAlpha ~= 0)
                    % case lines and faces should be plotted
                    h = patch('Faces',obj.idx,'Vertices',obj.data,'FaceColor','interp',...
                        'FaceVertexCData',colors,'FaceAlpha',faceAlpha,...
                        'EdgeColor','interp','LineWidth',lineWidth,'EdgeAlpha',faceAlpha);      
                else
                    error('Either lineWith or faceAlpha must be non-zero otherwise nothing gets plotted!')
                end
                
                % set plotting labels and grid
                xlabel X
                ylabel Y
                zlabel Z
                grid on
            end
        end
        
        %% get numElements
        function numElements = numElements(obj)
            numElements = size(obj.idx,1);
        end
        
        %% get numElements
        function numElements = getNumElements(obj)
            numElements = size(obj.idx,1);
        end
        
        %% select
        function obj = select( obj, selIdx )
            if islogical( selIdx )
                if size(selIdx,1) == obj.numElements && size(selIdx,2) == 1
                    obj.idx = obj.idx( selIdx, : );
                else
                    error('xPixel.select: Index must be of obj.numElements*1 size')
                end
            elseif isnumeric( selIdx ) && size( selIdx, 2 ) == 1
                    obj.idx = obj.idx( selIdx, : );
            else
                error('xPixel.select: Index must be logical or numeric')
            end
        end
    end
    
    
end

