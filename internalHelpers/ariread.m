function arirgb = ariread(Path, Kelvin,ISO)
%% Read Arriraw from Alexa

warning('Kelvin currently set to 3200, ISO set to 800. ToDo: Read Metadata (As described in SMPTE RDD 30:2014)')
Kelvin = 3200;
ISO = 800;
%% End Debug

    %%
    disp(['Processing: ' Path]);
    
    fid = fopen(Path);
    fseek(fid, 4096, 'bof');
    ari8 = fread(fid,'*uint8','b');
    fclose(fid);
    
    %% Copy full Bytes from .ari file:
    ari12a = uint16(ari8(repmat([2 4 7 1 12 6 9 11],1,2880*1620/8)+floor(0:1/8:(2880*1620/8-1/8))*12));
    
    %% shift lsbs to msbs at positions 2, 4, 6, 8
    ari12a(2:2:2880*1620) = bitshift(ari12a(2:2:2880*1620),4);
    
    %% Copy half Bytes
    ari12b = uint16(ari8(repmat([3 3 8 8 5 5 10 10],1,2880*1620/8)+floor(0:1/8:(2880*1620/8-1/8))*12));
    
    %% remove bits not used by bitshift
    ari12b(1:2:2880*1620) = bitshift(ari12b(1:2:2880*1620),12);
    ari12b(2:2:2880*1620) = bitshift(ari12b(2:2:2880*1620),-4);
    
    %% bring bits to correct position
    ari12b(1:2:2880*1620) = bitshift(ari12b(1:2:2880*1620),-4);
    
    %% Combine and make 2D image from pixelline
    ari12 = reshape((ari12a + ari12b),2880,1620)';
   
    %% Convert back to linear sensor value
    %ari12 = double(ari12);
    ari16 = ari12;
    ari16(ari12 >= 1024) = bitshift(1024 + 2 .* mod(ari12(ari12 >= 1024),512)+1, ...
        idivide(ari12(ari12 >= 1024), uint16(512))-2) - 1;
    
    %% Apply multipliers
    arifloat = double(ari16);
    switch Kelvin
        case 3200
            R = 1.128195;
            B = 2.068762;
        case 5600
            R = 1.644962;
            B = 1.366723;
        case 6500
            R = 1.745829;
            B = 1.252820;
        otherwise
            error('Currently ariread.m can only read ari with 3200,5600 or 6500 Kelvin')
    end
    % Red
    arifloat(1:2:end,2:2:end) = (arifloat(1:2:end,2:2:end)-256).*R + 256;
    % Blue
    arifloat(2:2:end,1:2:end) = (arifloat(2:2:end,1:2:end)-256).*B + 256;


    % Measure time for raw debayering
    tic;

    %% uncomment the debayering algorithm you want to use
    
    %arirgb = simple_half_bayer(arifloat);
    %arirgb = bilinear_interpolation_debayer(arifloat);
    arirgb = hqlin_debayer(arifloat);
    
    % /Measure time for raw debayering
    toc;
    
    %% Convert to Alexa WG and do CCT compensation as described in SMPTE RDD 30 in future?
    %
    %
    %
    %
    
    %% Substract Black Level and do exposure compensation
    arirgb = (arirgb-256)./65535.*0.18.*ISO./4;

%%

disp('Finished reading ArriRAW');

end



% simple raw debayering by just 
function rgbfloat = simple_half_bayer(arifloat)
    rgbfloat(:,:,1) = arifloat(1:2:end,2:2:end);
    rgbfloat(:,:,2) = (arifloat(1:2:end,1:2:end) + arifloat(2:2:end,2:2:end)) ./2;
    rgbfloat(:,:,3) = arifloat(2:2:end,1:2:end);
end

% The following algorithmus implemented with help of the Book "Computergrafik und
% Bildverarbeitung, Band II: Bildverarbeitung". 3. Auflage, 2011
% by Alfred Nischwitz,Max Fischer, Peter Haber?cker, Gudrun Socher

% bilinear interpolation with cutting of the outer lines on each side
% to simplyfy handling of edge pixel
function rgbfloat = bilinear_interpolation_debayer(arifloat)
    rgbfloat(:,:,1) = arifloat(:,:);
    rgbfloat(:,:,2) = arifloat(:,:);
    rgbfloat(:,:,3) = arifloat(:,:);

    % calculate green for non-green pixels
    rgbfloat(2:2:(end-1),3:2:(end-1),2) = (arifloat(2:2:(end-1),2:2:(end-1)) + arifloat(3:2:(end),3:2:(end)) + arifloat(2:2:(end-1),4:2:(end)) + arifloat(1:2:(end-3),3:2:(end-1))) / 4;
    rgbfloat(3:2:(end-1),2:2:(end-1),2) = (arifloat(2:2:(end-1),2:2:(end-1)) + arifloat(3:2:(end),3:2:(end)) + arifloat(4:2:(end),2:2:(end-1)) + arifloat(3:2:(end-1),1:2:(end-3))) / 4;
    
    % calculate red for non-red pixels
    rgbfloat(1:2:(end),3:2:(end),1) = (arifloat(1:2:(end),2:2:(end-2)) + arifloat(1:2:(end),4:2:(end)))/2;
    rgbfloat(2:2:(end-1),2:2:(end),1) = (arifloat(1:2:(end-2),2:2:(end)) + arifloat(3:2:(end),2:2:(end)))/2;
    rgbfloat(2:2:(end-1),3:2:(end-1),1) = ( arifloat(1:2:(end-2),2:2:(end-2)) + arifloat(1:2:(end-2),4:2:(end)) + arifloat(3:2:(end),2:2:(end-2)) + arifloat(3:2:(end),4:2:(end)) ) / 4;

    % calculate blue for non-blue pixels
    rgbfloat(2:2:end,2:2:(end-1),3) = (arifloat(2:2:end,1:2:(end-2)) + arifloat(2:2:end,3:2:end)) / 2;
    rgbfloat(3:2:(end-1),1:2:end,3) = (arifloat(2:2:(end-2),1:2:end) + arifloat(4:2:end,1:2:end)) / 2;
    rgbfloat(3:2:(end-1),2:2:(end-1),3) = (arifloat(2:2:(end-2), 1:2:(end-2)) + arifloat(2:2:(end-2),3:2:end) + arifloat(4:2:end,1:2:(end-2)) + arifloat(4:2:end,3:2:end)) / 4;
    
    rgbfloat = rgbfloat(2:(end-1), 2:(end-1), :);
end


% High quality linear demosaicing
% Cutting the outer two pixel lines where no sufficient debayering is possible
function rgbfloat = hqlin_debayer(arifloat)
    rgbfloat(:,:,1) = arifloat(:,:);
    rgbfloat(:,:,2) = arifloat(:,:);
    rgbfloat(:,:,3) = arifloat(:,:);


    % calculate green for non-green pixels
    rgbfloat(3:2:(end-2),4:2:(end-2),2) = ( arifloat(2:2:(end-3),4:2:(end-2)) + arifloat(3:2:(end-2),3:2:(end-3)) + arifloat(4:2:(end-1),4:2:(end-2)) + arifloat(3:2:(end-2),5:2:(end-1)) )/4 + ( 4*arifloat(3:2:(end-2),4:2:(end-2)) - arifloat(1:2:(end-4),4:2:(end-2)) - arifloat(3:2:(end-3),2:2:(end-4)) - arifloat(3:2:(end-2),6:2:(end)) - arifloat(5:2:(end),4:2:(end-2)) )/8;
    rgbfloat(4:2:(end-2),3:2:(end-2),2) = (arifloat(4:2:(end-2),2:2:(end-4)) + arifloat(5:2:(end),3:2:(end-2)) + arifloat(4:2:(end-2),4:2:(end-1)) + arifloat(3:2:(end-3),3:2:(end-2)))/4 + ( 4*arifloat(4:2:(end-2),3:2:(end-2)) - arifloat(4:2:(end-2),1:2:(end-4)) - arifloat(6:2:(end),3:2:(end-2)) - arifloat(4:2:(end-2),5:2:(end)) - arifloat(2:2:(end-4),3:2:(end-2)) )/8;


    % calculate red for non-red pixels
    rgbfloat(4:2:(end-2),3:2:(end-2),1) = ( arifloat(3:2:(end-3),2:2:(end-3)) + arifloat(5:2:(end-1),2:2:(end-3)) + arifloat(5:2:(end-1),4:2:(end-1)) + arifloat(3:2:(end-3),4:2:(end-1)) )/4 + ( 4*arifloat(4:2:(end-2),3:2:(end-2)) - arifloat(2:2:(end-4),3:2:(end-2)) - arifloat(4:2:(end-2),1:2:(end-4)) - arifloat(6:2:(end),3:2:(end-2)) - arifloat(4:2:(end-2),5:2:(end)) )*3/16;
    rgbfloat(3:2:(end-2),3:2:(end-2),1) = ( arifloat(3:2:(end-2),2:2:(end-3)) + arifloat(3:2:(end-2),4:2:(end-1)) )/2 + ( 5*arifloat(3:2:(end-2),3:2:(end-2)) + arifloat(1:2:(end-4),3:2:(end-2))/2 + arifloat(5:2:(end),3:2:(end-2))/2 - arifloat(2:2:(end-3),2:2:(end-3)) - arifloat(2:2:(end-3),4:2:(end-1)) - arifloat(4:2:(end-1),2:2:(end-3)) - arifloat(4:2:(end-1),4:2:(end-1)) - arifloat(3:2:(end-2),1:2:(end-4)) - arifloat(3:2:(end-2),5:2:(end)) )/8;
    rgbfloat(4:2:(end-2),4:2:(end-2),1) = ( arifloat(3:2:(end-3),4:2:(end-2)) + arifloat(5:2:(end-1),4:2:(end-2)) )/2 + ( 5*arifloat(4:2:(end-2),4:2:(end-2)) - arifloat(3:2:(end-3),3:2:(end-3)) - arifloat(5:2:(end-1),3:2:(end-3)) + arifloat(4:2:(end-2),2:2:(end-4))/2 - arifloat(5:2:(end-1),5:2:(end-1)) + arifloat(4:2:(end-2),6:2:(end))/2 - arifloat(3:2:(end-3),5:2:(end-1)) - arifloat(2:2:(end-4),4:2:(end-2)) - arifloat(6:2:(end),4:2:(end-2)) )/8;


    % calculate blue for non-blue pixels
    rgbfloat(3:2:(end-2),4:2:(end-2),3) = ( arifloat(2:2:(end-3),3:2:(end-3)) + arifloat(4:2:(end-1),3:2:(end-3)) + arifloat(4:2:(end-1),5:2:(end-1)) + arifloat(2:2:(end-3),5:2:(end-1)) )/4 + ( 4*arifloat(3:2:(end-2),4:2:(end-2)) - arifloat(1:2:(end-4),4:2:(end-2)) - arifloat(3:2:(end-3),2:2:(end-4)) - arifloat(3:2:(end-2),6:2:(end)) - arifloat(5:2:(end),4:2:(end-2)) )*3/16;
    rgbfloat(3:2:(end-2),3:2:(end-2),3) = ( arifloat(2:2:(end-3),3:2:(end-2)) + arifloat(4:2:(end-1),3:2:(end-2)) )/2 + ( 5*arifloat(3:2:(end-2),3:2:(end-2)) - arifloat(1:2:(end-4),3:2:(end-2)) - arifloat(5:2:(end),3:2:(end-2)) - arifloat(2:2:(end-3),2:2:(end-3)) - arifloat(2:2:(end-3),4:2:(end-1)) - arifloat(4:2:(end-1),2:2:(end-3)) - arifloat(4:2:(end-1),4:2:(end-1)) + arifloat(3:2:(end-2),1:2:(end-4))/2 + arifloat(3:2:(end-2),5:2:(end))/2 )/8;
    rgbfloat(4:2:(end-2),4:2:(end-2),3) = ( arifloat(4:2:(end-2),3:2:(end-3)) + arifloat(4:2:(end-2),5:2:(end-1)) )/2 + ( 5*arifloat(4:2:(end-2),4:2:(end-2)) - arifloat(3:2:(end-3),3:2:(end-3)) - arifloat(5:2:(end-1),3:2:(end-3)) - arifloat(4:2:(end-2),2:2:(end-4)) - arifloat(5:2:(end-1),5:2:(end-1)) - arifloat(4:2:(end-2),6:2:(end)) - arifloat(3:2:(end-3),5:2:(end-1)) + arifloat(2:2:(end-4),4:2:(end-2))/2 + arifloat(6:2:(end),4:2:(end-2))/2 )/8;

    
    rgbfloat = rgbfloat(3:(end-2), 3:(end-2), :);
end
