classdef xLine < xPoint
    %xLine for representing lines in threedimentional space
    % to declare more than one line in a xLine obj, use lines = xLine([Ax1 Ay1 Az1 Ax2 Ay2 Az2; Bx1 By1 Bz1 Bx2 By2 Bz2; ...])
    %
    % data is stored like this:
    %   Ax1 Ay1 Az1
    %   Bx1 By1 By1
    %   Ax2 Ay2 Az2
    %   Bx2 By2 Bz2
    
    properties
        % inherited from xBase: name, path, history, data
        idx
    end
    
    methods
        %% CONSTRUCTOR
        function obj = xLine(varargin)
           if nargin == 0
               % standard constructor
           else
               obj = xLine();
               obj = obj.setLine(varargin{:});
           end
        end
        
        %% setLine
        function obj = setLine(obj,x1,y1,z1,x2,y2,z2)
            %% 6 params
            if exist('x1','var') && exist('y1','var') && exist('z1','var') && ...
               exist('x2','var') && exist('y2','var') && exist('z2','var')    
                %                 if size(x1,2) == 1 && size(y1,2) == 1 && size(z1,2) == 1 && ...
                %                         size(x2,2) == 1 && size(y2,2) == 1 && size(z2,2) == 1 && ...
                %                         isequal(size(x1,1), size(y1,1), size(z1,1), size(x2,1), size(y2,1), size(z2,1))
                %                     obj.data = cat(1,cat(2,x1,y1,z1),cat(2,x2,y2,z2));
                %                     obj.idx = cat(2,[1:1:size(x1,1)]',[(size(x1,1)+1):1:(size(x1,1)*2)]');
                %                 elseif size(x1,1) == 1 && size(y1,1) == 1 && size(z1,1) == 1 && ...
                %                         size(x2,1) == 1 && size(y2,1) == 1 && size(z2,1) == 1 && ...
                %                         isequal(size(x1,2), size(y1,2), size(z1,2), size(x2,2), size(y2,2), size(z2,2))
                %                     obj.data = cat(1,cat(2,x1',y1',z1'),cat(2,x2',y2',z2'));
                %                     obj.idx = cat(2,(1:1:size(x1',1))',((size(x1',1)+1):1:(size(x1',1)*2))');
                %                 else
                error('xLine.setLine: NOT IMPLEMENTED YET x1,y1,z1,x2,y2 and z2 must be n*1 oder 1*n')
                %                 end
           
            %% 2 params
            elseif exist('x1','var') && exist('y1','var') && ~exist('z1','var') && ...
                    ~exist('x2','var') && ~exist('y2','var') && ~exist('z2','var')
                %warning('in 2 params')
                if size(x1,2) == 3 && size(y1,2) == 2
                    % Case vertices and indices
                    obj.data = x1;
                    obj.idx = y1;
                else
                    size(x1,1)
                    size(y1,1)
                    size(x1,2)
                    size(y1,2)
                    error('xLine.setLine: Wrong setLine usage')
                end
                
            %% 1 param
            elseif exist('x1','var') && ~exist('y1','var') && ~exist('z1','var') && ...
                    ~exist('x2','var') && ~exist('y2','var') && ~exist('z2','var')
                
                if isa(x1,'xPixel')
                    obj.data = x1.data;
                    obj.idx = cat(2,(1:1:size(x1.data,1))',((size(x1.data,1)+1):1:(size(x1.data,1)*2))');
                    obj.name = x1.name;
                    obj.path = x1.path;
                    obj.history = x1.history;
                elseif isa(x1,'xPoint')
                    obj.data = x1.data;
                    obj.idx = cat(2,(1:1:size(x1.data,1))',((size(x1.data,1)+1):1:(size(x1.data,1)*2))');
                    obj.name = x1.name;
                    obj.path = x1.path;
                    obj.history = x1.history;
                elseif size(x1,2) == 6
                    obj.data = cat(1,x1(:,1:1:3),x1(:,4:1:6));
                    obj.idx = cat(2,(1:1:size(x1,1))',((size(x1,1)+1):1:(size(x1,1)*2))');
                else
                    error('xLine.setLine: Using setLine with only one paprameter expects xPixel or n*6 list of Points')
                end
            else
                error('xLine.setLine: Wrong usage of xLine Contructor')
            end               
        end
       
        %% getLine
         % gives back start and endpoint of line
        function rawLine = getLine(obj)
            rawLine = cat(2,obj.data(obj.idx(:,1),:),obj.data(obj.idx(:,2),:));
        end
        
        % lenghts of the lines
        function len = length(obj)
            len = xPoint(obj.data(obj.idx(:,1),:)).distance(xPoint(obj.data(obj.idx(:,2),:)));
        end
        
        function obj = setVertex(obj,vertex)
            if size(vertex,2)~=3
                error('vertex must be n*3')
            end
            obj.data = vertex;
        end
        
        %% show function
        function h = show(obj, colorsORh, lineWidth)
            
            % create colors if they don't exist
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
                    error(['When moving lines the number of elements must not change. ' ...
                        'Your object has ' num2str(obj.getNumElements) ...
                        ' but the handle contains ' num2str(size(h.Faces,1))]);
                end
            else
                % draw new object
                colors = img2raw(colorsORh);
                
                % Replicate if it's a single RGB value
                if size(colors,1) == 1
                    colors = repmat(colors,[size(obj.data,1) 1]);
                end
                
                % warn if size is wrong
                if (size(colors,1) ~= size(obj.data,1))
                    error(['Colors have wrong size or type. xLine.show expects '...
                        'colors that conform to the number of underlying vertices not the number of lines!'])
                end
                % check if line width exists and otherwise set to default
                if ~exist('lineWidth','var')
                    lineWidth = 1.2;
                end
                
                % plot and output handle to Scatter object
                h = patch('Faces',obj.idx,'Vertices',obj.data,'FaceColor','none',...
                    'FaceVertexCData',colors,'EdgeColor','flat','LineWidth',lineWidth);
                
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
     end
end

