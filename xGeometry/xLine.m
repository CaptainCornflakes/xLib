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
        
        
%         %% linetriangleintersect
%         function [flag, intersection] = lineTriangleIntersect2(Line,Triangle,varargin)
%             % start function with both modes disabled
%         FullLine = false;
%         Any2Any = false;
% 
%         %% case differentiation 'FullLine'/'Any2Any'/other
%         % check all varargin and ignore Line and Triangle
%         for i=1:1:nargin-2  % nargin-2 = number of args - Line and Triangle = varargin, steps of 2 because of setting 'FullLine'/'Any2Any' true (see function description)
%             switch lower(varargin{i})
%                 case 'fullline'
%                     FullLine = true; %varargin{i+1};
%                     if ~isa(FullLine,'logical')
%                         error('value for argument ''fullline'' must be logical!')
%                     end
%                 case 'any2any'
%                     Any2Any = true; %varargin{i+1};
%                     if ~isa(Any2Any,'logical')
%                         error('value for argument ''any2any'' must be logical!')
%                     end
% 
%                 otherwise
%                     error(['argument' varargin{i} 'not allowed'])
%             end
%         end
% 
%         %% additional vars
%         % get line, triangle and number of lines
%         rawLines = Line.getLine;
%         rawTris = Triangle.getTriangle;
%         numLines = size(rawLines(:,1:3),1);
% 
% 
%         %% CASE DIFFERENTIATIONS
% 
%         %% input args: xLine, xTriangle
%         if isa(Line, 'xLine') && isa(Triangle, 'xTriangle')
% 
%             % less than 15000000 calculations 
%             % (restriction to prevent RAM from being filled completely on 16GB machine)
%             if (Triangle.getNumElements*Line.getNumElements < 15000000) || ~Any2Any
% 
%                 %transpose all points to vertical representation.
%                 %repmat to get every combination of lines and triangles.
% 
%                 % BASIC STRUCTURE:
%                     % L1 and L2:
%                         % dim1 = X,Y,Z coordinates for one point
%                         % dim2 = number of collums is number of points
%                         % dim3 = duplicate coordinates, number of dim3's is the number of calculations (num of triangles)
% 
%                     % T1, T2, T3:
%                         % dim1 = X,Y,Z coordinates for one point
%                         % dim2 = duplicate coordinates, number of dim2's is the number of calculations (num of lines)
%                         % dim3 = each dim3 holds a different triangle
% 
%                     % e.g. if there are 2 lines and 3 triangles,
%                         %      there will be 3x dim3 (one for each calculation)
%                         %      for L1 and L2 and 2x dim2 for T1,T2,T3
% 
%                 if Any2Any == true
%                     % starting points line(s)
%                     L1 = repmat(permute(rawLines(:,1:3),[2 1 3]),[1 1 Triangle.getNumElements]);
%                     % endpoints line(s)
%                     L2 = repmat(permute(rawLines(:,4:6),[2 1 3]),[1 1 Triangle.getNumElements]);
%                     % points triangle(s)
%                     T1 = repmat(permute(rawTris(:,1:3),[2 3 1]),[1 Line.getNumElements 1]);
%                     T2 = repmat(permute(rawTris(:,4:6),[2 3 1]),[1 Line.getNumElements 1]);
%                     T3 = repmat(permute(rawTris(:,7:9),[2 3 1]),[1 Line.getNumElements 1]);
% 
%                 else
%                     % if number of triangles = multiple of the number of lines
%                     if mod(Triangle.getNumElements,Line.getNumElements) == 0
%                         % starting points line(s)
%                         L1 = repmat(permute(rawLines(:,1:3),[2 1 3]),...
%                             [1 1 Triangle.getNumElements/Line.getNumElements]);
%                         % endpoints line(s)
%                         L2 = repmat(permute(rawLines(:,4:6),[2 1 3]),...
%                             [1 1 Triangle.getNumElements/Line.getNumElements]);
%                         % points triangle(s)
%                         T1 = permute(reshape(rawTris(:,1:3)',3,Line.getNumElements,[]),[1 2 3]);
%                         T2 = permute(reshape(rawTris(:,4:6)',3,Line.getNumElements,[]),[1 2 3]);
%                         T3 = permute(reshape(rawTris(:,7:9)',3,Line.getNumElements,[]),[1 2 3]);
%                     else
%                         error('when using lineTriangleIntersect without option ''Any2Any'' the number of triangles must be a multiple of the number of lines!')
%                     end
%                 end
% 
%                 % triangles per line
%                 TsPerLine = size(L1,3);
% 
%                 % def intersection matrix
%                 % dim1 = X,Y,Z coordinates
%                 % dim2 = one dim for each triangle
%                 % dim3 = one dim for each line
%                 intersection = NaN(3,numLines,TsPerLine);
% 
%                 %% vectorization
%                 epsilon = 10^-5;
%                 % Vektoren die Linie und Ebene aufspannen:
%                 o = L1;     % local origin
%                 d = L2-L1;  % directional vector from L1 to L2 of the lines
%                 e1 = T2-T1; % directional vector from T1 to T2 of the triangles
%                 e2 = T3-T1; % directional vector from T1 to T3 of the triangles
%                 p  = cross(d,e2,1); % cross product p = the normal between d and e2 (line and e2)
%                 a = dot(e1,p,1); % dot product between normal and e1 is zero if Dotprodukt zwischen Normale und e1 ist 0 wenn beide unabhängig, d.h. Linie und Dreieck in einer Ebene            
% 
%                 % index == 1 if cross product < epsilon 
%                 % line lies on the same plane as triangle
%                 index = abs(a) > epsilon;
% 
%                 %% calculations
%                 f = zeros(1, length(L1), TsPerLine);
%                 f(index) = 1./a(index);
% 
%                 %%
%                 s = zeros(3, length(L1), TsPerLine);
%                 s(:,index) = o(:,index)-T1(:,index);
% 
% 
%                 %% ________ AB HIER NUR KOPIERT; NOCHMAL ANSCHAUEN
%                 %%
%                  %%
%                         u = zeros(1,numLines,TsPerLine);
%                         if TsPerLine == 1
%                             u(index) = f(index).*dot(s(:,index),p(:,index),1);
%                         else
%                             u(index) = f(index)'.*dot(s(:,index),p(:,index),1);
%                         end
%                         %% Index aktualisieren für ausserhalb des Dreiecks in Bezug auf u
%                         index = index & (u >= 0 & u <= 1);
%                         %%
%                         q = zeros(3,numLines,TsPerLine);
%                         q(:,index) = cross(s(:,index),e1(:,index),1);
%                         %%
%                         v = zeros(1,numLines,TsPerLine);
%                         if TsPerLine == 1
%                             v(index) = f(index).*(dot(d(:,index),q(:,index),1));
%                         else
%                             v(index) = f(index)'.*(dot(d(:,index),q(:,index),1));
%                         end
%                         %% Index aktualisieren für ausserhalb des Dreiecks in Bezug auf v und u+v
%                         index = index & (v >= 0 & u+v <= 1);
%                         %%
%                         t = zeros(1,numLines,TsPerLine);
%                         if TsPerLine == 1
%                             t(index) = f(index).*(dot(e2(:,index),q(:,index),1));
%                         else
%                             t(index) = f(index)'.*(dot(e2(:,index),q(:,index),1));
%                         end
%                         %% Beschränkung auf die Linie zwischen den Punkten:
%                         if not(FullLine)
%                             index = index & (t >= 0 & t <= 1);
%                         end
% 
%                         %%
%                         if TsPerLine == 1
%                             intersection(:,index) = o(:,index) + repmat(t(index),3,1).*d(:,index);
%                         else
%                             intersection(:,index) = o(:,index) + repmat(t(index)',3,1).*d(:,index);
%                         end
%                         %%
%                         flag = sum(index,3);
% 
%                         % Wenn mehrere Dreiecke geschnitten werden langameren Code ausführen:
%                         if max(flag > 1)
%                             [~, IDX] = max(sqrt(sum((o - intersection).^2,1)),[],3);
%                             intersection = xPoint(intersection(:,(IDX-1).*numLines+(1:1:numLines))');
%                         else
%                             %% Hier muss noch schnellerer Code rein...
%                             [~, IDX] = max(sqrt(sum((o - intersection).^2,1)),[],3);
%                             intersection = xPoint(intersection(:,(IDX-1).*numLines+(1:1:numLines))');
%                         end
% 
%                         % size(intersection)
%                         % intersection = JPoint3D(intersection');
% 
%                     else
%                         %%
%                         disp('Using TriangelLineIntersect to detect more than 10 Million intersections may be very slow!')
% 
%     %                     if Any2Any == false
%     %                         error('More than 10^7 intersections are currently only supported in Any2Any Mode')
%     %                     end
% 
%                         flag = false(numLines,1);
%                         dist = Inf(numLines,1);
%                         intersection = NaN(numLines,3);
%                         %%
%                         for i = 1:1:length(Triangle.P1)
%                             %%
%                             disp(['Checking against Triangle Nr.:' num2str(i)])
%                             TriangleRep = xTriangle(repmat(rawTris(i,1:3),[numLines 1]),...
%                                 repmat(rawTris(i,4:6),[numLines 1]),...
%                                 repmat(rawTris(i,7:9),[numLines 1]));
% 
%     %                         %% Debug
%     %                         clear classes
%     %                         Line = JLine3D([0 0 0;0.1 0.1 0.1;1 0 0;10 10 10],...
%     %                             [1 1 1;0.5 0.7 0.3;2 0 0;10-0.3 10-0.5 10-0.7]);
%     %                         Triangle = JTriangle3D([1 0 0;1 0 0;1 0 3;10 0 0],...
%     %                             [0 1 0; 0.5 0.5 0;0 1 3;0 10 0],...
%     %                             [0 0 1;0 0 0.5;1 1 3;0 0 10]);
%     %                         clear classes
%     %                         Line = JLine3D([0.1 0.1 0.1],...
%     %                             [0.5 0.7 0.3]);
%     %                         TriangleRep = JTriangle3D([1 0 0],...
%     %                             [0.5 0.5 0],...
%     %                             [0 0 0.5]);
%                             %
%                             epsilon = 10^-5;
%                             % Vektoren die Linie und Ebene aufspannen:
%                             o = Line.P1; % Origin
%                             d = Line.P2-Line.P1; % Vektor der Linie
%                             e1 = TriangleRep.P2-TriangleRep.P1; % Vektor 1 des Dreiecks
%                             e2 = TriangleRep.P3-TriangleRep.P1; % Vektor 2 des Dreiecks
%                             p  = cross(d,e2,2); % Kreuzprodukt ergibt Normale zwischen d und e2 (Gerade und e2)
%                             a = dot(e1,p,2); % Dotprodukt zwischen Normale und e1 ist 0 wenn beide unabhängig, d.h. Linie und Dreieck in einer Ebene
% 
% 
%                             % Wenn Kreuzprodukt < epsilon liegt die Gerade in einer Ebene mit dem Dreieck
%                             index = abs(a) > epsilon;
% 
%                             %% Calculations:
%                             f = zeros(numLines,1);
%                             f(index) = 1./a(index);
% 
%                             s = zeros(numLines,3);
%                             s(index,:) =  o(index,:)-TriangleRep.P1(index,:);
% 
%                             u = zeros(numLines,1);
%                             u(index) = f(index).*dot(s(index,:),p(index,:),2);
% 
%                             %% Index aktualisieren für ausserhalb des Dreiecks in Bezug auf u
%                             index = index & (u >= 0 & u <= 1);
%                             %%
%                             q = zeros(numLines,3);
%                             q(index,:) = cross(s(index,:),e1(index,:),2);
%                             %%
%                             v = zeros(numLines,1);
%                             v(index) = f(index).*(dot(d(index,:),q(index,:),2));
% 
%                             %% Index aktualisieren für ausserhalb des Dreiecks in Bezug auf v und u+v
%                             index = index & (v >= 0 & u+v <= 1);
%                             %%
%                             t = zeros(numLines,1);
%                             t(index) = f(index).*(dot(e2(index,:),q(index,:),2));
% 
%                             %% Beschränkung auf die Linie zwischen den Punkten:
%                             if not(FullLine)
%                                 index = index & (t >= 0 & t <= 1);
%                             end
% 
%                             %% flag hier aktualisieren damit doppele Schnitte als Werte größer 1 dedektiert werden.
%                             flag = flag+index;
% 
%                             %% Punkte aus dem Index werfen für die schon eine dem ersten Punkt der Linie nähere Schnittstelle gefunden wurde:
%                             index(index) = index(index) & ( ((t(index).*d(index,1)).^2+...
%                                 (t(index).*d(index,2)).^2+...
%                                 (t(index).*d(index,3)).^2) < dist(index) );
%                             %%
%                             intersection(index,:) = o(index,:) + repmat(t(index),1,3).*d(index,:);
%                             %%
%                             dist(index) = t(index).*(d(index,1).^2+d(index,2).^2+d(index,3).^2);
%                             flag = flag+index;
%                             % clear u q t v index s p f
%                         end
%                         intersection = xPoint(intersection);
% 
%                     end
%                 else
%                     error('TriangelLineIntersect expects first a Line and the a Triangle as input parameters');
%             end
%         end
     end
end

