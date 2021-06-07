% writes dpx file
function dpxWrite(filename, data)

    if (exist(filename, 'file') == 2)
        overwrite = input('File exists. Would you like to overwrite it? (1 = Yes): ');
        
        if (overwrite ~= 1)
            return;
        end
    end

    fp = fopen(filename, 'w');
    
    if (fp == -1)
       error('File could not be opened. Exiting.');
    end
    
    header = data{1};
    imageData = data{2};
    
    offset = uint32(header(2));
    depth = bitand(header(201), 255);
    xRes = uint32(header(194));
    yRes = uint32(header(195));
    packing = bitand(bitshift(header(202), -16), 65535);
    descriptor = bitand(bitshift(header(201), -24), 255);
    
    
    
    writeHeader(fp, header);
    writeImageData(fp, imageData, offset, depth, xRes, yRes, packing, descriptor);
    fclose(fp);
    
% write header
function writeHeader(fp, header)
    for i = 1:length(header)
        fwrite(fp, header(i), 'uint32', 0, 'b');
    end

    
% write the image data    
function writeImageData(fp, data, offset, depth, xRes, yRes, packing, descriptor)

    depthType = getDepthType(depth);            
    fseek(fp, offset, 'bof');
    compLen = getCompLen(descriptor);
    numElements = xRes*yRes*compLen;
    
    
    if (depth == 10 || depth == 12)
        
        % datum is sequential 
        if (packing == 0)
            lnBitLen = xRes*compLen*depth;
            pad = 32 - mod(lnBitLen, 32);
            dataItr = 1;
            
            for i = 1:yRes
                
                % write sequential data followed
                for j = 1:xRes
                    fwrite(fp, data(dataItr), depthType, 0, 'b');
                    dataItr = dataItr + 1;
                end
                
                % write padding
                for j = 1:pad
                    fwrite(fp, 0, 'ubit1', 0, 'b');
                end
            end
        
        % Packing type 1
        elseif (packing == 1)
   
            buffer = createBufferPacking(data, depth, numElements, xRes, yRes);
            fwrite(fp, buffer, 'uint32', 0, 'b');
            
        else
            error('Cannot handle this type of packing');
        end
    else
        
        buffer = zeros(1, numElements);
        
        R = reshape(data(:,:,1), 1, xRes*yRes);
        G = reshape(data(:,:,2), 1, xRes*yRes);
        B = reshape(data(:,:,3), 1, xRes*yRes);
        
        buffer(1:3:end) = R;
        buffer(2:3:end) = G;
        buffer(3:3:end) = B;
        
        fwrite(fp, buffer, depthType, 0, 'b');
        
    end
    
    
function outBuffer = createBufferPacking(data, depth, numElements, xRes, yRes)
        
    % numbers left to fill in word
    if (depth == 10)
        addToEnd = mod(numElements, 3);
        buffLen = floor(numElements/3);
    else
        addToEnd = mod(numElements, 2);
        buffLen = floor(numElements/2);
    end
            
    if (addToEnd ~= 0)
        buffLen = buffLen + 1;
    end
    
    outBuffer = zeros(1, buffLen);
    
    if (depth == 10)
        
        c1 = reshape(data(:,:,1), 1, xRes*yRes);
        c2 = reshape(data(:,:,2), 1, xRes*yRes);
        c3 = reshape(data(:,:,3), 1, xRes*yRes);
        
        R = bitshift(c1, 2);
        G = bitshift(c2, 12);
        B = bitshift(c3, 22);
        
        outBuffer = bitor(outBuffer, R);
        outBuffer = bitor(outBuffer, G);
        outBuffer = bitor(outBuffer, B);       
    
    else
        
        R = reshape(data(:,:,1), 1, xRes*yRes);
        G = reshape(data(:,:,2), 1, xRes*yRes);
        B = reshape(data(:,:,3), 1, xRes*yRes);
        
        arr = zeros(1, xRes*yRes*3);
        arr(1:3:end) = R;
        arr(2:3:end) = G;
        arr(3:3:end) = B;
        
        c1 = arr(1:2:end);
        c2 = arr(2:2:end);
        
        c1 = bitshift(c1, 4);
        c2 = bitshift(c2, 20);
        
        outBuffer = bitor(outBuffer, c1);
        outBuffer = bitor(outBuffer, c2);
        
    end

% get string for bit depth
function depthType = getDepthType(depth)
    switch depth
        case 1
            depthType = 'ubit1';
        case 8
            depthType = 'ubit8';
        case 10
            depthType = 'ubit10';
        case 12
            depthType = 'ubit12';
        case 16
            depthType = 'ubit16';
        case 32
            depthType = 'ubit32';
        case 64
            depthType = 'ubit64';
        otherwise
            disp('Depth not valid');
            depthType = 'ubit32'
    end
    
function compLen = getCompLen(desc)
    switch desc
        case 50
            compLen = 3;

        otherwise
            error('Cannot handle descriptor type.');
    end