classdef xPoint < xBase
    %xPointD for representing points in threedimentional space
    %   Detailed explanation goes here
    
    properties
        % inherited from xBase: name, path, history, data
    end
    
    methods
        
        %% CONSTRUCTOR
        function obj = xPoint(varargin)
            if nargin == 0
                % standard constructor
            else
                obj = xPoint();
                obj = obj.setPoint(varargin{:});
                disp('xPoint created.')
            end
        end
        
        %% setPoint
        function obj = setPoint(obj,x,y,z)
            % 3 params
            if exist('x','var') && exist('y', 'var') && exist('z','var')
                % if the 2nd dim(->) of x,y,z == 1 and
                % the size of the 1st dim of x,y,z is equal ( = equal amount of points)
                if size(x,2) == 1 && size(y,2) == 1 && size(z,2) == 1 && ...
                        isequal(size(x,1), size(y,1), size(z,1))
                    obj.data = cat(2,x,y,z);
                % if dim1 == 1 and number of elements of dim2 are equal: transpose 
                elseif size(x,1) == 1 && size(y,1) == 1 && size(z,1) == 1 && ...
                        isequal(size(x,2), size(y,2), size(z,2))
                    obj.data = cat(2,x',y',z');
                else
                    error('x,y and z must be n*1 oder 1*n')
                end
                
            % 1 param
            elseif exist('x','var') && ~exist('y','var') && ~exist('z','var')
                if size(x,2) == 3
                    obj.data = x;
                elseif isa(x,'xPixel')
                    obj.data = x.data;
                    obj.name = x.name;
                    obj.path = x.path;
                    obj.history = x.history;
                else
                    error('Using setPoints with only one paprameter expects n*3 list of Points or xPixel/xImage')
                end
                
            else
                error('Wrong setPoints usage')
            end
        end
        
         %% get function
        function points = getPoint(obj)
            points = obj.data;
        end
        
        %% show function
        function h = show(obj, colorsORh, pointSize)
            % Create Colors of they don't exist
            if ~exist('colorsORh','var')
                colorsORh = zeros(obj.getNumElements,3);
            end
            % Move object if there's a handle at the input
            if isa(colorsORh, 'matlab.graphics.chart.primitive.Scatter')
                h = colorsORh;
                if obj.getNumElements == size(h.XData,2)
                    h.XData = obj.data(:,1)';
                    h.YData = obj.data(:,2)';
                    h.ZData = obj.data(:,3)';
                else
                    error(['When moving points the number of elements must not change. ' ...
                        'Your object has ' num2str(obj.getNumElements) ...
                        ' but the handle contains ' num2str(size(colorsORh.XData,1))]);
                end
            else
                % Draw new object
                colors = img2raw(colorsORh);
                % Replicate if it's a single RGB value
                if size(colors,1) == 1
                    colors = repmat(colors,[obj.getNumElements 1]);
                end
                % Warn is size is wrong
                if (size(colors,1) ~= obj.getNumElements)
                    error('Colors have wrong size or type')
                end
                % Check if Point size exists and otherwise set to default
                if ~exist('pointSize','var')
                    pointSize = 2;
                end
                % plot and output handle to Scatter object
                h = scatter3(obj.data(:,1),obj.data(:,2),obj.data(:,3),...
                    pointSize, colors,'filled');
                
                % set plotting labels and grid
                xlabel X
                ylabel Y
                zlabel Z
                grid on
                
            end
        end
        
        
        %% TODO: compute minimum euclidian distance between 2 points
        %% TODO: projection stuff (wrapper, points on triangle, points on lines)
    end
end

