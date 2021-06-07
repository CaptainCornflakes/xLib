
% reads dpx file
function [img, metaData] = dpxRead( filename )

    % open file
    fp = fopen( filename );
    if (fp == -1)
       error('File could not be opened.');
    end  
    
    % Get byte order 0 = forward, 1 = reverse
    order = getOrder(fp);
    if (order == -1)
        error('Incorrect syntax. File could not be read.');
    end
    
    % Field 4 Data Offset    
    metaData.dataOffset = getInfo(fp, 4, 4, 'U32', order);
    %fprintf('Offset: %u\n', dataOffset);
    
    % Field 3 Version Number
    metaData.version = getInfo(fp, 8, 8, 'ASCII', order);
    %fprintf('Version: %s\n', version);
    
    % Field 4 Total Image Size
    metaData.fileSize = getInfo(fp, 16, 4, 'U32', order);
    %fprintf('Image Size (bytes): %u\n', fileSize);
    
    % Field 5 Ditto Key
    metaData.dittoKey = getInfo(fp, 20, 4, 'U32', order);
    %fprintf('Ditto Key: %u\n', dittoKey);
    
    % Field 6 Generic Section Header Length (bytes)
    metaData.genericHeaderLen = getInfo(fp, 24, 4, 'U32', order);
    %fprintf('Generic Section Header Length (bytes): %u\n', genericHeaderLen);
    
    % Field 7 Industry Specific Header Length (bytes)
    metaData.industryHeaderLen = getInfo(fp, 28, 4, 'U32', order);
    %fprintf('Industry Specific Header Length (bytes): %u\n', industryHeaderLen);
    
    % Field 8 User Defined Header Length (bytes)
    metaData.userHeaderLen = getInfo(fp, 32, 4, 'U32', order);
    %fprintf('User Defined Header Length (bytes): %u\n', userHeaderLen);
    
    % Field 9 Image Filename
    metaData.imageFilename = getInfo(fp, 36, 100, 'ASCII', order);
    %fprintf('Image Filename: %s\n', imageFilename);
    
    % Field 10 Creation date/time
    metaData.creationTime = getInfo(fp, 136, 24, 'ASCII', order);
    %fprintf('Creation Time: %s\n', creationTime);
    
    % Field 12 Creator
    metaData.creator = getInfo(fp, 160, 100, 'ASCII', order);
    %fprintf('Creator: %s\n', creator);
    
    % Field 13 Project Name
    metaData.projectName = getInfo(fp, 260, 200, 'ASCII', order);
    %fprintf('Project Name: %s\n', projectName);
    
    % Field 14 Right to Use Copyright Statement
    metaData.copywriteStatement = getInfo(fp, 460, 200, 'ASCII', order);
    %fprintf('Right to Use Copyright Statement: %s\n', copywriteStatement);
    
    % Field 15
    metaData.encryptionKey = getInfo(fp, 660, 4, 'U32', order);
    %fprintf('Encryption Key: %x\n', encryptionKey);
    
    % Image Information Header
    
    % Field 17 Image Orientation
    metaData.orientation = getInfo(fp, 768, 2, 'U16', order);
    %fprintf('Image Orientation: %u\n', orientation);
    
    % Field 18 Number of Image Elements (1 - 8)
    metaData.numElements = getInfo(fp, 770, 2, 'U16', order);
    %fprintf('Number of Image Elements: %u\n', numElements);
    
    % Field 19 Number of Pixels per Line
    metaData.pixelsPerLine = getInfo(fp, 772, 4, 'U32', order);
    %fprintf('Pixels per Line: %u\n', pixelsPerLine);

    % Field 20 Lines per Image Element
    metaData.linesPerElement = getInfo(fp, 776, 4, 'U32', order);
    %fprintf('Lines per Image Element: %u\n', linesPerElement);
    
    % Field 21 Data Structure for Image Element

    metaData.dataSign = zeros(1, 8);
    metaData.lowData = zeros(1, 8);
    metaData.lowQuantity = zeros(1, 8);
    metaData.highData = zeros(1, 8);
    metaData.highQuantity = zeros(1, 8);
    metaData.descriptor = zeros(1, 8);
    metaData.transferChar = zeros(1, 8);
    metaData.colorSpec = zeros(1, 8);
    metaData.bitDepth = zeros(1, 8);
    metaData.packing = zeros(1, 8);
    metaData.encoding = zeros(1, 8);
    metaData.offsetToData = zeros(1, 8);
    metaData.linePadding = zeros(1, 8);
    metaData.imagePadding = zeros(1, 8);
    metaData.descImageElement = [];
    
    for i=1:metaData.numElements

        % need offset as if we have multiple elements
        elementOffset = 72*(i - 1);
        
        % Field 21.1 Data Sign
        metaData.dataSign(i) = getInfo(fp, 780 + elementOffset, 4, 'U32', order);
        %fprintf('Data Sign %d: %u\n', i, dataSign(i));

        % Field 21.2 Reference Low Data Code Value
        metaData.lowData(i) = getInfo(fp, 784 + elementOffset, 4, 'U32', order);
        %fprintf('Reference Low Data Code Value %d: %u\n', i, lowData(i));

        % Field 21.3 Reference Low Quantity Represented
        metaData.lowQuantity(i) = getInfo(fp, 788 + elementOffset, 4, 'U32', order);
        %fprintf('Reference Low Quantity Represented %d: %u\n', i, lowQuantity(i));

        % Field 21.4 Reference High Data Code Value
        metaData.highData(i) = getInfo(fp, 792 + elementOffset, 4, 'U32', order);
        %fprintf('Reference High Data Code Value %d: %u\n', i, highData(i));

        % Field 21.5 Reference Low Quantity Represented
        metaData.highQuantity(i) = getInfo(fp, 796 + elementOffset, 4, 'U32', order);
        %fprintf('Reference High Quantity Represented %d: %u\n', i, highQuantity(i));

        % Field 21.6 Descriptor
        metaData.descriptor(i) = getInfo(fp, 800 + elementOffset, 1, 'U8', order);
        %fprintf('Descriptor %d: %u\n', i, descriptor(i));

        % Field 21.7 Transfer Characteristics
        metaData.transferChar(i) = getInfo(fp, 801 + elementOffset, 1, 'U8', order);
        %fprintf('Transfer Characteristics %d: %u\n', i, transferChar(i));

        % Field 21.8 Colorimetric Specification
        metaData.colorSpec(i) = getInfo(fp, 802 + elementOffset, 1, 'U8', order);
        %fprintf('Transfer Characteristics %d: %u\n', i, colorSpec(i));

        % Field 21.9 Bit Depth
        metaData.bitDepth(i) = getInfo(fp, 803 + elementOffset, 1, 'U8', order);
        %fprintf('Bit Depth %d: %u\n', i, bitDepth(i));

        % Field 21.10 Packing
        metaData.packing(i) = getInfo(fp, 804 + elementOffset, 2, 'U16', order);
        %fprintf('Packing %d: %u\n', i, packing(i));

        % Field 21.11 Encoding
        metaData.encoding(i) = getInfo(fp, 806 + elementOffset, 2, 'U16', order);
        %fprintf('Encoding %d: %u\n', i, encoding(i));

        % Field 21.12 Offset to Data
        metaData.offsetToData(i) = getInfo(fp, 808 + elementOffset, 4, 'U32', order);
        %fprintf('Offset to Data %d: %u\n', i, offsetToData(i));

        % Field 21.13 End of Line Padding
        metaData.linePadding(i) = getInfo(fp, 812 + elementOffset, 4, 'U32', order);
        %fprintf('End-of-line padding %d: %u\n', i, linePadding(i));

        % Field 21.14 End of Image Padding
        metaData.imagePadding(i) = getInfo(fp, 816 + elementOffset, 4, 'U32', order);
        %fprintf('End-of-image padding %d: %u\n', i, imagePadding(i));

        % Field 21.15 Description of image element
        metaData.descImageElement = [ metaData.descImageElement, getInfo(fp, 820 + elementOffset, 32, 'ASCII', order) ];
        %fprintf('Description of image element %d: %s\n', i, descImageElement(i));
        
    end

    
    % Image information header 
    
    % Field 30 X Offset
    metaData.xOffset = getInfo(fp, 1408, 4, 'U32', order);
    %fprintf('X Offset: %u\n', xOffset);
    
    % Field 31 Y Offset
    metaData.yOffset = getInfo(fp, 1412, 4, 'U32', order);
    %fprintf('Y Offset: %u\n', yOffset);
    
    % Field 32 X Center
    metaData.xCenter = getInfo(fp, 1416, 4, 'R32', order);
    %fprintf('X Center: %d\n', xCenter);
    
    % Field 33 Y Center
    metaData.yCenter = getInfo(fp, 1420, 4, 'R32', order);
    %fprintf('Y Center: %d\n', yCenter);
    
    % Field 34 X Original Size
    metaData.xOrigSize = getInfo(fp, 1424, 4, 'U32', order);
    %fprintf('X Original Size: %u\n', xOrigSize);
    
    % Field 35 Y Original Size
    metaData.yOrigSize = getInfo(fp, 1428, 4, 'U32', order);
    %fprintf('Y Original Size: %u\n', yOrigSize);
    
    % Field 36 Source Image Filename
    metaData.srcImageFilename = getInfo(fp, 1432, 100, 'ASCII', order);
    %fprintf('Source Image Filename: %s\n', srcImageFilename);
    
    % Field 37 Source Image Date
    metaData.srcImageDate = getInfo(fp, 1532, 24, 'ASCII', order);
    %fprintf('Source Image Date: %s\n', srcImageDate);
    
    % Field 38 Input Device Name
    metaData.inputDevice = getInfo(fp, 1556, 32, 'ASCII', order);
    %fprintf('Input Device Name: %s\n', inputDevice);
    
    % Field 39 Input Device Serial Number
    metaData.inputDeviceSerial = getInfo(fp, 1588, 32, 'ASCII', order);
    %fprintf('Input Device Serial Number: %s\n', inputDeviceSerial);
    
    % Field 40 Border Validity
    metaData.borderValidity = getInfo(fp, 1620, 8, 'U16', order);
    %fprintf('Border Validity XL: %u XR: %u YT: %u YB: %u\n', borderValidity(1), borderValidity(2), borderValidity(3), borderValidity(4));
    
    % Field 41 Pixel Aspect Ratio
    metaData.pixelAspectRatio = getInfo(fp, 1628, 8, 'U32', order);
    %fprintf('Pixel Aspect Ratio Horizontal: %u Vertical: %u\n ', pixelAspectRatio(1), pixelAspectRatio(2));
    
    % Field 42 Data structure for additional source image information
    
    % Field 42.1 X Scanned Size
    metaData.xScannedSize = getInfo(fp, 1636, 4, 'R32', order);
    %fprintf('X Scanned Size: %d\n', xScannedSize);
    
    % Field 42.2 Y Scanned Size
    metaData.yScannedSize = getInfo(fp, 1640, 4, 'R32', order);
    %fprintf('Y Scanned Size: %d\n', yScannedSize);
    
    % Motion-picture Film Information Header
    
    % Field 43 Film mfg. ID Code
    metaData.filmmfg = getInfo(fp, 1664, 2, 'ASCII', order);
    %fprintf('Film mfg. ID Code: %s\n', filmmfg);
    
    % Field 44 Film Type
    metaData.filmType = getInfo(fp, 1666, 2, 'ASCII', order);
    %fprintf('Film Type: %s\n', filmType);
    
    % Field 45 Offset in Perfs
    metaData.offsetPerfs = getInfo(fp, 1668, 2, 'ASCII', order);
    %fprintf('Offset in Perfs: %s\n', offsetPerfs);
    
    % Field 47 Prefix
    metaData.prefix = getInfo(fp, 1670, 6, 'ASCII', order);
    %fprintf('Prefix: %s\n', prefix);
    
    % Field 48 Count
    metaData.count = getInfo(fp, 1676, 4, 'ASCII', order);
    %fprintf('Count: %s\n', count);
    
    % Field 49 Format
    metaData.format = getInfo(fp, 1680, 32, 'ASCII', order);
    %fprintf('Format: %s\n', format);
    
    % Field 50 Frame Position in Sequence
    metaData.framePosSeq = getInfo(fp, 1712, 4, 'U32', order);
    %fprintf('Frame Position in Sequence: %u\n', framePosSeq);
    
    % Field 51 Sequence Length (frames)
    metaData.seqLength = getInfo(fp, 1716, 4, 'U32', order);
    %fprintf('Sequence Length (frames): %u\n', seqLength);
    
    % Field 52 Held Count
    metaData.heldCount = getInfo(fp, 1720, 4, 'U32', order);
    %fprintf('Held Count: %u\n', heldCount);
    
    % Field 53 Frame Rate of Original (fps)
    metaData.fpsOriginal = getInfo(fp, 1724, 4, 'R32', order);
    %fprintf('Frame Rate of Original (fps): %d\n', fpsOriginal);
    
    % Field 54 Shuttle Angle (degrees)
    metaData.shuttleAngle = getInfo(fp, 1728, 4, 'R32', order);
    %fprintf('Shuttle Angle (degrees): %d\n', shuttleAngle);
    
    % Field 55 Frame Identification
    metaData.frameID = getInfo(fp, 1732, 32, 'ASCII', order);
    %fprintf('Frame Identification: %s\n', frameID);
    
    % Field 56 Slate Information
    metaData.slateInfo = getInfo(fp, 1764, 100, 'ASCII', order);
    %fprintf('Slate Information: %s\n', slateInfo);
    
    % Television Information Header
    
    % Field 58 SMPTE Time Code
    metaData.SMPTETimeCode = getInfo(fp, 1920, 4, 'U32', order);
    %fprintf('SMPTE Time Code: %u\n', SMPTETimeCode);
    
    % Field 59 SMPTE User Bits
    metaData.SMPTEUserBits = getInfo(fp, 1924, 4, 'U32', order);
    %fprintf('SMPTE User Bits: %u\n', SMPTEUserBits);
    
    % Field 60 Interlace
    metaData.interlace = getInfo(fp, 1928, 1, 'U8', order);
    %fprintf('Interlace: %u\n', interlace);
    
    % Field 61 Field Number
    metaData.fieldNum = getInfo(fp, 1929, 1, 'U8', order);
    %fprintf('Field Number: %u\n', fieldNum);
    
    % Field 62 Video Signal Standard
    metaData.vidSigStnd = getInfo(fp, 1930, 1, 'U8', order);
    %fprintf('Video Signal Standard: %u\n', vidSigStnd);
    
    % Field 63 Byte Alignment
    metaData.zero = getInfo(fp, 1931, 1, 'U8', order);
    %fprintf('Byte Alignment: %u\n', zero);
    
    % Field 64 Horizontal Sampling Rate (Hz)
    metaData.horzSampleRate = getInfo(fp, 1932, 4, 'R32', order);
    %fprintf('Horizontal Sampling Rate (Hz): %d\n', horzSampleRate);
    
    % Field 65 Verticle Sampling Rate (Hz)
    metaData.vertSampleRate = getInfo(fp, 1936, 4, 'R32', order);
    %fprintf('Verticle Sampling Rate (Hz): %d\n', vertSampleRate);
    
    % Field 66 Temporal Sampling Rate (Hz)
    metaData.tempSampleRate = getInfo(fp, 1940, 4, 'R32', order);
    %fprintf('Temporal Sampling Rate (Hz): %d\n', tempSampleRate);
    
    % Field 67 Time Offset from Sync to First Pixel (ms)
    metaData.timeOffsetSync = getInfo(fp, 1944, 4, 'R32', order);
    %fprintf('Time Offset from Sync to First Pixel (ms): %d\n', timeOffsetSync);
    
    % Field 68 Gamma
    metaData.gamma = getInfo(fp, 1948, 4, 'R32', order);
    %fprintf('Gamma: %d\n', gamma);
    
    % Field 69 Black Level
    metaData.blackLevel = getInfo(fp, 1952, 4, 'R32', order);
    %fprintf('Black Level: %d\n', blackLevel);
    
    % Field 70 Black Gain
    metaData.blackGain = getInfo(fp, 1956, 4, 'R32', order);
    %fprintf('Black Gain: %d\n', blackGain);
    
    % Field 71 Breakpoint
    metaData.breakpoint = getInfo(fp, 1960, 4, 'R32', order);
    %fprintf('Breakpoint: %d\n', breakpoint);
    
    % Field 72 White Level
    metaData.whiteLevel = getInfo(fp, 1964, 4, 'R32', order);
    %fprintf('White Level: %d\n', whiteLevel);
    
    % Field 73 Integration Time
    metaData.integTime = getInfo(fp, 1968, 4, 'R32', order);
    %fprintf('Integration Time: %d\n', integTime);
    
    
    
    
    % Field 77 Image data
      
    frewind(fp);
    headerData = fread(fp, metaData.dataOffset/4, 'uint32', 0, 'b');

    imageData = getImageData(fp, metaData.dataOffset, metaData.bitDepth(1), ...
        metaData.pixelsPerLine, metaData.linesPerElement, metaData.packing(1), metaData.descriptor(i));
    
    img = imageData;
    metaData.rawHeaderData = headerData;
    
    %% Normalize
    img = double(img) ./ (2.^metaData.bitDepth(1)-1);
    
    %% Check Orientation
    if size(img,1) == metaData.linesPerElement
        % do nothing
    elseif size(img,2) == metaData.linesPerElement
        img = cat( 3, img(:,:,1)', img(:,:,2)', img(:,:,3)' );
    else
        error('Wrong image size')
    end
    
    if not( size(img,1) == metaData.linesPerElement )
        error('Wrong image height')
    end
    
    if not( size(img,2) ==  metaData.pixelsPerLine )
        error('Wrong image width')
    end
    %% Swap RGB Channels because default Color Order is BGR
    img = cat( 3, img(:,:,3), img(:,:,2), img(:,:,1) );
    
    %% Check if ImagMagic RGB (Hacky!!!)
    metaData.creator
    if ~isempty( strfind(metaData.creator,'Magick') )
        disp('Image Magick DPX detected')
         img = cat( 3, img(:,:,3), img(:,:,2), img(:,:,1) );
    end
 
% get the image data    
function data = getImageData(fp, offset, depth, xRes, yRes, packing, descriptor)

    depthType = getDepthType( depth );            
    fseek(fp, offset, 'bof');
    compLen = getCompLen(descriptor);
    numElements = xRes*yRes*compLen;
    dataItr = 1;
    
    
    if (depth == 10 || depth == 12)
        
        % datum is sequential 
        if (packing == 0)

            lnBitLen = xRes*compLen*depth;
            pad = 32 - mod(lnBitLen, 32);
            buffer = zeros(1, numElements);
            
            for i = 1:yRes
                buffer(dataItr:(dataItr + xRes - 1)) = fread(fp, xRes, depthType);
                fread(fp, pad, 'ubit1');
                dataItr = dataItr + xRes;
            end  
            
            R = buffer(1:3:end);
            G = buffer(2:3:end);
            B = buffer(3:3:end);
            
            redChan = reshape(R, xRes, yRes);
            greenChan = reshape(G, xRes, yRes);
            blueChan = reshape(B, xRes, yRes);
            
            data = cat(3, redChan, greenChan, blueChan);

        % packing type 1
        elseif (packing == 1)
            
            % Read 10 bit files with packing type 1
            if (depth == 10)
                
                buffer = fread(fp, xRes*yRes, 'uint32', 0, 'b');
                
                c1 = bitshift(buffer, -2);
                c2 = bitshift(buffer, -12);
                c3 = bitshift(buffer, -22);
                
                R = bitand(c1, 1023);
                G = bitand(c2, 1023);
                B = bitand(c3, 1023);
                
                redChan = reshape(R, xRes, yRes);
                greenChan = reshape(G, xRes, yRes);
                blueChan = reshape(B, xRes, yRes);
                
                data = cat(3, redChan, greenChan, blueChan);
                
            % 12 bit files with packing type 1
            else
                
                buffLen = floor(double(numElements)/2.0);

                if (mod(numElements, 2) ~= 0)
                    buffLen = buffLen + 1;
                end
                
                if (mod(numElements, 2) ~= 0)
                    buffLen = buffLen + 1;
                end
                
                buffer = fread(fp, buffLen, 'uint32', 0, 'b');
                
                c1 = bitshift(buffer, -4);
                c2 = bitshift(buffer, -20);
                
                c1 = bitand(c1, 4095);
                c2 = bitand(c2, 4095);
                
                arr = zeros(1, 3*xRes*yRes);
                arr(1:2:end) = c1;
                arr(2:2:end) = c2;
                
                R = arr(1:3:end);
                G = arr(2:3:end);
                B = arr(3:3:end);
                
                redChan = reshape(R, xRes, yRes);
                greenChan = reshape(G, xRes, yRes);
                blueChan = reshape(B, xRes, yRes);
                
                data = cat(3, redChan, greenChan, blueChan);
                
            end
                
        else
            error('Cannot handle packing format.');
        end
    else
            buffer = uint64(fread(fp, numElements, depthType, 0, 'b'));
            R = buffer(1:3:end);
            G = buffer(2:3:end);
            B = buffer(3:3:end);
            
            redChan = reshape(R, xRes, yRes);
            greenChan = reshape(G, xRes, yRes);
            blueChan = reshape(B, xRes, yRes);
            
            data = cat(3, redChan, greenChan, blueChan);
       
    end   
    
    fclose(fp);

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
            error('Depth not valid');
    end
    
% gets the length of a component
% as of now only hold RGB
function compLen = getCompLen(desc)
    switch desc
        case 50
            compLen = 3;

        otherwise
            error('Cannot handle descriptor type.');
    end    
    
% seeks to a position from the beginning of the file
function seek(fp, pos)
    status = fseek(fp, pos, 'bof');
    if (status ~= 0)
        error('Error seeking file.');
    end

%returns the byte order. 0 = forward, 1 = reverse, -1 = wrong syntax
function order = getOrder(fp)
    seek(fp, 0);
    magicNum = fread(fp, 4, '*char');
    
    byteFor = ['S', 'D', 'P', 'X']';
    byteRev = ['X', 'P', 'D', 'S']';

    if isequal(magicNum, byteFor)
        order = 0;
    elseif isequal(magicNum, byteRev)
        order = 1;
    else
        order = -1;
    end
    
% gets file information
function value = getInfo(fp, offset, length, type, order)
    seek(fp, offset);
    
    if (strcmp(type,'U8'))
        count = length;
        if (order)
            value = uint8(fread(fp, count, 'uint8', 0, 'l'));
        else
            value = uint8(fread(fp, count, 'uint8', 0, 'b'));
        end
        
    elseif (strcmp(type,'U16'))
        count = length/2;
        if (order)
            value = uint16(fread(fp, count, 'uint16', 0, 'l'));
        else
            value = uint16(fread(fp, count, 'uint16', 0, 'b'));
        end
        
    elseif (strcmp(type,'U32'))
        count = length/4;
        if (order)
            value = uint32(fread(fp, count, 'uint32', 0 ,'l'));
        else
            value = uint32(fread(fp, count, 'uint32', 0, 'b'));
        end
        
    elseif (strcmp(type,'R32'))
        count = length/4;
        if (order)
            value = int32(fread(fp, count, 'int32', 0, 'l'));
        else
            value = int32(fread(fp, count, 'int32', 0, 'b'));
        end
        
    elseif (strcmp(type,'ASCII'))
        count = length;
        if (order)
            value = fliplr(char(fread(fp, count, '*char')'));
        else
            value = char(fread(fp, count, '*char')');
        end
     
    else
        error('Not a known type');
    end

    
    


