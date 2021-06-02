classdef xBase
    %xBASE class
    %    contains basic functions
    
    %% PROPERTIES
    properties (SetAccess = protected)
        name
        data
        path
        history
    end
    
    %% METHODS
    methods
        %% add and get history
        function obj = setHistory(obj,text)
            curTime = fix(clock);
            st = dbstack;
            %define layout for history:
            obj.history = cat(1,obj.history,{[num2str(curTime(1),'%04.0f') '-' ...
                num2str(curTime(2),'%02.0f') '-' num2str(curTime(3),'%02.0f'), ' ' ...
                num2str(curTime(4),'%02.0f') ':' num2str(curTime(5),'%02.0f'), ':'...
                num2str(curTime(6),'%02.0f') ' | ' st(2).name ' | ' text]});
        end
        
        function history = getHistory(obj,type)
           %not exist
           if ~exist('type', 'var')
               history = obj.history;
           %strcmpi compares ard1 and arg2, 1 if identical, 0 if different
           elseif strcmpi(typle, 'plain') || strcmpi(type,'char')
               history = obj.history;
           else
               error('getHistory mut be uses with no argument, to get native history, or plain or string, to get string')
           end
        end
        
       %% set/getName
       %setName
       function obj = setName(obj,name)
           if isa(name,'char')
               obj.name = name;
           else
               error('setName expects char input')
           end
       end
       %getName
       function name = getName(obj)
           if isempty(obj.name)
               error('object has not been assigned a name yet')
           else
               name = obj.name;
           end
       end
       
       %% set/getData
       function obj = setData(obj,data)
           obj.data = data;
       end
       
       function data = getData( obj )
            data = obj.data;
       end
       
       %% set/getPath
       function obj = setPath(obj,path)
           if isa(path,'char')
               obj.path = path;
           else
               error('setPath expects char input')
           end
       end
       
       function path = getPath(obj)
           if isempty(obj.path)
               error('object has not been assigned a path')
           else
               path = obj.path;
           end
       end
       
       %% get numElements
        function numElements = numElements(obj)
            numElements = size(obj.data,1);
        end
        
       %% getNumElements
      function numElements = getNumElements(obj)
            numElements = size(obj.data,1);
      end
      
      %% ---TODO---
      %  implementation of operators from jBase
      %% ToDo: Implement all operators from:
        % http://www.mathworks.com/help/matlab/matlab_oop/implementing-operators-for-your-class.html
        % use .data to make it compatible with geometry and LUTs
        %% +
        function obj1 = plus( obj1, obj2 )
            % xBase + xBase
            if isa(obj1,'xBase') && isa(obj2,'xBase')
                if size(obj1.data,1) == size(obj2.data,1) && size(obj1.data,2) == size(obj2.data,2)
                    obj1.data = obj1.data + obj2.data;
                else
                    error('xBase.plus: Can''t add - Image size different');
                end
            % xBase + scalar 
            elseif isa(obj1,'xBase') && isscalar(obj2) && isfloat(obj2) && isreal(obj2)
                obj1.data = obj1.data + repmat(obj2,[size(obj1.data,1),size(obj1.data,2)]);
            elseif isa(obj2,'xBase') && isscalar(obj1) && isfloat(obj1) && isreal(obj1)
                obj1 = plus(obj2,obj1);
            % xBase + [1 2 3]
            elseif isa(obj1,'xBase') && (size(obj2,1)==1) && (size(obj2,2)==size(obj1.data,2)) ...
                    && isfloat(obj2) && isreal(obj2)
                obj1.data = obj1.data + repmat(obj2,[size(obj1.data,1),1]);
            elseif isa(obj2,'xBase') && (size(obj1,1)==1) && (size(obj1,2)==size(obj1.data,2)) ...
                    && isfloat(obj1) && isreal(obj1)
                obj1 = plus(obj2,obj1);
            % xBase + vec of same size 
            elseif isa(obj1,'xBase') && (size(obj2,1)==size(obj1.data,1)) && ...
                    (size(obj2,2)==size(obj1.data,2)) && isfloat(obj2) && isreal(obj2)
                obj1 = obj1.setPixel(obj1.getPixel + obj2);
            else
                error('xBase.plus: Can only add two xBase Objects or scalars or 1*3 or same size')
            end
        end
        
        %% -
        function obj1 = minus(obj1,obj2)
            % xBase - xBase
            if isa(obj1,'xBase') && isa(obj2,'xBase')
                if size(obj1.data,1) == size(obj2.data,1) && size(obj1.data,2) == size(obj2.data,2)
                    obj1.data = obj1.data - obj2.data;
                else
                    error('xBase.plus: Can''t add - Image size different');
                end
            % xBase - scalar 
            elseif isa(obj1,'xBase') && isscalar(obj2) && isfloat(obj2) && isreal(obj2)
                obj1.data = obj1.data - repmat(obj2,[size(obj1.data,1),size(obj1.data,2)]);
%             elseif isa(obj2,'xBase') && isscalar(obj1) && isfloat(obj1) && isreal(obj1)
%                 obj1 = minus(obj2,obj1);
            % xBase - [1 2 3]
            elseif isa(obj1,'xBase') && (size(obj2,1)==1) && (size(obj2,2)==size(obj1.data,2)) ...
                    && isfloat(obj2) && isreal(obj2)
                obj1.data = obj1.data - repmat(obj2,[size(obj1.data,1),1]);
%             elseif isa(obj2,'xBase') && (size(obj1,1)==1) && (size(obj1,2)==size(obj1.data,2)) ...
%                     && isfloat(obj1) && isreal(obj1)
%                 obj1 = minus(obj2,obj1);
            % xBase - vec of same size 
            elseif isa(obj1,'xBase') && (size(obj2,1)==size(obj1.data,1)) && ...
                    (size(obj2,2)==size(obj1.data,2)) && isfloat(obj2) && isreal(obj2)
                obj1 = obj1.setPixel(obj1.getPixel - obj2);
            else
                error('xBase.minus: Can only add two jBase Objects or scalars or 1*3 or same size')
            end
        end
            
        %% .*
        function obj1 = times(obj1,obj2)
            % xBase .* xBase
            if isa(obj1,'xBase') && isa(obj2,'xBase')
                if obj1.numElements == obj2.numElements
                    obj1.data = obj1.data .* obj2.data;
                else
                    error('xBase.times: Can''t multiply - Image size different');
                end
            % xBase .* scalar 
            elseif isa(obj1,'xBase') && isscalar(obj2) && isreal(obj2) && isfloat(obj2)
                obj1.data = obj1.data .* repmat(obj2,size(obj1.data));
            elseif isa(obj2,'xBase') && isscalar(obj1) && isreal(obj1) && isfloat(obj1)
                obj1 = times(obj2,obj1);
            % xBase .* [1 2 3]
            elseif isa(obj1,'xBase') && (size(obj2,1)==1) && (size(obj2,2)==3) && isreal(obj2) && isfloat(obj2)
                obj1.data = obj1.data .* repmat(obj2,[size(obj1.data,1),1]);
            elseif isa(obj2,'xBase') && (size(obj1,1)==1) && (size(obj1,2)==3) && isreal(obj1) && isfloat(obj1)
                obj1 = times(obj2,obj1);
            % xBase .* [1 2 3 ... numElements]' 
            elseif isa(obj1,'xBase')
                if (size(obj2,1)==size(obj1.data,1)) && (size(obj2,2)==1) && isreal(obj2) && isfloat(obj2)
                    obj1 = obj1.setPixel(obj1.getPixel .* repmat(obj2,[1,3]));
                else
                    error('xBase.times: Can only multiply two xImages or scalars or 1*3 or numElements*1')
                end
            elseif isa(obj2,'xBase')
                if (size(obj1,1)==size(obj2.data,1)) && (size(obj1,2)==1) && isreal(obj1) && isfloat(obj1)
                    obj1 = times(obj2,obj1);
                else
                    error('xBase.times: Can only multiply two xImages or scalars or 1*3 or numElements*1')
                end
            % xBase .* vec of same size 
            elseif isa(obj1,'xBase') && isfloat(obj2) && isreal(obj2) && ...
                    (size(obj2,1)==size(obj1.data,1)) && (size(obj2,2)==size(obj1.data,2))
                obj1.data = obj1.data .* obj2;
            else
                error('xBase.times: Can only multiply two xImages or scalars or 1*3 or numElements*1')
            end
        end
        %% .^
        function obj1 = power(obj1,obj2)
            if isa(obj1,'xBase') && isa(obj2,'xBase')
                if obj1.numElements == obj2.numElements
                    obj1 = obj1.setPixel(obj1.getPixel.^obj2.getPixel);
                else
                    error('xBase.power: Can''t pow - Image size different');
                end
            elseif isa(obj1,'xBase') && isscalar(obj2) && isfloat(obj2) && isreal(obj2)
                obj1 = obj1.setPixel(obj1.getPixel.^repmat(obj2,[obj1.numElements,3]));
            elseif isscalar(obj1) && isfloat(obj1) && isreal(obj1) && isa(obj2,'xBase')
                obj1 = obj2.setPixel(repmat(obj1,[obj2.numElements,3]).^obj2.getPixel);
            else
                error('xBase.power: Can only pow two xImages or scalars')
            end
        end
        
        %% * (matrix multiplication)
        function obj = mtimes(obj, matrix)
            obj.data = (matrix*obj.data')';
        end
        %% \ (matrix division)
        function obj = mldivide(obj, matrix)
            obj.data = (matrix\obj.data')';
        end
        %% ./
        function obj1 = rdivide(obj1,obj2)
            if isa(obj1,'xBase') && isa(obj2,'xBase')
                if obj1.numElements == obj2.numElements
                    obj1 = obj1.setPixel(obj1.getPixel ./ obj2.getPixel);
                else
                    error('xBase.times: Can''t multiply - Image size different');
                end
            elseif isa(obj1,'xBase') && isscalar(obj2) && isfloat(obj2) && isreal(obj2)
                obj1 = obj1.setPixel(obj1.getPixel ./ repmat(obj2,[obj1.numElements,3]));
            elseif isa(obj2,'xBase') && isscalar(obj1) && isfloat(obj1) && isreal(obj1)
                obj1 = rdivide(obj2,obj1);
            elseif isa(obj1,'xBase') && (size(obj2,1)==1) && (size(obj2,2)==3) && isfloat(obj2) && isreal(obj2)
                obj1 = obj1.setPixel(obj1.getPixel ./ repmat(obj2,[obj1.numElements,1]));
            elseif isa(obj2,'xBase') && (size(obj1,1)==1) && (size(obj1,2)==3) && isfloat(obj1) && isreal(obj1)
                obj1 = rdivide(obj2,obj1);
            else
                error('xBase.times: Can only divide two xImages or scalars or 1*3')
            end
        end
        
        %% Apply function to .data
        function obj = fun(obj,func_handle)
            obj.data = func_handle(obj.data);
            warning('This function will be removed in Future!')
        end        
        %% Clear data
        function obj = clearData(obj)
            obj.data = [];
        end
        %% clamp
        function obj = clamp(obj, lowerClip, upperClip)
            if isscalar(lowerClip) && isscalar(upperClip)
                obj.data(obj.data>upperClip)=upperClip;
                obj.data(obj.data<lowerClip)=lowerClip;
            elseif size(lowerClip,1)==1 && size(upperClip,1)==1 && size(lowerClip,2)==3 && size(upperClip,2)==3 
                obj.data(cat(2,obj.data(:,1)>upperClip(1),zeros(size(obj.data,1),2)))=upperClip(1);
                obj.data(cat(2,obj.data(:,1)<lowerClip(1),zeros(size(obj.data,1),2)))=lowerClip(1);
                obj.data(cat(2,zeros(size(obj.data,1),1),obj.data(:,2)>upperClip(2),zeros(size(obj.data,1),1)))=upperClip(2);
                obj.data(cat(2,zeros(size(obj.data,1),1),obj.data(:,2)<lowerClip(2),zeros(size(obj.data,1),1)))=lowerClip(2);
                obj.data(cat(2,zeros(size(obj.data,1),2),obj.data(:,3)>upperClip(3)))=upperClip(3);
                obj.data(cat(2,zeros(size(obj.data,1),2),obj.data(:,3)<lowerClip(3)))=lowerClip(3);
            else
                error(['Input vector size: ' num2str(size(lowerClip)) ' and ' ...
                    num2str(size(upperClip)) ' not yet supported. Try scalar values or 1*3 vectors.']);
            end
        end
        %% clip NaN
        function obj = clipNaN(obj, value)
                obj.data(isnan(obj.data))=value;
        end
        %% clip to Value
        function obj = clipToValue(obj, lowerClip, upperClip, lowerTargetValue, upperTargetValue)
                obj.data( obj.data > upperClip ) = upperTargetValue;
                obj.data( obj.data < lowerClip ) = lowerTargetValue;
        end
        %% abs
        function obj = abs( obj )
                obj.data = abs( obj.data );
        end
      
      %% --------------------------------------------------------------------------------------------------------------------
      
      
      
      
      
      
      
    end
    
    %% useful static methods
    methods(Static)
    
        %% ---TODO---
        %  implement base path, test img path, ...
        
        
        
        
        %% Get Plot Envrionment
        function plotEngine = get3DPlotEngine()
            plotEngine = 'hg2';
        end
       
    end
end

